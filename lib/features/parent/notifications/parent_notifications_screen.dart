import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/parent_bloc.dart';
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
    context.read<ParentBloc>().add(LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
                context.read<ParentBloc>().add(LoadNotifications());
              },
            );
          }
          if (state is ParentNotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyStateWidget(
                message: 'No notifications yet.',
                icon: Icons.notifications_none,
              );
            }

            // Group by date
            final grouped = <String, List<NotificationModel>>{};
            for (final n in state.notifications) {
              final key = DateFormatter.formatDate(n.date);
              grouped.putIfAbsent(key, () => []).add(n);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ParentBloc>().add(LoadNotifications());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final date = grouped.keys.elementAt(index);
                  final notifications = grouped[date]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        child: Text(
                          date,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                        ),
                      ),
                      ...notifications.map((n) =>
                          _NotificationTile(notification: n)),
                      const SizedBox(height: 8),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification dismissed')),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _typeColor(notification.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _typeIcon(notification.type),
              color: _typeColor(notification.type),
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatTime(notification.date),
                style: TextStyle(
                    fontSize: 11, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.absence:
        return Colors.red;
      case NotificationType.resultDeclared:
        return Colors.green;
      case NotificationType.event:
        return Colors.blue;
      case NotificationType.announcement:
        return Colors.purple;
      case NotificationType.feeDue:
        return Colors.orange;
      case NotificationType.ptm:
        return Colors.teal;
    }
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.absence:
        return Icons.person_off;
      case NotificationType.resultDeclared:
        return Icons.assignment_turned_in;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.feeDue:
        return Icons.payment;
      case NotificationType.ptm:
        return Icons.groups;
    }
  }
}
