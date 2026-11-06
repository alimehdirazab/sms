import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/models/user_model.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/marks_model.dart';
import '../../auth/models/notification_model.dart';
import '../../auth/models/leave_model.dart';
import '../../auth/models/academic_calendar_model.dart';
import '../attendance/repositories/teacher_attendance_repository.dart';
import '../schedule/repositories/teacher_timetable_repository.dart';
import '../../parent/calendar/repositories/academic_calendar_repository.dart';
import '../../parent/notifications/repositories/notification_repository.dart';
import 'mock_teacher_repository.dart';

// --- States ---
abstract class TeacherState extends Equatable {
  const TeacherState();
  @override
  List<Object?> get props => [];
}

class TeacherInitial extends TeacherState {}

// Profile
class TeacherProfileLoading extends TeacherState {}
class TeacherProfileLoaded extends TeacherState {
  final TeacherModel profile;
  const TeacherProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}
class TeacherProfileError extends TeacherState {
  final String message;
  const TeacherProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// Attendance
class TeacherAttendanceLoading extends TeacherState {}
class TeacherAttendanceLoaded extends TeacherState {
  final List<AttendanceModel> records;
  const TeacherAttendanceLoaded(this.records);
  @override
  List<Object?> get props => [records];
}
class TeacherAttendanceError extends TeacherState {
  final String message;
  const TeacherAttendanceError(this.message);
  @override
  List<Object?> get props => [message];
}

// Marks navigation
class TeacherClassesLoading extends TeacherState {}
class TeacherClassesLoaded extends TeacherState {
  final List<String> classes;
  const TeacherClassesLoaded(this.classes);
  @override
  List<Object?> get props => [classes];
}

class TeacherSubjectsLoading extends TeacherState {}
class TeacherSubjectsLoaded extends TeacherState {
  final List<String> subjects;
  final String selectedClass;
  const TeacherSubjectsLoaded(this.subjects, this.selectedClass);
  @override
  List<Object?> get props => [subjects, selectedClass];
}

class TeacherExamsLoading extends TeacherState {}
class TeacherExamsLoaded extends TeacherState {
  final List<ExamModel> exams;
  const TeacherExamsLoaded(this.exams);
  @override
  List<Object?> get props => [exams];
}

class TeacherStudentMarksLoading extends TeacherState {}
class TeacherStudentMarksLoaded extends TeacherState {
  final List<StudentMarkModel> marks;
  const TeacherStudentMarksLoaded(this.marks);
  @override
  List<Object?> get props => [marks];
}

// Save marks
class TeacherMarksSaving extends TeacherState {}
class TeacherMarksSaved extends TeacherState {
  final String message;
  const TeacherMarksSaved(this.message);
  @override
  List<Object?> get props => [message];
}

// Check-in
class TeacherCheckInLoading extends TeacherState {}
class TeacherCheckInSuccess extends TeacherState {
  final bool checkedIn;
  const TeacherCheckInSuccess(this.checkedIn);
  @override
  List<Object?> get props => [checkedIn];
}
class TeacherCheckInError extends TeacherState {
  final String message;
  const TeacherCheckInError(this.message);
  @override
  List<Object?> get props => [message];
}

// Schedule
class TeacherScheduleLoading extends TeacherState {}
class TeacherScheduleLoaded extends TeacherState {
  final List<ScheduleModel> schedule;
  const TeacherScheduleLoaded(this.schedule);
  @override
  List<Object?> get props => [schedule];
}

// Notification count & notifications
class TeacherNotificationCountLoaded extends TeacherState {
  final int count;
  const TeacherNotificationCountLoaded(this.count);
  @override
  List<Object?> get props => [count];
}

class TeacherNotificationsLoading extends TeacherState {}

class TeacherNotificationsLoaded extends TeacherState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  const TeacherNotificationsLoaded(this.notifications, {this.unreadCount = 0});
  @override
  List<Object?> get props => [notifications, unreadCount];
}

class TeacherNotificationsError extends TeacherState {
  final String message;
  const TeacherNotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Weekly timetable
class TeacherWeeklyScheduleLoading extends TeacherState {}
class TeacherWeeklyScheduleLoaded extends TeacherState {
  final Map<String, List<ScheduleModel>> week;
  const TeacherWeeklyScheduleLoaded(this.week);
  @override
  List<Object?> get props => [week];
}

// Academic calendar
class TeacherCalendarLoading extends TeacherState {}
class TeacherCalendarLoaded extends TeacherState {
  final List<AcademicCalendarEvent> events;
  const TeacherCalendarLoaded(this.events);
  @override
  List<Object?> get props => [events];
}

// Analytics
class TeacherAnalyticsLoading extends TeacherState {}
class TeacherAnalyticsLoaded extends TeacherState {
  final TeacherAnalytics analytics;
  const TeacherAnalyticsLoaded(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

// Leave
class TeacherLeaveLoading extends TeacherState {}
class TeacherLeaveLoaded extends TeacherState {
  final List<LeaveApplicationModel> applications;
  final bool justSubmitted;
  const TeacherLeaveLoaded(this.applications, {this.justSubmitted = false});
  @override
  List<Object?> get props => [applications, justSubmitted];
}
class TeacherLeaveSubmitting extends TeacherState {}
class TeacherLeaveError extends TeacherState {
  final String message;
  const TeacherLeaveError(this.message);
  @override
  List<Object?> get props => [message];
}

// Late check-in comment
class TeacherLateCommentSaved extends TeacherState {
  final String message;
  const TeacherLateCommentSaved(this.message);
  @override
  List<Object?> get props => [message];
}

// General error
class TeacherError extends TeacherState {
  final String message;
  const TeacherError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Events ---
abstract class TeacherEvent extends Equatable {
  const TeacherEvent();
  @override
  List<Object?> get props => [];
}

class LoadTeacherProfile extends TeacherEvent {}
class LoadTeacherAttendance extends TeacherEvent {}
class LoadTeacherClasses extends TeacherEvent {}
class LoadTeacherSubjects extends TeacherEvent {
  final String className;
  const LoadTeacherSubjects(this.className);
  @override
  List<Object?> get props => [className];
}
class LoadTeacherExams extends TeacherEvent {
  final String className;
  final String subject;
  const LoadTeacherExams(this.className, this.subject);
  @override
  List<Object?> get props => [className, subject];
}
class LoadStudentMarks extends TeacherEvent {
  final String examId;
  const LoadStudentMarks(this.examId);
  @override
  List<Object?> get props => [examId];
}
class SaveStudentMarks extends TeacherEvent {
  final List<StudentMarkModel> marks;
  const SaveStudentMarks(this.marks);
  @override
  List<Object?> get props => [marks];
}
class PublishMarks extends TeacherEvent {
  final String examId;
  const PublishMarks(this.examId);
  @override
  List<Object?> get props => [examId];
}
class PerformCheckIn extends TeacherEvent {
  final double latitude;
  final double longitude;
  final double accuracy;
  final File? selfieFile;

  const PerformCheckIn({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.selfieFile,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy, selfieFile?.path];
}

class PerformCheckOut extends TeacherEvent {
  final double latitude;
  final double longitude;
  final double accuracy;

  const PerformCheckOut({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy];
}

class LoadTeacherSchedule extends TeacherEvent {}
class LoadNotificationCount extends TeacherEvent {}
class SubmitAttendanceCorrection extends TeacherEvent {
  final String attendanceId;
  final String reason;
  const SubmitAttendanceCorrection(this.attendanceId, this.reason);
  @override
  List<Object?> get props => [attendanceId, reason];
}

class LoadTeacherWeeklySchedule extends TeacherEvent {}
class LoadTeacherCalendar extends TeacherEvent {}
class LoadTeacherAnalytics extends TeacherEvent {}
class AddLateCheckInComment extends TeacherEvent {
  final String attendanceId;
  final String comment;
  const AddLateCheckInComment(this.attendanceId, this.comment);
  @override
  List<Object?> get props => [attendanceId, comment];
}
class LoadTeacherLeaveApplications extends TeacherEvent {}
class SubmitTeacherLeaveApplication extends TeacherEvent {
  final LeaveApplicationModel application;
  const SubmitTeacherLeaveApplication(this.application);
  @override
  List<Object?> get props => [application];
}
class CancelTeacherLeaveApplication extends TeacherEvent {
  final String leaveId;
  const CancelTeacherLeaveApplication(this.leaveId);
  @override
  List<Object?> get props => [leaveId];
}

class BroadcastAnnouncementEvent extends TeacherEvent {
  final String title;
  final String message;
  final String category;
  final int schoolId;

  const BroadcastAnnouncementEvent({
    required this.title,
    required this.message,
    this.category = 'ANNOUNCEMENT',
    required this.schoolId,
  });

  @override
  List<Object?> get props => [title, message, category, schoolId];
}

class LoadTeacherNotifications extends TeacherEvent {
  final bool onlyUnread;
  final String? category;
  const LoadTeacherNotifications({this.onlyUnread = false, this.category});
  @override
  List<Object?> get props => [onlyUnread, category];
}

class MarkTeacherNotificationAsRead extends TeacherEvent {
  final String notificationId;
  const MarkTeacherNotificationAsRead(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class MarkAllTeacherNotificationsAsRead extends TeacherEvent {
  const MarkAllTeacherNotificationsAsRead();
}

// --- BLoC ---
class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final MockTeacherRepository _repository;
  final TeacherAttendanceRepository? _attendanceRepository;
  final TeacherTimetableRepository? _timetableRepository;
  final AcademicCalendarRepository? _calendarRepository;
  final NotificationRepository? _notificationRepository;

  TeacherBloc({
    MockTeacherRepository? repository,
    TeacherAttendanceRepository? attendanceRepository,
    TeacherTimetableRepository? timetableRepository,
    AcademicCalendarRepository? calendarRepository,
    NotificationRepository? notificationRepository,
  })  : _repository = repository ?? MockTeacherRepository(),
        _attendanceRepository = attendanceRepository,
        _timetableRepository = timetableRepository,
        _calendarRepository = calendarRepository,
        _notificationRepository = notificationRepository,
        super(TeacherInitial()) {
    on<LoadTeacherProfile>(_onLoadProfile);
    on<LoadTeacherAttendance>(_onLoadAttendance);
    on<LoadTeacherClasses>(_onLoadClasses);
    on<LoadTeacherSubjects>(_onLoadSubjects);
    on<LoadTeacherExams>(_onLoadExams);
    on<LoadStudentMarks>(_onLoadStudentMarks);
    on<SaveStudentMarks>(_onSaveStudentMarks);
    on<PublishMarks>(_onPublishMarks);
    on<PerformCheckIn>(_onCheckIn);
    on<PerformCheckOut>(_onCheckOut);
    on<LoadTeacherSchedule>(_onLoadSchedule);
    on<LoadNotificationCount>(_onLoadNotificationCount);
    on<SubmitAttendanceCorrection>(_onSubmitCorrection);
    on<LoadTeacherWeeklySchedule>(_onLoadWeeklySchedule);
    on<LoadTeacherCalendar>(_onLoadCalendar);
    on<LoadTeacherAnalytics>(_onLoadAnalytics);
    on<AddLateCheckInComment>(_onAddLateComment);
    on<LoadTeacherLeaveApplications>(_onLoadLeaves);
    on<SubmitTeacherLeaveApplication>(_onSubmitLeave);
    on<CancelTeacherLeaveApplication>(_onCancelLeave);
    on<BroadcastAnnouncementEvent>(_onBroadcastAnnouncement);
    on<LoadTeacherNotifications>(_onLoadTeacherNotifications);
    on<MarkTeacherNotificationAsRead>(_onMarkTeacherNotificationAsRead);
    on<MarkAllTeacherNotificationsAsRead>(_onMarkAllTeacherNotificationsAsRead);
  }

  Future<void> _onLoadProfile(
    LoadTeacherProfile event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherProfileLoading());
    try {
      final profile = await _repository.getTeacherProfile();
      emit(TeacherProfileLoaded(profile));
    } catch (e) {
      emit(TeacherProfileError(e.toString()));
    }
  }

  Future<void> _onLoadAttendance(
    LoadTeacherAttendance event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherAttendanceLoading());
    try {
      final records = await _repository.getTeacherAttendance();
      emit(TeacherAttendanceLoaded(records));
    } catch (e) {
      emit(TeacherAttendanceError(e.toString()));
    }
  }

  Future<void> _onLoadClasses(
    LoadTeacherClasses event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherClassesLoading());
    try {
      final classes = await _repository.getAssignedClasses();
      emit(TeacherClassesLoaded(classes));
    } catch (e) {
      emit(const TeacherError('Failed to load classes.'));
    }
  }

  Future<void> _onLoadSubjects(
    LoadTeacherSubjects event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherSubjectsLoading());
    try {
      final subjects = await _repository.getSubjectsForClass(event.className);
      emit(TeacherSubjectsLoaded(subjects, event.className));
    } catch (e) {
      emit(const TeacherError('Failed to load subjects.'));
    }
  }

  Future<void> _onLoadExams(
    LoadTeacherExams event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherExamsLoading());
    try {
      final exams = await _repository.getExamsForSubject(event.className, event.subject);
      emit(TeacherExamsLoaded(exams));
    } catch (e) {
      emit(const TeacherError('Failed to load exams.'));
    }
  }

  Future<void> _onLoadStudentMarks(
    LoadStudentMarks event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherStudentMarksLoading());
    try {
      final marks = await _repository.getStudentMarks(event.examId);
      emit(TeacherStudentMarksLoaded(marks));
    } catch (e) {
      emit(const TeacherError('Failed to load student marks.'));
    }
  }

  Future<void> _onSaveStudentMarks(
    SaveStudentMarks event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherMarksSaving());
    try {
      await _repository.saveStudentMarks(event.marks);
      emit(const TeacherMarksSaved('Marks saved as draft successfully.'));
    } catch (e) {
      emit(const TeacherError('Failed to save marks.'));
    }
  }

  Future<void> _onPublishMarks(
    PublishMarks event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherMarksSaving());
    try {
      await _repository.publishMarks(event.examId);
      emit(const TeacherMarksSaved('Marks published successfully.'));
    } catch (e) {
      emit(const TeacherError('Failed to publish marks.'));
    }
  }

  Future<void> _onCheckIn(
    PerformCheckIn event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherCheckInLoading());
    try {
      if (_attendanceRepository != null) {
        await _attendanceRepository.checkIn(
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
          selfieImage: event.selfieFile,
        );
        add(LoadTeacherAttendance());
      } else {
        await Future.delayed(const Duration(milliseconds: 1500));
      }
      emit(const TeacherCheckInSuccess(true));
    } catch (e) {
      emit(TeacherCheckInError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCheckOut(
    PerformCheckOut event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherCheckInLoading());
    try {
      if (_attendanceRepository != null) {
        await _attendanceRepository.checkOut(
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
        );
        add(LoadTeacherAttendance());
      } else {
        await Future.delayed(const Duration(milliseconds: 1500));
      }
      emit(const TeacherCheckInSuccess(false));
    } catch (e) {
      emit(TeacherCheckInError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadSchedule(
    LoadTeacherSchedule event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherScheduleLoading());
    try {
      if (_timetableRepository != null) {
        final timetable = await _timetableRepository.getTodayTimetable();
        if (timetable.periods.isNotEmpty) {
          final now = DateTime.now();
          final schedules = timetable.periods.map((p) {
            return ScheduleModel(
              id: p.id,
              subject: p.subjectName,
              className: p.className,
              section: p.roomName.isNotEmpty ? p.roomName : 'Room 1',
              startTime: now,
              endTime: now.add(const Duration(minutes: 45)),
            );
          }).toList();
          emit(TeacherScheduleLoaded(schedules));
          return;
        }
      }
      final schedule = await _repository.getTodaySchedule();
      emit(TeacherScheduleLoaded(schedule));
    } catch (e) {
      emit(const TeacherError('Failed to load schedule.'));
    }
  }

  Future<void> _onLoadNotificationCount(
    LoadNotificationCount event,
    Emitter<TeacherState> emit,
  ) async {
    try {
      if (_notificationRepository != null) {
        final res = await _notificationRepository.getNotifications(
          page: 1,
          limit: 1,
        );
        emit(TeacherNotificationCountLoaded(res.unreadCount));
        return;
      }
      final count = await _repository.getNotificationCount();
      emit(TeacherNotificationCountLoaded(count));
    } catch (_) {
      emit(const TeacherNotificationCountLoaded(0));
    }
  }

  Future<void> _onBroadcastAnnouncement(
    BroadcastAnnouncementEvent event,
    Emitter<TeacherState> emit,
  ) async {
    try {
      if (_notificationRepository != null) {
        await _notificationRepository.broadcastAnnouncement(
          title: event.title,
          message: event.message,
          category: event.category,
          schoolId: event.schoolId,
        );
        add(LoadNotificationCount());
        add(const LoadTeacherNotifications());
      }
    } catch (_) {}
  }

  Future<void> _onLoadTeacherNotifications(
    LoadTeacherNotifications event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherNotificationsLoading());
    try {
      if (_notificationRepository != null) {
        final res = await _notificationRepository.getNotifications(
          onlyUnread: event.onlyUnread,
          category: event.category,
        );
        emit(TeacherNotificationsLoaded(
          res.notifications,
          unreadCount: res.unreadCount,
        ));
        return;
      }
      emit(const TeacherNotificationsLoaded([]));
    } catch (e) {
      emit(TeacherNotificationsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMarkTeacherNotificationAsRead(
    MarkTeacherNotificationAsRead event,
    Emitter<TeacherState> emit,
  ) async {
    try {
      if (_notificationRepository != null) {
        await _notificationRepository.markAsRead(event.notificationId);
        add(const LoadTeacherNotifications());
        add(LoadNotificationCount());
      }
    } catch (_) {}
  }

  Future<void> _onMarkAllTeacherNotificationsAsRead(
    MarkAllTeacherNotificationsAsRead event,
    Emitter<TeacherState> emit,
  ) async {
    try {
      if (_notificationRepository != null) {
        await _notificationRepository.markAllAsRead();
        add(const LoadTeacherNotifications());
        add(LoadNotificationCount());
      }
    } catch (_) {}
  }

  Future<void> _onSubmitCorrection(
    SubmitAttendanceCorrection event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherMarksSaving());
    try {
      await _repository.submitAttendanceCorrection(
        event.attendanceId,
        event.reason,
      );
      emit(const TeacherMarksSaved('Correction request submitted.'));
    } catch (e) {
      emit(const TeacherError('Failed to submit correction request.'));
    }
  }

  // ────────────────────── WEEKLY TIMETABLE ──────────────────────

  Future<void> _onLoadWeeklySchedule(
    LoadTeacherWeeklySchedule event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherWeeklyScheduleLoading());
    try {
      final week = await _repository.getWeeklySchedule();
      emit(TeacherWeeklyScheduleLoaded(week));
    } catch (e) {
      emit(const TeacherError('Failed to load weekly schedule.'));
    }
  }

  // ────────────────────── ACADEMIC CALENDAR ─────────────────────

  Future<void> _onLoadCalendar(
    LoadTeacherCalendar event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherCalendarLoading());
    try {
      if (_calendarRepository != null) {
        final events = await _calendarRepository.getEvents();
        emit(TeacherCalendarLoaded(events));
        return;
      }
      final events = await _repository.getAcademicCalendar();
      emit(TeacherCalendarLoaded(events));
    } catch (e) {
      emit(const TeacherError('Failed to load academic calendar.'));
    }
  }

  // ─────────────────────────── ANALYTICS ────────────────────────

  Future<void> _onLoadAnalytics(
    LoadTeacherAnalytics event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherAnalyticsLoading());
    try {
      final analytics = await _repository.getTeacherAnalytics();
      emit(TeacherAnalyticsLoaded(analytics));
    } catch (e) {
      emit(const TeacherError('Failed to load analytics.'));
    }
  }

  // ──────────────────── LATE CHECK-IN COMMENT ───────────────────

  Future<void> _onAddLateComment(
    AddLateCheckInComment event,
    Emitter<TeacherState> emit,
  ) async {
    try {
      await _repository.addLateCheckInComment(
        event.attendanceId,
        event.comment,
      );
      emit(const TeacherLateCommentSaved('Comment added to late check-in.'));
    } catch (e) {
      emit(const TeacherError('Failed to save comment.'));
    }
  }

  // ───────────────────────────── LEAVE ──────────────────────────

  Future<void> _onLoadLeaves(
    LoadTeacherLeaveApplications event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLeaveLoading());
    try {
      final applications = await _repository.getLeaveApplications();
      emit(TeacherLeaveLoaded(applications));
    } catch (e) {
      emit(const TeacherLeaveError('Failed to load leave applications.'));
    }
  }

  Future<void> _onSubmitLeave(
    SubmitTeacherLeaveApplication event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLeaveSubmitting());
    try {
      await _repository.submitLeaveApplication(event.application);
      final applications = await _repository.getLeaveApplications();
      emit(TeacherLeaveLoaded(applications, justSubmitted: true));
    } catch (e) {
      emit(const TeacherLeaveError('Failed to submit leave application.'));
    }
  }

  Future<void> _onCancelLeave(
    CancelTeacherLeaveApplication event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLeaveSubmitting());
    try {
      await _repository.cancelLeaveApplication(event.leaveId);
      final applications = await _repository.getLeaveApplications();
      emit(TeacherLeaveLoaded(applications));
    } catch (e) {
      emit(const TeacherLeaveError('Failed to cancel leave application.'));
    }
  }
}
