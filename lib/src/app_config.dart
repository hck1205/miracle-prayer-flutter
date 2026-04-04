class AppConfig {
  static const String backendBaseUrl = String.fromEnvironment(
    "BACKEND_BASE_URL",
    defaultValue: "http://127.0.0.1:3000/api",
  );

  static const String googleClientId = String.fromEnvironment(
    "GOOGLE_CLIENT_ID",
  );
  static const String googleServerClientId = String.fromEnvironment(
    "GOOGLE_SERVER_CLIENT_ID",
  );

  static String get normalizedBackendBaseUrl =>
      backendBaseUrl.replaceAll(RegExp(r"/+$"), "");
}
