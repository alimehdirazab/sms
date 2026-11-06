import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/announcement_model.dart';
import '../repositories/announcement_repository.dart';

// --- States ---
abstract class AnnouncementState extends Equatable {
  const AnnouncementState();

  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {
  const AnnouncementInitial();
}

class AnnouncementLoading extends AnnouncementState {
  const AnnouncementLoading();
}

class AnnouncementLoaded extends AnnouncementState {
  final List<AnnouncementModel> announcements;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final int total;

  const AnnouncementLoaded({
    required this.announcements,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.total = 0,
  });

  AnnouncementLoaded copyWith({
    List<AnnouncementModel>? announcements,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    int? total,
  }) {
    return AnnouncementLoaded(
      announcements: announcements ?? this.announcements,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
        announcements,
        currentPage,
        hasMore,
        isLoadingMore,
        total,
      ];
}

class AnnouncementError extends AnnouncementState {
  final String message;

  const AnnouncementError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnnouncementCreating extends AnnouncementState {
  const AnnouncementCreating();
}

class AnnouncementCreatedSuccess extends AnnouncementState {
  final AnnouncementModel announcement;

  const AnnouncementCreatedSuccess(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementCreateError extends AnnouncementState {
  final String message;

  const AnnouncementCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Events ---
abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnnouncements extends AnnouncementEvent {
  final bool refresh;
  final int limit;

  const LoadAnnouncements({this.refresh = false, this.limit = 10});

  @override
  List<Object?> get props => [refresh, limit];
}

class LoadMoreAnnouncements extends AnnouncementEvent {
  const LoadMoreAnnouncements();
}

class CreateAnnouncementRequested extends AnnouncementEvent {
  final String title;
  final String message;
  final List<String> recipient;

  const CreateAnnouncementRequested({
    required this.title,
    required this.message,
    required this.recipient,
  });

  @override
  List<Object?> get props => [title, message, recipient];
}

// --- BLoC ---
class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository repository;
  static const int _defaultPageLimit = 10;

  AnnouncementBloc({required this.repository})
      : super(const AnnouncementInitial()) {
    on<LoadAnnouncements>(_onLoadAnnouncements);
    on<LoadMoreAnnouncements>(_onLoadMoreAnnouncements);
    on<CreateAnnouncementRequested>(_onCreateAnnouncement);
  }

  Future<void> _onLoadAnnouncements(
    LoadAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    if (!event.refresh && state is! AnnouncementLoaded) {
      emit(const AnnouncementLoading());
    }

    try {
      final res = await repository.getAnnouncements(
        page: 1,
        limit: event.limit,
      );

      emit(AnnouncementLoaded(
        announcements: res.announcements,
        currentPage: 1,
        hasMore: res.hasNextPage,
        total: res.total,
      ));
    } catch (e) {
      emit(AnnouncementError(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadMoreAnnouncements(
    LoadMoreAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AnnouncementLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final res = await repository.getAnnouncements(
        page: nextPage,
        limit: _defaultPageLimit,
      );

      final combined = List<AnnouncementModel>.from(currentState.announcements)
        ..addAll(res.announcements);

      emit(AnnouncementLoaded(
        announcements: combined,
        currentPage: nextPage,
        hasMore: res.hasNextPage,
        isLoadingMore: false,
        total: res.total,
      ));
    } catch (e) {
      // Revert loading more flag without wiping current announcements
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onCreateAnnouncement(
    CreateAnnouncementRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementCreating());
    try {
      final newAnnouncement = await repository.createAnnouncement(
        title: event.title,
        message: event.message,
        recipient: event.recipient,
      );

      emit(AnnouncementCreatedSuccess(newAnnouncement));

      // Refresh announcements list to show the newly created item
      add(const LoadAnnouncements(refresh: true));
    } catch (e) {
      emit(AnnouncementCreateError(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}

