import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/mock_delay.dart';

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
  final String userId;
  final String role; // 'parent' or 'teacher'
  final String name;

  const AuthSuccess({
    required this.userId,
    required this.role,
    required this.name,
  });

  @override
  List<Object?> get props => [userId, role, name];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OtpSent extends AuthState {
  final String message;

  const OtpSent({required this.message});

  @override
  List<Object?> get props => [message];
}

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

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

class ForgotPasswordRequested extends AuthEvent {
  final String studentId;

  const ForgotPasswordRequested({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<ParentLoginRequested>(_onParentLogin);
    on<TeacherLoginRequested>(_onTeacherLogin);
    on<TeacherOtpRequested>(_onTeacherOtp);
    on<TeacherOtpVerified>(_onTeacherOtpVerified);
    on<ForgotPasswordRequested>(_onForgotPassword);
  }

  Future<void> _onParentLogin(
    ParentLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await MockDelay.simulate();

    // Mock validation: any non-empty credentials work
    if (event.studentId.isNotEmpty && event.password.isNotEmpty) {
      emit(const AuthSuccess(
        userId: 'p1',
        role: 'parent',
        name: 'Amit Sharma',
      ));
    } else {
      emit(const AuthError(message: 'Invalid Student ID or Password.'));
    }
  }

  Future<void> _onTeacherLogin(
    TeacherLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await MockDelay.simulate();

    if (event.employeeId.isNotEmpty && event.password.isNotEmpty) {
      emit(const AuthSuccess(
        userId: 't1',
        role: 'teacher',
        name: 'Rajesh Kumar',
      ));
    } else {
      emit(const AuthError(message: 'Invalid Employee ID or Password.'));
    }
  }

  Future<void> _onTeacherOtp(
    TeacherOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await MockDelay.simulate(milliseconds: 1200);

    emit(const OtpSent(message: 'OTP sent to registered mobile number.'));
  }

  Future<void> _onTeacherOtpVerified(
    TeacherOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await MockDelay.simulate();

    if (event.otp.length == 6) {
      emit(AuthSuccess(
        userId: 't_${event.employeeId}',
        role: 'teacher',
        name: 'Rajesh Kumar',
      ));
    } else {
      emit(const AuthError(message: 'Invalid OTP. Please try again.'));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await MockDelay.simulate(milliseconds: 1500);

    emit(const OtpSent(
      message: 'Password reset link has been sent to your registered contact.',
    ));
  }
}
