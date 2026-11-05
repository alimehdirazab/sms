import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/auth_response_model.dart';
import '../repositories/auth_repository.dart';

// --- States ---
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserModel user;

  const AuthSuccess({required this.user});

  String get userId => user.id;
  String get role => user.role;
  String get name => user.name;
  String? get activeStudentId => user.activeStudentId;

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordSent extends AuthState {
  final String message;

  const ForgotPasswordSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class ResetPasswordSuccess extends AuthState {
  final String message;

  const ResetPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class OtpSent extends AuthState {
  final String message;

  const OtpSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthSessionEvent extends AuthEvent {
  const CheckAuthSessionEvent();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String roleHint; // 'teacher' or 'parent'
  final String? fcmToken;

  const LoginRequested({
    required this.email,
    required this.password,
    this.roleHint = '',
    this.fcmToken,
  });

  @override
  List<Object?> get props => [email, password, roleHint, fcmToken];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String password;

  const ResetPasswordRequested({
    required this.token,
    required this.password,
  });

  @override
  List<Object?> get props => [token, password];
}

class LogoutRequested extends AuthEvent {
  final String? fcmToken;

  const LogoutRequested({this.fcmToken});

  @override
  List<Object?> get props => [fcmToken];
}

// Backward compatibility events for existing UI components
class ParentLoginRequested extends AuthEvent {
  final String studentId;
  final String password;

  const ParentLoginRequested({
    required this.studentId,
    required this.password,
  });

  @override
  List<Object?> get props => [studentId, password];
}

class TeacherLoginRequested extends AuthEvent {
  final String employeeId;
  final String password;

  const TeacherLoginRequested({
    required this.employeeId,
    required this.password,
  });

  @override
  List<Object?> get props => [employeeId, password];
}

class TeacherOtpRequested extends AuthEvent {
  final String employeeId;

  const TeacherOtpRequested({required this.employeeId});

  @override
  List<Object?> get props => [employeeId];
}

class TeacherOtpVerified extends AuthEvent {
  final String employeeId;
  final String otp;

  const TeacherOtpVerified({
    required this.employeeId,
    required this.otp,
  });

  @override
  List<Object?> get props => [employeeId, otp];
}

// --- BLoC Implementation ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository? authRepository;

  AuthBloc({this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthSessionEvent>(_onCheckAuthSession);
    on<LoginRequested>(_onLoginRequested);
    on<ParentLoginRequested>(_onParentLoginLegacy);
    on<TeacherLoginRequested>(_onTeacherLoginLegacy);
    on<TeacherOtpRequested>(_onTeacherOtpRequested);
    on<TeacherOtpVerified>(_onTeacherOtpVerified);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthSession(
    CheckAuthSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (authRepository == null) return;
    try {
      final user = await authRepository!.getCachedUser();
      if (user != null) {
        emit(AuthSuccess(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (authRepository != null) {
        final result = await authRepository!.login(
          email: event.email,
          password: event.password,
          fcmToken: event.fcmToken,
        );

        final user = result.user ??
            UserModel(
              id: 'user_1',
              email: event.email,
              firstName: event.email.split('@').first,
              role: event.roleHint.isNotEmpty ? event.roleHint : 'parent',
            );

        emit(AuthSuccess(user: user));
      } else {
        // Fallback mock if repo not provided
        emit(AuthSuccess(
          user: UserModel(
            id: 'mock_1',
            email: event.email,
            firstName: 'Demo User',
            role: event.roleHint.isNotEmpty ? event.roleHint : 'parent',
          ),
        ));
      }
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onParentLoginLegacy(
    ParentLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.studentId.contains('@')
        ? event.studentId
        : '${event.studentId.toLowerCase().replaceAll(' ', '')}@school.com';
    add(LoginRequested(
      email: email,
      password: event.password,
      roleHint: 'parent',
    ));
  }

  Future<void> _onTeacherLoginLegacy(
    TeacherLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.employeeId.contains('@')
        ? event.employeeId
        : '${event.employeeId.toLowerCase().replaceAll(' ', '')}@school.com';
    add(LoginRequested(
      email: email,
      password: event.password,
      roleHint: 'teacher',
    ));
  }

  Future<void> _onTeacherOtpRequested(
    TeacherOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(const OtpSent(
      message: 'OTP sent to registered mobile number (Demo: 123456)',
    ));
  }

  Future<void> _onTeacherOtpVerified(
    TeacherOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    if (event.otp == '123456' || event.otp.length == 6) {
      final email = event.employeeId.contains('@')
          ? event.employeeId
          : '${event.employeeId.toLowerCase()}@school.com';
      emit(AuthSuccess(
        user: UserModel(
          id: event.employeeId,
          email: email,
          firstName: 'Teacher ${event.employeeId}',
          role: 'teacher',
        ),
      ));
    } else {
      emit(const AuthError(message: 'Invalid OTP entered. Please try again.'));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (authRepository != null) {
        final msg = await authRepository!.forgotPassword(email: event.email);
        emit(ForgotPasswordSent(message: msg));
      } else {
        emit(const ForgotPasswordSent(
          message: 'Reset instructions sent to your email.',
        ));
      }
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (authRepository != null) {
        final msg = await authRepository!.resetPassword(
          token: event.token,
          newPassword: event.password,
        );
        emit(ResetPasswordSuccess(message: msg));
      } else {
        emit(const ResetPasswordSuccess(
          message: 'Password reset successfully.',
        ));
      }
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository?.logout(fcmToken: event.fcmToken);
    } finally {
      emit(const AuthUnauthenticated());
    }
  }
}
