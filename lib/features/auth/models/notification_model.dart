import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String notificationId;
  final String title;
  final String message;
  final DateTime date;
  final NotificationType type;
  final bool isRead;
  final String category;
  final String priority;
  final String? actionUrl;
  final String? createdByName;
  final String? createdByRole;
  final bool isCreatedByMe;

  const NotificationModel({
    required this.id,
    this.notificationId = '',
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.isRead = false,
    this.category = 'ANNOUNCEMENT',
    this.priority = 'NORMAL',
    this.actionUrl,
    this.createdByName,
    this.createdByRole,
    this.isCreatedByMe = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return NotificationModel(
        id: '',
        title: '',
        message: '',
        date: DateTime.now(),
        type: NotificationType.announcement,
      );
    }

    final rawCat = json['category']?.toString().toUpperCase() ?? '';
    NotificationType nType;
    switch (rawCat) {
      case 'FEE_REMINDER':
      case 'FEES':
        nType = NotificationType.feeDue;
        break;
      case 'ABSENCE':
      case 'ATTENDANCE':
        nType = NotificationType.absence;
        break;
      case 'RESULT':
      case 'MARKS':
        nType = NotificationType.resultDeclared;
        break;
      case 'EVENT':
        nType = NotificationType.event;
        break;
      case 'PTM':
        nType = NotificationType.ptm;
        break;
      default:
        nType = NotificationType.announcement;
    }

    final rawDate = json['createdAt'] ?? json['date'];
    final parsedDate = rawDate != null
        ? (DateTime.tryParse(rawDate.toString()) ?? DateTime.now())
        : DateTime.now();

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      notificationId: json['notificationId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      date: parsedDate,
      type: nType,
      isRead: json['isRead'] == true,
      category: rawCat,
      priority: json['priority']?.toString() ?? 'NORMAL',
      actionUrl: json['actionUrl']?.toString(),
      createdByName: json['createdByName']?.toString(),
      createdByRole: json['createdByRole']?.toString(),
      isCreatedByMe: json['isCreatedByMe'] == true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        notificationId,
        title,
        message,
        date,
        type,
        isRead,
        category,
        priority,
        actionUrl,
        createdByName,
        createdByRole,
        isCreatedByMe,
      ];

  NotificationModel copyWith({
    String? id,
    String? notificationId,
    String? title,
    String? message,
    DateTime? date,
    NotificationType? type,
    bool? isRead,
    String? category,
    String? priority,
    String? actionUrl,
    String? createdByName,
    String? createdByRole,
    bool? isCreatedByMe,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      actionUrl: actionUrl ?? this.actionUrl,
      createdByName: createdByName ?? this.createdByName,
      createdByRole: createdByRole ?? this.createdByRole,
      isCreatedByMe: isCreatedByMe ?? this.isCreatedByMe,
    );
  }
}

class NotificationListResponseModel extends Equatable {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const NotificationListResponseModel({
    required this.notifications,
    this.unreadCount = 0,
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 1,
  });

  factory NotificationListResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const NotificationListResponseModel(notifications: []);
    }

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final nList = <NotificationModel>[];
    if (data['notifications'] is List) {
      for (final item in data['notifications']) {
        if (item is Map<String, dynamic>) {
          nList.add(NotificationModel.fromJson(item));
        }
      }
    }

    final pag = data['pagination'] is Map<String, dynamic>
        ? data['pagination'] as Map<String, dynamic>
        : {};

    return NotificationListResponseModel(
      notifications: nList,
      unreadCount: (data['unreadCount'] is num)
          ? (data['unreadCount'] as num).toInt()
          : 0,
      page: (pag['page'] is num) ? (pag['page'] as num).toInt() : 1,
      limit: (pag['limit'] is num) ? (pag['limit'] as num).toInt() : 20,
      total: (pag['total'] is num) ? (pag['total'] as num).toInt() : nList.length,
      totalPages:
          (pag['totalPages'] is num) ? (pag['totalPages'] as num).toInt() : 1,
    );
  }

  @override
  List<Object?> get props =>
      [notifications, unreadCount, page, limit, total, totalPages];
}

enum NotificationType {
  absence,
  resultDeclared,
  event,
  announcement,
  feeDue,
  ptm,
}

class ScheduleModel extends Equatable {
  final String id;
  final String subject;
  final String className;
  final String section;
  final DateTime startTime;
  final DateTime endTime;

  const ScheduleModel({
    required this.id,
    required this.subject,
    required this.className,
    required this.section,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [id, subject, className, section, startTime, endTime];
}
