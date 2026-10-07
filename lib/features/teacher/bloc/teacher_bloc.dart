import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/models/user_model.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/marks_model.dart';
import '../../auth/models/notification_model.dart';
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

// Notification count
class TeacherNotificationCountLoaded extends TeacherState {
  final int count;
  const TeacherNotificationCountLoaded(this.count);
  @override
  List<Object?> get props => [count];
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
class PerformCheckIn extends TeacherEvent {}
class PerformCheckOut extends TeacherEvent {}
class LoadTeacherSchedule extends TeacherEvent {}
class LoadNotificationCount extends TeacherEvent {}
class SubmitAttendanceCorrection extends TeacherEvent {
  final String attendanceId;
  final String reason;
  const SubmitAttendanceCorrection(this.attendanceId, this.reason);
  @override
  List<Object?> get props => [attendanceId, reason];
}

// --- BLoC ---
class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final MockTeacherRepository _repository;

  TeacherBloc({MockTeacherRepository? repository})
      : _repository = repository ?? MockTeacherRepository(),
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
      // Mock GPS + face verification
      await Future.delayed(const Duration(milliseconds: 2000));
      emit(const TeacherCheckInSuccess(true));
    } catch (e) {
      emit(TeacherCheckInError(e.toString()));
    }
  }

  Future<void> _onCheckOut(
    PerformCheckOut event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherCheckInLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(const TeacherCheckInSuccess(false));
    } catch (e) {
      emit(TeacherCheckInError(e.toString()));
    }
  }

  Future<void> _onLoadSchedule(
    LoadTeacherSchedule event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherScheduleLoading());
    try {
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
      final count = await _repository.getNotificationCount();
      emit(TeacherNotificationCountLoaded(count));
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
}
