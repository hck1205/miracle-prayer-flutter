import "dart:convert";

class AuthenticatedUser {
  static const Object _sentinel = Object();

  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.name,
  });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      id: json["id"] as String,
      email: json["email"] as String,
      name: json["name"] as String?,
    );
  }

  final String id;
  final String email;
  final String? name;

  AuthenticatedUser copyWith({
    String? id,
    String? email,
    Object? name = _sentinel,
  }) {
    return AuthenticatedUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: identical(name, _sentinel) ? this.name : name as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{"id": id, "email": email, "name": name};
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.refreshExpiresIn,
    required this.user,
  });

  factory AuthSession.fromLoginResponse(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json["accessToken"] as String,
      tokenType: json["tokenType"] as String,
      expiresIn: json["expiresIn"] as int,
      refreshToken: json["refreshToken"] as String,
      refreshExpiresIn: json["refreshExpiresIn"] as int,
      user: AuthenticatedUser.fromJson(json["user"] as Map<String, dynamic>),
    );
  }

  factory AuthSession.fromStorage(String raw) {
    return AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json["accessToken"] as String,
      tokenType: json["tokenType"] as String,
      expiresIn: json["expiresIn"] as int,
      refreshToken: json["refreshToken"] as String,
      refreshExpiresIn: json["refreshExpiresIn"] as int,
      user: AuthenticatedUser.fromJson(json["user"] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;
  final int refreshExpiresIn;
  final AuthenticatedUser user;

  AuthSession copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    String? refreshToken,
    int? refreshExpiresIn,
    AuthenticatedUser? user,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshExpiresIn: refreshExpiresIn ?? this.refreshExpiresIn,
      user: user ?? this.user,
    );
  }

  String toStorage() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "accessToken": accessToken,
      "tokenType": tokenType,
      "expiresIn": expiresIn,
      "refreshToken": refreshToken,
      "refreshExpiresIn": refreshExpiresIn,
      "user": user.toJson(),
    };
  }
}
