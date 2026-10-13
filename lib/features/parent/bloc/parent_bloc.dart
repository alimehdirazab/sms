import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/models/user_model.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/marks_model.dart';
import '../../auth/models/notification_model.dart';
import '../../auth/models/leave_model.dart';
import '../../auth/models/fee_model.dart';
import '../../auth/models/academic_calendar_model.dart';
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

// --- Leave ---
class ParentLeaveLoading extends ParentState {
  const ParentLeaveLoading();
}
class ParentLeaveLoaded extends ParentState {
  final List<LeaveApplicationModel> applications;

  /// Transient flag used to show a success animation/snackbar once.
  final bool justSubmitted;
  const ParentLeaveLoaded(this.applications, {this.justSubmitted = false});
  @override
  List<Object?> get props => [applications, justSubmitted];
}
class ParentLeaveSubmitting extends ParentState {
  const ParentLeaveSubmitting();
}
class ParentLeaveError extends ParentState {
  final String message;
  const ParentLeaveError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Fees ---
class ParentFeesLoading extends ParentState {
  const ParentFeesLoading();
}
class ParentFeesLoaded extends ParentState {
  final List<FeeModel> fees;
  final List<FeePaymentModel> payments;
  final SchoolAccountModel account;
  const ParentFeesLoaded(this.fees, this.payments, this.account);
  double get totalOutstanding =>
      fees.fold<double>(0, (sum, f) => sum + f.balance);
  @override
  List<Object?> get props => [fees, payments, account];
}
class ParentFeeSubmitting extends ParentState {
  const ParentFeeSubmitting();
}
class ParentFeeSubmitted extends ParentState {
  final FeePaymentModel payment;
  const ParentFeeSubmitted(this.payment);
  @override
  List<Object?> get props => [payment];
}
class ParentFeesError extends ParentState {
  final String message;
  const ParentFeesError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Academic calendar ---
class ParentCalendarLoading extends ParentState {
  const ParentCalendarLoading();
}
class ParentCalendarLoaded extends ParentState {
  final List<AcademicCalendarEvent> events;
  const ParentCalendarLoaded(this.events);
  @override
  List<Object?> get props => [events];
}

// --- Analytics (dashboard charts) ---
class ParentAnalyticsLoading extends ParentState {
  const ParentAnalyticsLoading();
}
class ParentAnalyticsLoaded extends ParentState {
  final StudentAnalytics analytics;
  const ParentAnalyticsLoaded(this.analytics);
  @override
  List<Object?> get props => [analytics];
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

// --- Leave events ---
class LoadLeaveApplications extends ParentEvent {
  final String studentId;
  const LoadLeaveApplications(this.studentId);
  @override
  List<Object?> get props => [studentId];
}
class SubmitLeaveApplication extends ParentEvent {
  final LeaveApplicationModel application;
  const SubmitLeaveApplication(this.application);
  @override
  List<Object?> get props => [application];
}
class CancelLeaveApplication extends ParentEvent {
  final String leaveId;
  final String studentId;
  const CancelLeaveApplication(this.leaveId, this.studentId);
  @override
  List<Object?> get props => [leaveId, studentId];
}

// --- Fee events ---
class LoadFees extends ParentEvent {
  final String studentId;
  const LoadFees(this.studentId);
  @override
  List<Object?> get props => [studentId];
}
class SubmitFeePayment extends ParentEvent {
  final FeePaymentModel payment;
  final String studentId;
  const SubmitFeePayment(this.payment, this.studentId);
  @override
  List<Object?> get props => [payment, studentId];
}

// --- Calendar event ---
class LoadAcademicCalendar extends ParentEvent {}

// --- Analytics event ---
class LoadStudentAnalytics extends ParentEvent {
  final String studentId;
  const LoadStudentAnalytics(this.studentId);
  @override
  List<Object?> get props => [studentId];
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
    on<LoadLeaveApplications>(_onLoadLeaveApplications);
    on<SubmitLeaveApplication>(_onSubmitLeaveApplication);
    on<CancelLeaveApplication>(_onCancelLeaveApplication);
    on<LoadFees>(_onLoadFees);
    on<SubmitFeePayment>(_onSubmitFeePayment);
    on<LoadAcademicCalendar>(_onLoadAcademicCalendar);
    on<LoadStudentAnalytics>(_onLoadStudentAnalytics);
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
      emit(ParentAttendanceLoaded(today, const []));
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

  // ─────────────────────────── LEAVE ───────────────────────────

  Future<void> _onLoadLeaveApplications(
    LoadLeaveApplications event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentLeaveLoading());
    try {
      final applications =
          await _repository.getLeaveApplications(event.studentId);
      emit(ParentLeaveLoaded(applications));
    } catch (e) {
      emit(const ParentLeaveError('Failed to load leave applications.'));
    }
  }

  Future<void> _onSubmitLeaveApplication(
    SubmitLeaveApplication event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentLeaveSubmitting());
    try {
      await _repository.submitLeaveApplication(event.application);
      // Refresh the list so the new entry shows with its pending status.
      final applications =
          await _repository.getLeaveApplications(event.application.applicantId);
      emit(ParentLeaveLoaded(applications, justSubmitted: true));
    } catch (e) {
      emit(const ParentLeaveError('Failed to submit leave application.'));
    }
  }

  Future<void> _onCancelLeaveApplication(
    CancelLeaveApplication event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentLeaveSubmitting());
    try {
      await _repository.cancelLeaveApplication(event.leaveId);
      final applications =
          await _repository.getLeaveApplications(event.studentId);
      emit(ParentLeaveLoaded(applications));
    } catch (e) {
      emit(const ParentLeaveError('Failed to cancel leave application.'));
    }
  }

  // ──────────────────────────── FEES ────────────────────────────

  Future<void> _onLoadFees(
    LoadFees event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentFeesLoading());
    try {
      final fees = await _repository.getFees(event.studentId);
      final payments = await _repository.getFeePayments(event.studentId);
      emit(ParentFeesLoaded(fees, payments, _repository.getSchoolAccount()));
    } catch (e) {
      emit(const ParentFeesError('Failed to load fee details.'));
    }
  }

  Future<void> _onSubmitFeePayment(
    SubmitFeePayment event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentFeeSubmitting());
    try {
      final saved = await _repository.submitFeePayment(event.payment);
      emit(ParentFeeSubmitted(saved));
      final fees = await _repository.getFees(event.studentId);
      final payments = await _repository.getFeePayments(event.studentId);
      emit(ParentFeesLoaded(fees, payments, _repository.getSchoolAccount()));
    } catch (e) {
      emit(const ParentFeesError('Failed to submit payment. Please try again.'));
    }
  }

  // ──────────────────────── ACADEMIC CALENDAR ────────────────────────

  Future<void> _onLoadAcademicCalendar(
    LoadAcademicCalendar event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentCalendarLoading());
    try {
      final events = await _repository.getAcademicCalendar();
      emit(ParentCalendarLoaded(events));
    } catch (e) {
      emit(const ParentError('Failed to load academic calendar.'));
    }
  }

  // ─────────────────────────── ANALYTICS ────────────────────────────

  Future<void> _onLoadStudentAnalytics(
    LoadStudentAnalytics event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentAnalyticsLoading());
    try {
      final analytics = await _repository.getStudentAnalytics(event.studentId);
      emit(ParentAnalyticsLoaded(analytics));
    } catch (e) {
      emit(const ParentError('Failed to load analytics.'));
    }
  }
}
