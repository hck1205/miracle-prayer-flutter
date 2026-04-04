import "../core/utils/string_utils.dart";
import "auth_models.dart";

String authDisplayName(
  AuthenticatedUser user, {
  String fallback = "Authenticated reader",
}) {
  final String? name = normalizeNullable(user.name);
  return name ?? user.email;
}

String authSummaryName(AuthenticatedUser? user, {String fallback = "Your account"}) {
  if (user == null) {
    return fallback;
  }

  final String? name = normalizeNullable(user.name);
  return name ?? user.email;
}

String authLeadingCharacter(AuthenticatedUser user) {
  return leadingCharacter(authDisplayName(user));
}

String formatRefreshExpiresIn(int seconds) => "$seconds seconds";
