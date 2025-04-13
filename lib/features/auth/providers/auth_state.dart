import 'package:flutter/foundation.dart';

// This is a simple class to represent different authentication states
// for a more complex state management approach. For most cases, the
// AuthProvider is sufficient.
enum AuthenticationStatus {
  unknown,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthState {
  final AuthenticationStatus status;
  final String? errorMessage;
  final String? userId;
  final String? token;

  const AuthState({
    this.status = AuthenticationStatus.unknown,
    this.errorMessage,
    this.userId,
    this.token,
  });

  factory AuthState.unknown() => const AuthState(
        status: AuthenticationStatus.unknown,
      );

  factory AuthState.unauthenticated() => const AuthState(
        status: AuthenticationStatus.unauthenticated,
      );

  factory AuthState.authenticating() => const AuthState(
        status: AuthenticationStatus.authenticating,
      );

  factory AuthState.authenticated({
    required String userId,
    required String token,
  }) =>
      AuthState(
        status: AuthenticationStatus.authenticated,
        userId: userId,
        token: token,
      );

  factory AuthState.error(String message) => AuthState(
        status: AuthenticationStatus.error,
        errorMessage: message,
      );

  AuthState copyWith({
    AuthenticationStatus? status,
    String? errorMessage,
    String? userId,
    String? token,
  }) =>
      AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        userId: userId ?? this.userId,
        token: token ?? this.token,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.errorMessage == errorMessage &&
        other.userId == userId &&
        other.token == token;
  }

  @override
  int get hashCode =>
      status.hashCode ^
      errorMessage.hashCode ^
      userId.hashCode ^
      token.hashCode;
}
