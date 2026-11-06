import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/leave_api_model.dart';
import '../repositories/leave_repository.dart';

// --- States ---
abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object?> get props => [];
}

class LeaveInitial extends LeaveState {
  const LeaveInitial();
}

class LeaveLoading extends LeaveState {
  const LeaveLoading();
}

class LeaveLoaded extends LeaveState {
  final List<LeaveItemModel> leaves;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final LeaveStatus currentStatusFilter;
  final String? activeStudentId;
  final bool isSubmitting;
  final String? actionSuccessMessage;
  final String? actionErrorMessage;

  const LeaveLoaded({
    required this.leaves,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.currentStatusFilter,
    this.activeStudentId,
    this.isSubmitting = false,
    this.actionSuccessMessage,
    this.actionErrorMessage,
  });

  LeaveLoaded copyWith({
    List<LeaveItemModel>? leaves,
    int? totalCount,
    int? currentPage,
    int? totalPages,
    bool? hasNextPage,
    LeaveStatus? currentStatusFilter,
    String? activeStudentId,
    bool? isSubmitting,
    String? actionSuccessMessage,
    String? actionErrorMessage,
  }) {
    return LeaveLoaded(
      leaves: leaves ?? this.leaves,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentStatusFilter: currentStatusFilter ?? this.currentStatusFilter,
      activeStudentId: activeStudentId ?? this.activeStudentId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionSuccessMessage: actionSuccessMessage,
      actionErrorMessage: actionErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        leaves,
        totalCount,
        currentPage,
        totalPages,
        hasNextPage,
        currentStatusFilter,
        activeStudentId,
        isSubmitting,
        actionSuccessMessage,
        actionErrorMessage,
      ];
}

class LeaveError extends LeaveState {
  final String message;

  const LeaveError({required this.message});

  @override
  List<Object?> get props => [message];
}

// --- Events ---
abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeavesRequested extends LeaveEvent {
  final LeaveStatus status;
  final int page;
  final String? applicantType;
  final String? studentId;
  final String? search;

  const LoadLeavesRequested({
    this.status = LeaveStatus.unknown,
    this.page = 1,
    this.applicantType,
    this.studentId,
    this.search,
  });

  @override
  List<Object?> get props => [status, page, applicantType, studentId, search];
}

class CreateTeacherLeaveRequested extends LeaveEvent {
  final String leaveType;
  final String startDate;
  final String endDate;
  final String description;
  final String? attachment;

  const CreateTeacherLeaveRequested({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.attachment,
  });

  @override
  List<Object?> get props => [leaveType, startDate, endDate, description, attachment];
}

class CreateParentLeaveRequested extends LeaveEvent {
  final String leaveType;
  final String startDate;
  final String endDate;
  final String description;
  final String? studentId;
  final String? attachment;

  const CreateParentLeaveRequested({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.studentId,
    this.attachment,
  });

  @override
  List<Object?> get props => [
        leaveType,
        startDate,
        endDate,
        description,
        studentId,
        attachment,
      ];
}

class UpdateLeaveStatusRequested extends LeaveEvent {
  final String leaveId;
  final String status; // 'APPROVED' or 'REJECTED'
  final String reason;

  const UpdateLeaveStatusRequested({
    required this.leaveId,
    required this.status,
    required this.reason,
  });

  @override
  List<Object?> get props => [leaveId, status, reason];
}

class DeleteLeaveRequested extends LeaveEvent {
  final String leaveId;

  const DeleteLeaveRequested({required this.leaveId});

  @override
  List<Object?> get props => [leaveId];
}

// --- BLoC ---
class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository leaveRepository;

  LeaveBloc({required this.leaveRepository}) : super(const LeaveInitial()) {
    on<LoadLeavesRequested>(_onLoadLeaves);
    on<CreateTeacherLeaveRequested>(_onCreateTeacherLeave);
    on<CreateParentLeaveRequested>(_onCreateParentLeave);
    on<UpdateLeaveStatusRequested>(_onUpdateLeaveStatus);
    on<DeleteLeaveRequested>(_onDeleteLeave);
  }

  Future<void> _onLoadLeaves(
    LoadLeavesRequested event,
    Emitter<LeaveState> emit,
  ) async {
    final currentState = state;
    if (event.page == 1) {
      emit(const LeaveLoading());
    }

    try {
      final statusParam = event.status == LeaveStatus.unknown
          ? null
          : event.status.toApiString();

      final result = await leaveRepository.getLeaves(
        status: statusParam,
        page: event.page,
        applicantType: event.applicantType,
        studentId: event.studentId,
        search: event.search,
      );

      emit(LeaveLoaded(
        leaves: result.items,
        totalCount: result.totalCount,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        hasNextPage: result.hasNextPage,
        currentStatusFilter: event.status,
        activeStudentId: event.studentId,
      ));
    } catch (e) {
      if (currentState is LeaveLoaded && event.page > 1) {
        emit(currentState.copyWith(
          actionSuccessMessage: null,
          actionErrorMessage: null,
        ));
      } else {
        emit(LeaveError(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> _onCreateTeacherLeave(
    CreateTeacherLeaveRequested event,
    Emitter<LeaveState> emit,
  ) async {
    final currentState = state;
    if (currentState is LeaveLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
    } else {
      emit(const LeaveLoading());
    }

    try {
      await leaveRepository.createTeacherLeave(
        leaveType: event.leaveType,
        startDate: event.startDate,
        endDate: event.endDate,
        description: event.description,
        attachment: event.attachment,
      );

      if (currentState is LeaveLoaded) {
        emit(currentState.copyWith(
          isSubmitting: false,
          actionSuccessMessage: 'Leave application submitted successfully',
        ));
      }

      // Re-fetch leaves on success
      add(const LoadLeavesRequested(applicantType: 'TEACHER'));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (currentState is LeaveLoaded) {
        emit(currentState.copyWith(
          isSubmitting: false,
          actionErrorMessage: errorMsg,
        ));
      } else {
        emit(LeaveError(message: errorMsg));
      }
    }
  }

  Future<void> _onCreateParentLeave(
    CreateParentLeaveRequested event,
    Emitter<LeaveState> emit,
  ) async {
    final currentState = state;
    if (currentState is LeaveLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
    } else {
      emit(const LeaveLoading());
    }

    try {
      await leaveRepository.createParentLeave(
        leaveType: event.leaveType,
        startDate: event.startDate,
        endDate: event.endDate,
        description: event.description,
        studentId: event.studentId,
        attachment: event.attachment,
      );

      if (currentState is LeaveLoaded) {
        emit(currentState.copyWith(
          isSubmitting: false,
          actionSuccessMessage: 'Student leave application submitted successfully',
        ));
      }

      // Re-fetch leaves on success
      add(LoadLeavesRequested(
        applicantType: 'STUDENT',
        studentId: event.studentId,
      ));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (currentState is LeaveLoaded) {
        emit(currentState.copyWith(
          isSubmitting: false,
          actionErrorMessage: errorMsg,
        ));
      } else {
        emit(LeaveError(message: errorMsg));
      }
    }
  }

  Future<void> _onUpdateLeaveStatus(
    UpdateLeaveStatusRequested event,
    Emitter<LeaveState> emit,
  ) async {
    final currentState = state;
    if (currentState is LeaveLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
    }

    try {
      await leaveRepository.updateLeaveStatus(
        leaveId: event.leaveId,
        status: event.status,
        reason: event.reason,
      );

      if (currentState is LeaveLoaded) {
        emit(currentState.copyWith(
          isSubmitting: false,
          actionSuccessMessage: 'Leave status updated successfully',
        ));
      }

      // Refresh list
      final currentFilter = currentState is LeaveLoaded
          ? currentState.currentStatusFilter
          : LeaveStatus.unknown;
      add(LoadLeavesRequested(status: currentFilter));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (currentState is LeaveLoaded) {
        emit(currentState.copyWith(
          isSubmitting: false,
          actionErrorMessage: errorMsg,
        ));
      } else {
        emit(LeaveError(message: errorMsg));
      }
    }
  }

  Future<void> _onDeleteLeave(
    DeleteLeaveRequested event,
    Emitter<LeaveState> emit,
  ) async {
    final currentState = state;
    if (currentState is LeaveLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
    }

    try {
      await leaveRepository.deleteLeave(event.leaveId);
      if (currentState is LeaveLoaded) {
        emit(currentState.copyWith(
          isSubmitting: false,
          actionSuccessMessage: 'Leave application deleted',
        ));
      }
      final currentFilter = currentState is LeaveLoaded
          ? currentState.currentStatusFilter
          : LeaveStatus.unknown;
      add(LoadLeavesRequested(status: currentFilter));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (currentState is LeaveLoaded) {
        emit(currentState.copyWith(
          isSubmitting: false,
          actionErrorMessage: errorMsg,
        ));
      } else {
        emit(LeaveError(message: errorMsg));
      }
    }
  }
}
