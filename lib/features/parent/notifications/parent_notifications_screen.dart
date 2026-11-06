import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/parent_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';
import '../../auth/models/notification_model.dart';

class ParentNotificationsScreen extends StatefulWidget {
  const ParentNotificationsScreen({super.key});

  @override
  State<ParentNotificationsScreen> createState() =>
      _ParentNotificationsScreenState();
}

class _ParentNotificationsScreenState
    extends State<ParentNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ParentBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Alerts & updates',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, size: 20),
            tooltip: 'Mark all as read',
            onPressed: () {
              context.read<ParentBloc>().add(const MarkAllNotificationsAsRead());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marked all as read')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ParentBloc, ParentState>(
        buildWhen: (_, state) =>
            state is ParentNotificationsLoaded ||
            state is ParentNotificationsLoading ||
            state is ParentError,
        builder: (context, state) {
          if (state is ParentNotificationsLoading) {
            return const ShimmerLoading(itemCount: 8, itemHeight: 80);
          }
          if (state is ParentError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ParentBloc>().add(const LoadNotifications());
              },
            );
          }
          if (state is ParentNotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyStateWidget(
                message: 'No notifications yet',
                subtitle: "You're all caught up with campus updates.",
                icon: Icons.notifications_none_rounded,
              );
            }

            final grouped = <String, List<NotificationModel>>{};
            for (final n in state.notifications) {
              final key = DateFormatter.formatDate(n.date);
              grouped.putIfAbsent(key, () => []).add(n);
            }

            return RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () async {
                context.read<ParentBloc>().add(const LoadNotifications());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final date = grouped.keys.elementAt(index);
                  final notifications = grouped[date]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 12),
                        child: Text(
                          date,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ),
                      ...notifications.map((n) =>
                          _NotificationTile(notification: n)),
                    ],
                  );
                },
              ),
            );
          }
          return const ShimmerLoading(itemCount: 8, itemHeight: 80);
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.dangerBorder, width: 1),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      onDismissed: (_) {
        context.read<ParentBloc>().add(MarkNotificationAsRead(notification.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification marked as read')),
        );
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context.read<ParentBloc>().add(MarkNotificationAsRead(notification.id));
          }
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.surface : AppColors.surfaceInset,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: notification.isRead ? AppColors.border : AppColors.accent,
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: AppShadows.subtle,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInset,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Icon(
                  _typeIcon(notification.type),
                  color: _typeColor(notification.type),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.poppins(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatTime(notification.date),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.absence:
        return AppColors.danger;
      case NotificationType.resultDeclared:
        return AppColors.success;
      case NotificationType.event:
        return AppColors.accent;
      case NotificationType.announcement:
        return AppColors.accent;
      case NotificationType.feeDue:
        return AppColors.warning;
      case NotificationType.ptm:
        return AppColors.accent;
    }
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.absence:
        return Icons.person_off_outlined;
      case NotificationType.resultDeclared:
        return Icons.assignment_turned_in_outlined;
      case NotificationType.event:
        return Icons.event_outlined;
      case NotificationType.announcement:
        return Icons.campaign_outlined;
      case NotificationType.feeDue:
        return Icons.payments_outlined;
      case NotificationType.ptm:
        return Icons.groups_outlined;
    }
  }
}
