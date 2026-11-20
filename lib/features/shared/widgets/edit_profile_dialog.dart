import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../repositories/user_repository.dart';

class EditProfileDialog extends StatefulWidget {
  final dynamic userId;
  final String initialFirstName;
  final String initialLastName;
  final String initialEmail;
  final String initialPhone;
  final String initialCnic;
  final String initialBloodGroup;
  final String initialFatherName;
  final String initialContactNo1;
  final String initialEmergencyContact;
  final String initialAddress;
  final VoidCallback? onSuccess;
  final ApiClient? apiClient;

  const EditProfileDialog({
    super.key,
    required this.userId,
    this.initialFirstName = '',
    this.initialLastName = '',
    this.initialEmail = '',
    this.initialPhone = '',
    this.initialCnic = '',
    this.initialBloodGroup = '',
    this.initialFatherName = '',
    this.initialContactNo1 = '',
    this.initialEmergencyContact = '',
    this.initialAddress = '',
    this.onSuccess,
    this.apiClient,
  });

  static Future<void> show(
    BuildContext context, {
    required dynamic userId,
    String initialFirstName = '',
    String initialLastName = '',
    String initialEmail = '',
    String initialPhone = '',
    String initialCnic = '',
    String initialBloodGroup = '',
    String initialFatherName = '',
    String initialContactNo1 = '',
    String initialEmergencyContact = '',
    String initialAddress = '',
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditProfileDialog(
        userId: userId,
        initialFirstName: initialFirstName,
        initialLastName: initialLastName,
        initialEmail: initialEmail,
        initialPhone: initialPhone,
        initialCnic: initialCnic,
        initialBloodGroup: initialBloodGroup,
        initialFatherName: initialFatherName,
        initialContactNo1: initialContactNo1,
        initialEmergencyContact: initialEmergencyContact,
        initialAddress: initialAddress,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cnicController;
  late final TextEditingController _bloodGroupController;
  late final TextEditingController _fatherNameController;
  late final TextEditingController _contact1Controller;
  late final TextEditingController _emergencyContactController;
  late final TextEditingController _addressController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _cnicController = TextEditingController(text: widget.initialCnic);
    _bloodGroupController = TextEditingController(text: widget.initialBloodGroup);
    _fatherNameController = TextEditingController(text: widget.initialFatherName);
    _contact1Controller = TextEditingController(
      text: widget.initialContactNo1.isNotEmpty
          ? widget.initialContactNo1
          : widget.initialPhone,
    );
    _emergencyContactController = TextEditingController(text: widget.initialEmergencyContact);
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _bloodGroupController.dispose();
    _fatherNameController.dispose();
    _contact1Controller.dispose();
    _emergencyContactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final userRepo = UserRepository(apiClient: widget.apiClient ?? ApiClient());

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fullName = '$firstName $lastName'.trim();

    final payload = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': widget.initialEmail,
      'phone': _phoneController.text.trim(),
      'cnicNo': _cnicController.text.trim(),
      'bloodGroup': _bloodGroupController.text.trim(),
      'fatherName': _fatherNameController.text.trim(),
      'contactNo1': _contact1Controller.text.trim(),
      'emergencyContactNumber': _emergencyContactController.text.trim(),
      'address': _addressController.text.trim(),
    };

    try {
      await userRepo.updateUserProfile(
        userId: widget.userId,
        payload: payload,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
              'Edit profile',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First name'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cnicController,
                    decoration: const InputDecoration(
                      labelText: 'CNIC',
                      hintText: '42301-1039445-2',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bloodGroupController,
                    decoration: const InputDecoration(
                      labelText: 'Blood group',
                      hintText: 'e.g. A+',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fatherNameController,
              decoration: const InputDecoration(
                labelText: 'Father / Guardian name',
                prefixIcon: Icon(Icons.person_outline, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _contact1Controller,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact No 1',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _emergencyContactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Emergency contact',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Residential address',
                prefixIcon: Icon(Icons.home_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
