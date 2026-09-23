import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/session_cache.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/otp_digit_boxes.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.identifier, this.purpose = 'registration'});

  /// Numéro de téléphone ou email vers lequel le code a été envoyé.
  final String identifier;

  /// Doit correspondre exactement à l'enum backend: registration | login | password_reset | phone_verification
  final String purpose;

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const _codeLength = 6; // aligné sur OtpService::generate() côté backend (6 chiffres)
  String _code = '';
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;

  String get _channel => widget.identifier.contains('@') ? 'email' : 'sms';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _onDigit(String digit) {
    if (_code.length >= _codeLength) return;
    setState(() {
      _code += digit;
      _errorMessage = null;
    });

    if (_code.length == _codeLength) {
      _verify();
    }
  }

  void _onBackspace() {
    if (_code.isEmpty) return;
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  Future<void> _verify() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final loggedIn = await ref.read(authRepositoryProvider).verifyOtp(
            identifier: widget.identifier,
            purpose: widget.purpose,
            code: _code,
          );

      if (!mounted) return;

      if (loggedIn) {
        clearUserScopedCache(ref); // purge les données d'un éventuel compte précédent
        ref.read(pushNotificationServiceProvider).registerDeviceToken(); // fire-and-forget
        context.go('/'); // token déjà sauvegardé par le repository
      } else {
        // Cas password_reset par ex : le code est vérifié mais il n'y a pas de token,
        // l'écran suivant (nouveau mot de passe) prend le relais.
        context.pop(true);
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _code = ''; // on vide pour laisser ressaisir
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      await ref.read(authRepositoryProvider).requestOtp(
            identifier: widget.identifier,
            channel: _channel,
            purpose: widget.purpose,
          );
      _startCountdown();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
              const SizedBox(height: 8),
              Text('Vérifiez votre compte', style: textTheme.displayMedium),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  children: [
                    const TextSpan(text: 'Saisissez le code envoyé à\n'),
                    TextSpan(text: widget.identifier, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              OtpDigitBoxes(code: _code, length: _codeLength),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Text(_errorMessage!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                ),
              ],

              const SizedBox(height: 20),

              Row(
                children: [
                  Text('Code non reçu ? ', style: textTheme.bodyMedium),
                  GestureDetector(
                    onTap: _resend,
                    child: Text(
                      _isResending ? 'Envoi...' : 'Renvoyer le code',
                      style: textTheme.bodyMedium?.copyWith(
                        color: _secondsRemaining == 0 ? AppColors.primary : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_secondsRemaining > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
                      child: Text('00:${_secondsRemaining.toString().padLeft(2, '0')}', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _code.length == _codeLength && !_isVerifying ? _verify : null,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
                  child: _isVerifying
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Vérifier'),
                ),
              ),
              const SizedBox(height: 12),

              NumericKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
