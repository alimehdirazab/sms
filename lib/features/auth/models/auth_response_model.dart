import 'package:equatable/equatable.dart';
import 'auth_user_model.dart';
export 'auth_user_model.dart';

class AuthResponseModel extends Equatable {
  final bool success;
  final String message;
  final String accessToken;
  final String refreshToken;
  final UserModel? user;

  const AuthResponseModel({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AuthResponseModel(
        success: false,
        message: 'Empty response',
        accessToken: '',
        refreshToken: '',
      );
    }

    final success = json['success'] is bool
        ? json['success'] as bool
        : (json['status'] == 'success' || json['accessToken'] != null);

    final message = json['message']?.toString() ?? '';

    // Handle nested data envelope { success: true, data: { accessToken: ..., user: ... } }
    final dynamic dataObj = json['data'] is Map<String, dynamic>
        ? json['data']
        : json;

    final dataMap = dataObj is Map<String, dynamic> ? dataObj : <String, dynamic>{};

    final accessToken = dataMap['accessToken']?.toString() ??
        json['accessToken']?.toString() ??
        '';

    final refreshToken = dataMap['refreshToken']?.toString() ??
        json['refreshToken']?.toString() ??
        '';

    final userJson = dataMap['user'] is Map<String, dynamic>
        ? dataMap['user'] as Map<String, dynamic>
        : (json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : dataMap);

    final user = UserModel.fromJson(userJson);

    return AuthResponseModel(
      success: success,
      message: message,
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        if (user != null) 'user': user!.toJson(),
      },
    };
  }

  @override
  List<Object?> get props => [success, message, accessToken, refreshToken, user];
}
