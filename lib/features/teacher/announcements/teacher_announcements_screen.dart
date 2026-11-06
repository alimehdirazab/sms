import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../announcements/bloc/announcement_bloc.dart';
import '../../announcements/models/announcement_model.dart';

class TeacherAnnouncementsScreen extends StatefulWidget {
  const TeacherAnnouncementsScreen({super.key});

  @override
  State<TeacherAnnouncementsScreen> createState() =>
      _TeacherAnnouncementsScreenState();
}

class _TeacherAnnouncementsScreenState
    extends State<TeacherAnnouncementsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<AnnouncementBloc>().add(const LoadAnnouncements());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= (maxScroll - 200)) {
      context.read<AnnouncementBloc>().add(const LoadMoreAnnouncements());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Campus announcements',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'Post announcement',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => _showCreateAnnouncementModal(context),
      ),
      body: BlocConsumer<AnnouncementBloc, AnnouncementState>(
        listenWhen: (_, state) =>
            state is AnnouncementCreatedSuccess ||
            state is AnnouncementCreateError,
        listener: (context, state) {
          if (state is AnnouncementCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Announcement posted successfully!'),
                backgroundColor: AppColors.accent,
              ),
            );
          } else if (state is AnnouncementCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AnnouncementLoading) {
            return const ShimmerLoading(itemCount: 6, itemHeight: 110);
          }

          if (state is AnnouncementError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<AnnouncementBloc>()
                  .add(const LoadAnnouncements(refresh: true)),
            );
          }

          if (state is AnnouncementLoaded) {
            final items = state.announcements;

            if (items.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceInset,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.borderFaint),
                        ),
                        child: const Icon(
                          Icons.campaign_outlined,
                          size: 26,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No announcements posted',
                        style: GoogleFonts.instrumentSerif(
                          fontSize: 22,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Post announcements to parents, students, or faculty using the button below.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () async {
                context
                    .read<AnnouncementBloc>()
                    .add(const LoadAnnouncements(refresh: true));
              },
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                itemCount: items.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    );
                  }

                  final item = items[index];
                  return _TeacherAnnouncementCard(announcement: item);
                },
              ),
            );
          }

          return const ShimmerLoading(itemCount: 6, itemHeight: 110);
        },
      ),
    );
  }

  void _showCreateAnnouncementModal(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final selectedRecipients = <String>{'parents'};

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
                      'Post campus announcement',
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 22,
                        fontWeight: FontWeight.normal,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Broadcast official notifications to parents and students.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Target recipients',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        FilterChip(
                          label: const Text('Parents'),
                          selected: selectedRecipients.contains('parents'),
                          selectedColor: AppColors.accent.withValues(alpha: 0.14),
                          onSelected: (val) {
                            setModalState(() {
                              if (val) {
                                selectedRecipients.add('parents');
                              } else if (selectedRecipients.length > 1) {
                                selectedRecipients.remove('parents');
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Students'),
                          selected: selectedRecipients.contains('students'),
                          selectedColor: AppColors.accent.withValues(alpha: 0.14),
                          onSelected: (val) {
                            setModalState(() {
                              if (val) {
                                selectedRecipients.add('students');
                              } else if (selectedRecipients.length > 1) {
                                selectedRecipients.remove('students');
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Teachers'),
                          selected: selectedRecipients.contains('teachers'),
                          selectedColor: AppColors.accent.withValues(alpha: 0.14),
                          onSelected: (val) {
                            setModalState(() {
                              if (val) {
                                selectedRecipients.add('teachers');
                              } else if (selectedRecipients.length > 1) {
                                selectedRecipients.remove('teachers');
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('All campus'),
                          selected: selectedRecipients.contains('all'),
                          selectedColor: AppColors.accent.withValues(alpha: 0.14),
                          onSelected: (val) {
                            setModalState(() {
                              if (val) {
                                selectedRecipients.clear();
                                selectedRecipients.add('all');
                              } else {
                                selectedRecipients.remove('all');
                                selectedRecipients.add('parents');
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Announcement title',
                        hintText: 'e.g. Upcoming Parent-Teacher Conference',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Message body',
                        hintText: 'Dear parents, please note that...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBouncyButton(
                      label: 'Publish announcement',
                      onPressed: () {
                        final title = titleController.text.trim();
                        final message = messageController.text.trim();
                        if (title.isEmpty || message.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter both title and message.'),
                            ),
                          );
                          return;
                        }

                        Navigator.of(ctx).pop();
                        context.read<AnnouncementBloc>().add(
                              CreateAnnouncementRequested(
                                title: title,
                                message: message,
                                recipient: selectedRecipients.toList(),
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

class _TeacherAnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;

  const _TeacherAnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy • hh:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInset,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: AppColors.ink,
                        letterSpacing: -0.01 * 20,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateFormat.format(announcement.createdAt),
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
          const SizedBox(height: 12),
          Text(
            announcement.message,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.inkSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: announcement.recipient.map((r) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInset,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Text(
                      r.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 13,
                    color: AppColors.inkMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    announcement.senderName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

