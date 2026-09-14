import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_selector.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _role = UserRole.buyer;
  bool _acceptedTerms = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _fullNameController,
      _emailController,
      _phoneController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  bool get _canSubmit =>
      _fullNameController.text.trim().length >= 2 &&
      _emailRegex.hasMatch(_emailController.text.trim()) &&
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmPasswordController.text &&
      _acceptedTerms &&
      !_isSubmitting;

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    debugPrint('[RegisterScreen] Envoi de la requête register pour $email...');

    // 1. Nettoyage et formatage du numéro de téléphone
    final rawPhone = _phoneController.text.trim();
    String? formattedPhone;

    if (rawPhone.isNotEmpty) {
      // Si le numéro ne commence pas déjà par +225 ou 225, on ajoute +225 devant
      if (rawPhone.startsWith('+225')) {
        formattedPhone = rawPhone;
      } else if (rawPhone.startsWith('225')) {
        formattedPhone = '+$rawPhone';
      } else {
        formattedPhone = '+225$rawPhone';
      }
    }

    try {
      await ref.read(authRepositoryProvider).register(
            fullName: _fullNameController.text.trim(),
            email: email,
            phone: formattedPhone, // 2. Envoi du numéro au format +225XXXXXXXXXX
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            role: _role == UserRole.buyer ? 'buyer' : 'seller',
          );

      if (!mounted) {
        debugPrint('[RegisterScreen] ATTENTION: widget démonté avant la navigation, push annulé.');
        return;
      }
      final target = '/otp?identifier=${Uri.encodeComponent(email)}&purpose=registration';
      debugPrint('[RegisterScreen] context.push($target)');
      context.push(target);
    } on ApiException catch (e) {
      debugPrint('[RegisterScreen] ApiException: ${e.message} (status ${e.statusCode})');
      setState(() => _errorMessage = e.message);
    }catch (e, stackTrace) {
      // Filet de sécurité : capture TOUT ce qui n'est pas une ApiException
      // (ex: erreur de parsing JSON inattendue) pour ne jamais rester bloqué
      // silencieusement sur cet écran.
      debugPrint('[RegisterScreen] Erreur inattendue: $e');
      debugPrint(stackTrace.toString());
      setState(() => _errorMessage = 'Erreur inattendue : $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _fullNameController,
      _emailController,
      _phoneController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.removeListener(_onFieldChanged);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBE9DD), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                    const Spacer(),
                    Text('Trok', style: textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Créez votre compte', style: textTheme.headlineLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text('Rejoignez la communauté Trok aujourd\'hui.', style: textTheme.bodyMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 24),

                      Text('Je suis un...', style: textTheme.titleMedium),
                      const SizedBox(height: 10),
                      RoleSelector(selected: _role, onChanged: (role) => setState(() => _role = role)),
                      const SizedBox(height: 20),

                      AuthTextField(controller: _fullNameController, hint: 'Nom complet', icon: Icons.person_outline_rounded),
                      const SizedBox(height: 14),

                      AuthTextField(
                        controller: _emailController,
                        hint: 'Adresse email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      AuthTextField(
                        controller: _phoneController,
                        hint: 'Numéro de téléphone (optionnel)',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        prefixText: '+225 ',
                      ),
                      const SizedBox(height: 14),

                      AuthTextField(controller: _passwordController, hint: 'Mot de passe', icon: Icons.lock_outline_rounded, obscureText: true),
                      const SizedBox(height: 14),

                      AuthTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirmez le mot de passe',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                      ),

                      if (_passwordController.text.isNotEmpty &&
                          _confirmPasswordController.text.isNotEmpty &&
                          _passwordController.text != _confirmPasswordController.text) ...[
                        const SizedBox(height: 6),
                        Text('Les mots de passe ne correspondent pas.', style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                      ],

                      const SizedBox(height: 18),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptedTerms,
                              onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: textTheme.bodySmall,
                                children: [
                                  const TextSpan(text: "J'accepte les "),
                                  TextSpan(text: "Conditions d'utilisation", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  const TextSpan(text: ' et la '),
                                  TextSpan(text: 'Politique de confidentialité.', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                          child: Text(_errorMessage!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                        ),
                      ],

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canSubmit ? _submit : null,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
                          child: _isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Créer mon compte'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: () => context.pushReplacement('/login'),
                          child: Text.rich(
                            TextSpan(
                              style: textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'Vous avez déjà un compte ? '),
                                TextSpan(text: 'Connectez-vous', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
