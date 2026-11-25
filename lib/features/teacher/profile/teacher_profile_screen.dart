import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/glossy_3d_avatar.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../shared/widgets/change_password_dialog.dart';
import '../../shared/widgets/edit_profile_dialog.dart';
import '../bloc/teacher_bloc.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadTeacherProfile());
  }

  void _openEditProfile() {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthSuccess ? authState.user : null;
    final names = (user?.name ?? 'Annemarie Mertens').split(' ');
    final firstName = names.isNotEmpty ? names.first : 'Annemarie';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'Mertens';

    EditProfileDialog.show(
      context,
      userId: user?.id ?? 3,
      initialFirstName: firstName,
      initialLastName: lastName,
      initialEmail: user?.email ?? 'annemarie.mertens.kgs@school.com',
      initialPhone: user?.phone ?? '+92 333 1068021',
      initialCnic: '42301-1039445-2',
      initialBloodGroup: 'A+',
      initialFatherName: 'Mertens Senior',
      initialContactNo1: '+92 333 1068021',
      initialEmergencyContact: '+92 333 1095422',
      initialAddress: '6816 De Vlakte, Block 5, Clifton, Karachi',
      onSuccess: () {
        context.read<TeacherBloc>().add(LoadTeacherProfile());
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign out',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to sign out of Nexira?',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.inkSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.inkMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequested());
              context.goNamed(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Sign out',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2), // Luxury fintech cream canvas matching Image 3
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1D1D1F)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goNamed(RouteNames.teacherHome);
            }
          },
        ),
        title: Text(
          'Personal Profile',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D1D1F),
          ),
        ),
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        buildWhen: (_, state) =>
            state is TeacherProfileLoaded ||
            state is TeacherProfileLoading ||
            state is TeacherProfileError,
        builder: (context, state) {
          if (state is TeacherProfileLoading) {
            return const ShimmerLoading(itemCount: 6, itemHeight: 64);
          }
          if (state is TeacherProfileError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<TeacherBloc>().add(LoadTeacherProfile()),
            );
          }

          final authState = context.read<AuthBloc>().state;
          final user = authState is AuthSuccess ? authState.user : null;

          final fullName = user?.name.isNotEmpty == true
              ? user!.name
              : (state is TeacherProfileLoaded ? state.profile.name : 'Annemarie Mertens');
          final email = user?.email.isNotEmpty == true
              ? user!.email
              : (state is TeacherProfileLoaded ? (state.profile.email ?? 'annemarie.mertens.kgs@school.com') : 'annemarie.mertens.kgs@school.com');
          final phone = (user?.phone?.isNotEmpty == true)
              ? user!.phone!
              : (state is TeacherProfileLoaded ? (state.profile.phoneNumber ?? '+92 333 1068021') : '+92 333 1068021');

          final employeeId = state is TeacherProfileLoaded ? state.profile.employeeId : 'T-1042';
          final department = state is TeacherProfileLoaded ? state.profile.department : 'Science & Mathematics';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              children: [
                // 1. Glossy 3D Avatar (Image 3)
                Center(
                  child: Glossy3DAvatar(
                    size: 88,
                    onCameraTap: _openEditProfile,
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Edit Profile Outlined Button (Image 3)
                OutlinedButton.icon(
                  onPressed: _openEditProfile,
                  icon: const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Color(0xFFFA8C16),
                  ),
                  label: Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFA8C16),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFA8C16), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Form Card with Rounded Fields (Image 3)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileField(
                        label: 'Full Name *',
                        value: fullName,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        label: 'Email Address',
                        value: email,
                      ),
                      const SizedBox(height: 16),
                      _buildMobileField(
                        label: 'Mobile Number',
                        value: phone,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        label: 'CNIC',
                        value: '42301-1039445-2',
                        hintText: 'e.g. xxxxx-xxxxxxx-x',
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        label: 'Employee ID',
                        value: employeeId,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        label: 'Department',
                        value: department,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4. Navigation & Account Management Actions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_view_week_rounded,
                            color: Color(0xFFFA8C16),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Weekly Timetable',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D1D1F),
                          ),
                        ),
                        subtitle: Text(
                          'View class periods and schedules',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Color(0xFFC7C7CC),
                        ),
                        onTap: () => context.pushNamed(RouteNames.teacherWeeklySchedule),
                      ),
                      const Divider(height: 1, indent: 56, endIndent: 16),
                      ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.event_available_rounded,
                            color: Color(0xFFFA8C16),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Leave Applications',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D1D1F),
                          ),
                        ),
                        subtitle: Text(
                          'Track teacher leaves and student approvals',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Color(0xFFC7C7CC),
                        ),
                        onTap: () => context.pushNamed(RouteNames.teacherLeave),
                      ),
                      const Divider(height: 1, indent: 56, endIndent: 16),
                      ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xFFFA8C16),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Academic Calendar',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D1D1F),
                          ),
                        ),
                        subtitle: Text(
                          'Campus events, exams & holidays',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Color(0xFFC7C7CC),
                        ),
                        onTap: () => context.pushNamed(RouteNames.teacherCalendar),
                      ),
                      const Divider(height: 1, indent: 56, endIndent: 16),
                      ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Color(0xFFFA8C16),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Change Password',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D1D1F),
                          ),
                        ),
                        subtitle: Text(
                          'Update your account security credentials',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Color(0xFFC7C7CC),
                        ),
                        onTap: () => ChangePasswordDialog.show(context),
                      ),
                      const Divider(height: 1, indent: 56, endIndent: 16),
                      ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.dangerBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.danger,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Sign Out',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                        subtitle: Text(
                          'End current session on this device',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Color(0xFFC7C7CC),
                        ),
                        onTap: _confirmLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 1.2),
          ),
          child: Text(
            value.isNotEmpty ? value : (hintText ?? ''),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: value.isNotEmpty
                  ? const Color(0xFF1D1D1F)
                  : const Color(0xFF8E8E93),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 1.2),
          ),
          child: Row(
            children: [
              // Pakistan Flag icon
              Container(
                width: 24,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF00401A),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Container(width: 6, color: Colors.white),
                    Expanded(
                      child: Center(
                        child: Text(
                          '★',
                          style: TextStyle(
                            fontSize: 7,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: Color(0xFF1D1D1F),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
