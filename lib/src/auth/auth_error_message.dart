const String authBackendRequestFailedCode = "auth.backend_request_failed";
const String authGoogleInitFailedCode = "auth.google_init_failed";
const String authGoogleCanceledCode = "auth.google_canceled";

bool isCanceledGoogleSignInError(Object error) {
  final String rawMessage = error.toString();

  return rawMessage.contains("GoogleSignInExceptionCode.canceled") ||
      rawMessage.contains("GoogleSignInException(code canceled") ||
      rawMessage.contains("sign_in_canceled");
}

String mapAuthErrorMessage(Object error) {
  final String rawMessage = error.toString().replaceFirst("Exception: ", "");

  if (rawMessage.contains("XMLHttpRequest error")) {
    return authBackendRequestFailedCode;
  }

  if (rawMessage.contains("not initialized")) {
    return authGoogleInitFailedCode;
  }

  if (isCanceledGoogleSignInError(error)) {
    return authGoogleCanceledCode;
  }

  return rawMessage;
}
