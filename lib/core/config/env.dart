/// Configuration lue depuis --dart-define selon le flavor (dev/prod).
abstract final class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1', // 10.0.2.2 = localhost depuis l'émulateur Android
  );

  static const String reverbHost = String.fromEnvironment('REVERB_HOST', defaultValue: '10.0.2.2');
  static const String reverbKey = String.fromEnvironment('REVERB_APP_KEY', defaultValue: '');

  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}
