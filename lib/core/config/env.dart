/// Configuration lue depuis --dart-define selon le flavor (dev/prod).
abstract final class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1', // 10.0.2.2 = localhost depuis l'émulateur Android
  );

  static const String reverbHost = String.fromEnvironment('REVERB_HOST', defaultValue: '10.0.2.2');
  static const int reverbPort = int.fromEnvironment('REVERB_PORT', defaultValue: 8080);
  static const String reverbKey = String.fromEnvironment('REVERB_APP_KEY', defaultValue: '8ait438fpuyx1z7a4cdi');
  static const bool reverbUseTls = bool.fromEnvironment('REVERB_USE_TLS', defaultValue: false);

  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}
