import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/models/user_model.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/marks_model.dart';
import '../../auth/models/notification_model.dart';
import 'mock_parent_repository.dart';

// --- States ---
abstract class ParentState extends Equatable {
  const ParentState();
  @override
  List<Object?> get props => [];
}

class ParentInitial extends ParentState {}

class ParentProfileLoading extends ParentState {}
class ParentProfileLoaded extends ParentState {
  final ParentModel profile;
  final int selectedChildIndex;
  const ParentProfileLoaded(this.profile, {this.selectedChildIndex = 0});
  @override
  List<Object?> get props => [profile, selectedChildIndex];
}
class ParentProfileError extends ParentState {
  final String message;
  const ParentProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class ParentAttendanceLoading extends ParentState {}
class ParentAttendanceLoaded extends ParentState {
  final AttendanceModel todayAttendance;
  final List<AttendanceModel> monthlyAttendance;
  const ParentAttendanceLoaded(this.todayAttendance, this.monthlyAttendance);
  @override
  List<Object?> get props => [todayAttendance, monthlyAttendance];
}

class ParentMarksLoading extends ParentState {}
class ParentMarksLoaded extends ParentState {
  final List<StudentMarkModel> marks;
  const ParentMarksLoaded(this.marks);
  @override
  List<Object?> get props => [marks];
}

class ParentUpcomingExamsLoading extends ParentState {}
class ParentUpcomingExamsLoaded extends ParentState {
  final List<ExamModel> exams;
  const ParentUpcomingExamsLoaded(this.exams);
  @override
  List<Object?> get props => [exams];
}

class ParentNotificationsLoading extends ParentState {}
class ParentNotificationsLoaded extends ParentState {
  final List<NotificationModel> notifications;
  const ParentNotificationsLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class ParentError extends ParentState {
  final String message;
  const ParentError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Events ---
abstract class ParentEvent extends Equatable {
  const ParentEvent();
  @override
  List<Object?> get props => [];
}

class LoadParentProfile extends ParentEvent {}
class SelectChild extends ParentEvent {
  final int index;
  const SelectChild(this.index);
  @override
  List<Object?> get props => [index];
}
class LoadTodayAttendance extends ParentEvent {
  final String studentId;
  const LoadTodayAttendance(this.studentId);
  @override
  List<Object?> get props => [studentId];
}
class LoadMonthlyAttendance extends ParentEvent {
  final String studentId;
  final DateTime month;
  const LoadMonthlyAttendance(this.studentId, this.month);
  @override
  List<Object?> get props => [studentId, month];
}
class LoadStudentMarks extends ParentEvent {
  final String studentId;
  const LoadStudentMarks(this.studentId);
  @override
  List<Object?> get props => [studentId];
}
class LoadUpcomingExams extends ParentEvent {
  final String studentId;
  const LoadUpcomingExams(this.studentId);
  @override
  List<Object?> get props => [studentId];
}
class LoadNotifications extends ParentEvent {}
class ChangePasswordRequested extends ParentEvent {
  final String oldPassword;
  final String newPassword;
  const ChangePasswordRequested(this.oldPassword, this.newPassword);
  @override
  List<Object?> get props => [oldPassword, newPassword];
}

// --- BLoC ---
class ParentBloc extends Bloc<ParentEvent, ParentState> {
  final MockParentRepository _repository;

  ParentBloc({MockParentRepository? repository})
      : _repository = repository ?? MockParentRepository(),
        super(ParentInitial()) {
    on<LoadParentProfile>(_onLoadProfile);
    on<SelectChild>(_onSelectChild);
    on<LoadTodayAttendance>(_onLoadTodayAttendance);
    on<LoadMonthlyAttendance>(_onLoadMonthlyAttendance);
    on<LoadStudentMarks>(_onLoadStudentMarks);
    on<LoadUpcomingExams>(_onLoadUpcomingExams);
    on<LoadNotifications>(_onLoadNotifications);
    on<ChangePasswordRequested>(_onChangePassword);
  }

  Future<void> _onLoadProfile(
    LoadParentProfile event,
    Emitter<ParentState> emit,
  ) async {
    emit(ParentProfileLoading());
    try {
      final profile = await _repository.getParentProfile();
      emit(ParentProfileLoaded(profile));
    } catch (e) {
      emit(ParentProfileError(e.toString()));
    }
  }

  void _onSelectChild(SelectChild event, Emitter<ParentState> emit) {
    final current = state;
    if (current is ParentProfileLoaded) {
      emit(ParentProfileLoaded(current.profile,
          selectedChildIndex: event.index));
    }
  }

  Future<void> _onLoadTodayAttendance(
    LoadTodayAttendance event,
    Emitter<ParentState> emit,
  ) async {
    emit(ParentAttendanceLoading());
    try {
      final today = await _repository.getTodayAttendance(event.studentId);
      emit(ParentAttendanceLoaded(today, []));
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onLoadMonthlyAttendance(
    LoadMonthlyAttendance event,
    Emitter<ParentState> emit,
  ) async {
    emit(ParentAttendanceLoading());
    try {
      final monthly = await _repository.getMonthlyAttendance(
        event.studentId,
        event.month,
      );
      final today = await _repository.getTodayAttendance(event.studentId);
      emit(ParentAttendanceLoaded(today, monthly));
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onLoadStudentMarks(
    LoadStudentMarks event,
    Emitter<ParentState> emit,
  ) async {
    emit(ParentMarksLoading());
    try {
      final marks = await _repository.getStudentMarks(event.studentId);
      emit(ParentMarksLoaded(marks));
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onLoadUpcomingExams(
    LoadUpcomingExams event,
    Emitter<ParentState> emit,
  ) async {
    emit(ParentUpcomingExamsLoading());
    try {
      final exams = await _repository.getUpcomingExams(event.studentId);
      emit(ParentUpcomingExamsLoaded(exams));
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<ParentState> emit,
  ) async {
    emit(ParentNotificationsLoading());
    try {
      final notifications = await _repository.getNotifications();
      emit(ParentNotificationsLoaded(notifications));
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordRequested event,
    Emitter<ParentState> emit,
  ) async {
    try {
      await _repository.changePassword(event.oldPassword, event.newPassword);
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }
}
