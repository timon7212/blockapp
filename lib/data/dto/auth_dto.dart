// ─── Request DTOs ───

class RegisterRequest {
  final String email;
  final String password;
  final String displayName;
  final String? referralCode;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.displayName,
    this.referralCode,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'displayName': displayName,
        if (referralCode != null) 'referralCode': referralCode,
      };
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class GoogleSignInRequest {
  final String idToken;
  final String? referralCode;

  const GoogleSignInRequest({required this.idToken, this.referralCode});

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
        if (referralCode != null) 'referralCode': referralCode,
      };
}

class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'newPassword': newPassword,
      };
}

// ─── Response DTOs ───

class UserSummaryDto {
  final String id;
  final String email;
  final String displayName;
  final String referralCode;
  final bool emailVerified;
  final DateTime joinedAt;

  const UserSummaryDto({
    required this.id,
    required this.email,
    required this.displayName,
    required this.referralCode,
    required this.emailVerified,
    required this.joinedAt,
  });

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) => UserSummaryDto(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        referralCode: json['referralCode'] as String,
        emailVerified: json['emailVerified'] as bool,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );
}

class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final UserSummaryDto user;

  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      AuthResponseDto(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: UserSummaryDto.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class MessageResponseDto {
  final String message;

  const MessageResponseDto({required this.message});

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) =>
      MessageResponseDto(message: json['message'] as String);
}
