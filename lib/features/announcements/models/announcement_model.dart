import 'package:equatable/equatable.dart';

/// Single Announcement Item Model with zero-null safety
class AnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final List<String> recipient;
  final String senderName;
  final String senderRole;
  final dynamic schoolId;
  final DateTime createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    this.recipient = const [],
    this.senderName = 'Campus Administration',
    this.senderRole = 'Administrator',
    this.schoolId,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AnnouncementModel(
        id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Campus Notice',
        message: 'No description provided.',
        recipient: const ['parents', 'teachers'],
        createdAt: DateTime.now(),
      );
    }

    // Recipients list parsing
    final List<String> recipients = [];
    if (json['recipient'] is List) {
      for (final r in json['recipient']) {
        if (r != null) {
          recipients.add(r.toString());
        }
      }
    } else if (json['recipient'] is String) {
      recipients.add(json['recipient'] as String);
    } else if (json['recipients'] is List) {
      for (final r in json['recipients']) {
        if (r != null) {
          recipients.add(r.toString());
        }
      }
    }

    // Sender resolution
    String senderName = 'Campus Administration';
    String senderRole = 'Administrator';
    if (json['sender'] is Map<String, dynamic>) {
      final s = json['sender'] as Map<String, dynamic>;
      final firstName = s['firstName']?.toString() ?? '';
      final lastName = s['lastName']?.toString() ?? '';
      final fullName = '$firstName $lastName'.trim();
      senderName = fullName.isNotEmpty
          ? fullName
          : (s['name']?.toString() ?? 'Campus Administration');
      senderRole = s['role']?.toString() ?? 'Administrator';
    } else if (json['senderName'] != null) {
      senderName = json['senderName'].toString();
      senderRole = json['senderRole']?.toString() ?? 'Administrator';
    } else if (json['createdBy'] is Map<String, dynamic>) {
      final c = json['createdBy'] as Map<String, dynamic>;
      senderName = c['name']?.toString() ?? 'Teacher';
      senderRole = c['role']?.toString() ?? 'Teacher';
    }

    // Created date
    DateTime parsedDate;
    try {
      final dateRaw = json['createdAt'] ?? json['date'] ?? json['created_at'];
      parsedDate = dateRaw != null
          ? DateTime.parse(dateRaw.toString()).toLocal()
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return AnnouncementModel(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          'ann_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Campus Announcement',
      message: json['message']?.toString() ??
          json['description']?.toString() ??
          json['content']?.toString() ??
          '',
      recipient: recipients.isNotEmpty ? recipients : const ['all'],
      senderName: senderName,
      senderRole: senderRole,
      schoolId: json['schoolId'] ?? json['school_id'],
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'recipient': recipient,
      'senderName': senderName,
      'senderRole': senderRole,
      'schoolId': schoolId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        recipient,
        senderName,
        senderRole,
        schoolId,
        createdAt,
      ];
}

/// Paginated announcements response model
class AnnouncementListResponseModel extends Equatable {
  final List<AnnouncementModel> announcements;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;

  const AnnouncementListResponseModel({
    required this.announcements,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory AnnouncementListResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AnnouncementListResponseModel(
        announcements: [],
        page: 1,
        limit: 10,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
      );
    }

    // Unwrap envelope if present
    dynamic payload = json;
    if (json.containsKey('data') && json['data'] != null) {
      payload = json['data'];
    }

    List<AnnouncementModel> list = [];
    if (payload is List) {
      list = payload
          .map((item) => AnnouncementModel.fromJson(
              item is Map<String, dynamic> ? item : null))
          .toList();
    } else if (payload is Map<String, dynamic>) {
      final rawList = payload['announcements'] ??
          payload['items'] ??
          payload['results'] ??
          payload['data'];
      if (rawList is List) {
        list = rawList
            .map((item) => AnnouncementModel.fromJson(
                item is Map<String, dynamic> ? item : null))
            .toList();
      }
    }

    // Metadata extraction
    Map<String, dynamic>? meta;
    if (json['meta'] is Map<String, dynamic>) {
      meta = json['meta'] as Map<String, dynamic>;
    } else if (json['pagination'] is Map<String, dynamic>) {
      meta = json['pagination'] as Map<String, dynamic>;
    } else if (payload is Map<String, dynamic> &&
        payload['meta'] is Map<String, dynamic>) {
      meta = payload['meta'] as Map<String, dynamic>;
    }

    final page = int.tryParse(meta?['page']?.toString() ??
            json['page']?.toString() ??
            (payload is Map ? payload['page']?.toString() ?? '1' : '1')) ??
        1;

    final limit = int.tryParse(meta?['limit']?.toString() ??
            json['limit']?.toString() ??
            (payload is Map ? payload['limit']?.toString() ?? '10' : '10')) ??
        10;

    final total = int.tryParse(meta?['total']?.toString() ??
            json['total']?.toString() ??
            (payload is Map ? payload['total']?.toString() ?? '' : '')) ??
        list.length;

    final totalPages = int.tryParse(meta?['totalPages']?.toString() ??
            json['totalPages']?.toString() ??
            '') ??
        (total > 0 ? (total / limit).ceil() : 1);

    final hasNext = meta?['hasNextPage'] == true ||
        meta?['hasNext'] == true ||
        (page < totalPages) ||
        (list.length >= limit && total > list.length);

    return AnnouncementListResponseModel(
      announcements: list,
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      hasNextPage: hasNext,
    );
  }

  @override
  List<Object?> get props => [
        announcements,
        page,
        limit,
        total,
        totalPages,
        hasNextPage,
      ];
}

