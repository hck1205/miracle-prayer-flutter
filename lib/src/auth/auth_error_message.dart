String mapAuthErrorMessage(Object error) {
  final String rawMessage = error.toString().replaceFirst("Exception: ", "");

  if (rawMessage.contains("XMLHttpRequest error")) {
    return "Backend request failed. Make sure miracle-prayer-backend is running.";
  }

  if (rawMessage.contains("not initialized")) {
    return "Google sign-in could not initialize. Check GOOGLE_CLIENT_ID.";
  }

  return rawMessage;
}
