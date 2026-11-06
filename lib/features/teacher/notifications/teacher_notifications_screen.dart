import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/notification_model.dart';

class TeacherNotificationsScreen extends StatefulWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  State<TeacherNotificationsScreen> createState() =>
      _TeacherNotificationsScreenState();
}

class _TeacherNotificationsScreenState
    extends State<TeacherNotificationsScreen> {
  bool _onlyUnread = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<TeacherBloc>().add(
          LoadTeacherNotifications(onlyUnread: _onlyUnread),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Campus notices',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined, size: 22),
            tooltip: 'Broadcast announcement',
            onPressed: () => _showBroadcastDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.done_all_rounded, size: 20),
            tooltip: 'Mark all as read',
            onPressed: () {
              context
                  .read<TeacherBloc>()
                  .add(const MarkAllTeacherNotificationsAsRead());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marked all as read')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.campaign_outlined, size: 20),
        label: Text(
          'New broadcast',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => _showBroadcastDialog(context),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocBuilder<TeacherBloc, TeacherState>(
              buildWhen: (_, state) =>
                  state is TeacherNotificationsLoaded ||
                  state is TeacherNotificationsLoading ||
                  state is TeacherNotificationsError,
              builder: (context, state) {
                if (state is TeacherNotificationsLoading) {
                  return const ShimmerLoading(itemCount: 8, itemHeight: 80);
                }

                if (state is TeacherNotificationsError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: _fetch,
                  );
                }

                if (state is TeacherNotificationsLoaded) {
                  if (state.notifications.isEmpty) {
                    return EmptyStateWidget(
                      message: _onlyUnread
                          ? 'No unread notifications'
                          : 'No notifications yet',
                      subtitle: _onlyUnread
                          ? 'You are all caught up with urgent updates.'
                          : 'Campus alerts, announcements, and notices will appear here.',
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
                    onRefresh: () async => _fetch(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
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
                            ...notifications.map(
                              (n) => _TeacherNotificationTile(notification: n),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }

                return const ShimmerLoading(itemCount: 8, itemHeight: 80);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All notices'),
            selected: !_onlyUnread,
            onSelected: (val) {
              if (val && _onlyUnread) {
                setState(() => _onlyUnread = false);
                _fetch();
              }
            },
            selectedColor: AppColors.accent.withValues(alpha: 0.12),
            labelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: !_onlyUnread ? AppColors.accent : AppColors.inkMuted,
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Unread only'),
            selected: _onlyUnread,
            onSelected: (val) {
              if (val != _onlyUnread) {
                setState(() => _onlyUnread = val);
                _fetch();
              }
            },
            selectedColor: AppColors.accent.withValues(alpha: 0.12),
            labelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _onlyUnread ? AppColors.accent : AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String category = 'ANNOUNCEMENT';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Broadcast announcement',
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 22,
                        fontWeight: FontWeight.normal,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Send an official campus notice to students and parents.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ANNOUNCEMENT',
                          child: Text('Announcement'),
                        ),
                        DropdownMenuItem(
                          value: 'ACADEMIC',
                          child: Text('Academic update'),
                        ),
                        DropdownMenuItem(
                          value: 'EVENT',
                          child: Text('Campus event'),
                        ),
                        DropdownMenuItem(
                          value: 'EMERGENCY',
                          child: Text('Urgent notice'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => category = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Midterm revision schedule',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Message body',
                        hintText: 'Enter announcement details...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBouncyButton(
                      label: 'Send broadcast',
                      onPressed: () {
                        final title = titleController.text.trim();
                        final message = messageController.text.trim();
                        if (title.isEmpty || message.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in title and message.'),
                            ),
                          );
                          return;
                        }

                        Navigator.of(ctx).pop();
                        context.read<TeacherBloc>().add(
                              BroadcastAnnouncementEvent(
                                title: title,
                                message: message,
                                category: category,
                                schoolId: 1,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Announcement broadcasted successfully.'),
                            backgroundColor: AppColors.accent,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TeacherNotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _TeacherNotificationTile({required this.notification});

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
        context
            .read<TeacherBloc>()
            .add(MarkTeacherNotificationAsRead(notification.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification marked as read')),
        );
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context
                .read<TeacherBloc>()
                .add(MarkTeacherNotificationAsRead(notification.id));
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
                  _categoryIcon(notification.category),
                  size: 18,
                  color: notification.isRead
                      ? AppColors.inkMuted
                      : AppColors.accent,
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
                              fontSize: 13,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.inkSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceInset,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border:
                                Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Text(
                            notification.category.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormatter.formatTime(notification.date),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
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

  IconData _categoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'ATTENDANCE':
        return Icons.how_to_reg_rounded;
      case 'MARKS':
      case 'EXAM':
      case 'ACADEMIC':
        return Icons.grade_rounded;
      case 'FEE':
        return Icons.receipt_long_rounded;
      case 'LEAVE':
        return Icons.event_busy_rounded;
      case 'ANNOUNCEMENT':
      case 'EVENT':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}

