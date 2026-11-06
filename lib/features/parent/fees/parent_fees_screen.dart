import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/parent_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/fee_model.dart';
import '../../auth/models/user_model.dart';
import '../../shared/widgets/stat_card.dart';

/// Parent-facing fee screen: shows outstanding dues, school bank account
/// details, and the history of submitted payments with their verification
/// status. Aligned with DESIGN.md Quiet Editorial Luxury.
class ParentFeesScreen extends StatefulWidget {
  const ParentFeesScreen({super.key});

  @override
  State<ParentFeesScreen> createState() => _ParentFeesScreenState();
}

class _ParentFeesScreenState extends State<ParentFeesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ParentBloc>().add(LoadParentProfile());
  }

  void _loadFees(StudentModel child) {
    context.read<ParentBloc>().add(LoadFees(child.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Fees & payments',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
      ),
      body: BlocBuilder<ParentBloc, ParentState>(
        buildWhen: (_, state) =>
            state is ParentProfileLoaded ||
            state is ParentProfileLoading ||
            state is ParentProfileError,
        builder: (context, state) {
          if (state is ParentProfileLoading) {
            return const ShimmerLoading(itemCount: 6, itemHeight: 100);
          }
          if (state is ParentProfileError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<ParentBloc>().add(LoadParentProfile()),
            );
          }
          if (state is ParentProfileLoaded) {
            final profile = state.profile;
            final child = profile.children[state.selectedChildIndex];

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadFees(child);
            });

            return Column(
              children: [
                if (profile.children.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInset,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.children.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 4),
                        itemBuilder: (context, index) {
                          final c = profile.children[index];
                          final isSelected = index == state.selectedChildIndex;
                          return GestureDetector(
                            onTap: () {
                              context.read<ParentBloc>().add(SelectChild(index));
                              _loadFees(c);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(color: AppColors.border, width: 1)
                                    : null,
                                boxShadow: isSelected ? AppShadows.subtle : null,
                              ),
                              child: Center(
                                child: Text(
                                  c.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? AppColors.accent : AppColors.inkMuted,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: BlocConsumer<ParentBloc, ParentState>(
                    listenWhen: (_, state) =>
                        state is ParentFeeSubmitted ||
                        state is ParentFeesError,
                    listener: (context, state) {
                      if (state is ParentFeeSubmitted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Payment submitted. Status: ${state.payment.status.label}. '
                              'It will update after verification.',
                            ),
                            backgroundColor: AppColors.accent,
                          ),
                        );
                      } else if (state is ParentFeesError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    },
                    buildWhen: (_, state) =>
                        state is ParentFeesLoaded ||
                        state is ParentFeesLoading ||
                        state is ParentFeeSubmitting ||
                        state is ParentFeesError,
                    builder: (context, state) {
                      if (state is ParentFeesLoading) {
                        return const ShimmerLoading(
                            itemCount: 5, itemHeight: 110);
                      }
                      if (state is ParentFeesError) {
                        return AppErrorWidget(
                          message: state.message,
                          onRetry: () => _loadFees(child),
                        );
                      }
                      if (state is ParentFeesLoaded) {
                        return RefreshIndicator(
                          color: AppColors.accent,
                          onRefresh: () async => _loadFees(child),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildOutstandingSummary(state),
                                const SizedBox(height: 20),
                                Text(
                                  'Fee dues',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...state.fees.map(
                                  (fee) => _FeeCard(
                                    fee: fee,
                                    onPay: fee.isFullyPaid
                                        ? null
                                        : () => _openPaymentSheet(
                                              child,
                                              fee,
                                              state.account,
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Payment history',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (state.payments.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'No payments submitted yet.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.inkMuted,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...state.payments.map(
                                    (p) => _PaymentHistoryCard(payment: p),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const ShimmerLoading(itemCount: 5, itemHeight: 110);
                    },
                  ),
                ),
              ],
            );
          }
          return const ShimmerLoading(itemCount: 6, itemHeight: 100);
        },
      ),
    );
  }

  Widget _buildOutstandingSummary(ParentFeesLoaded state) {
    final status = AppStatusColors.of(context);
    final outstanding = state.totalOutstanding;
    final pendingCount = state.payments
        .where((p) => p.status == FeePaymentStatus.pending)
        .length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Total outstanding',
            value: 'Rs. ${outstanding.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_outlined,
            color: outstanding > 0 ? status.danger : status.success,
            caption: outstanding > 0 ? 'Dues pending payment' : 'All clear',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Pending audit',
            value: '$pendingCount',
            icon: Icons.hourglass_top_rounded,
            color: status.warning,
            caption: 'Awaiting verification',
          ),
        ),
      ],
    );
  }

  Future<void> _openPaymentSheet(
    StudentModel child,
    FeeModel fee,
    SchoolAccountModel account,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ParentBloc>(),
        child: _FeePaymentSheet(
          child: child,
          fee: fee,
          account: account,
        ),
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final FeeModel fee;
  final VoidCallback? onPay;

  const _FeeCard({required this.fee, this.onPay});

  @override
  Widget build(BuildContext context) {
    final String badge;
    final String kind;
    if (fee.isFullyPaid) {
      badge = 'Paid';
      kind = 'success';
    } else if (fee.isOverdue) {
      badge = 'Overdue';
      kind = 'danger';
    } else {
      badge = 'Due';
      kind = 'warning';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInset,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: const Icon(Icons.receipt_long_outlined, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fee.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill.semantic(
                context,
                label: badge,
                kind: kind,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _amountColumn(
                  'Amount',
                  'Rs. ${fee.amount.toStringAsFixed(0)}',
                  AppColors.ink,
                ),
              ),
              Expanded(
                child: _amountColumn(
                  'Balance',
                  'Rs. ${fee.balance.toStringAsFixed(0)}',
                  fee.balance > 0 ? AppColors.danger : AppColors.success,
                ),
              ),
              Expanded(
                child: _amountColumn(
                  'Due date',
                  DateFormatter.formatShortDate(fee.dueDate),
                  fee.isOverdue ? AppColors.danger : AppColors.inkSecondary,
                ),
              ),
            ],
          ),
          if (onPay != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.payments_outlined, size: 18),
                label: const Text('Pay now'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _amountColumn(
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FeePaymentSheet extends StatefulWidget {
  final StudentModel child;
  final FeeModel fee;
  final SchoolAccountModel account;

  const _FeePaymentSheet({
    required this.child,
    required this.fee,
    required this.account,
  });

  @override
  State<_FeePaymentSheet> createState() => _FeePaymentSheetState();
}

class _FeePaymentSheetState extends State<_FeePaymentSheet> {
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  String? _screenshotName;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.fee.balance.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _attachScreenshot() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64Image = base64Encode(bytes);
        setState(() {
          _screenshotName = 'data:image/jpeg;base64,$base64Image';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deposit slip image attached successfully.')),
          );
        }
      }
      // If user cancelled / picked == null, do not attach any dummy image!
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }
    if (_screenshotName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach a payment screenshot to continue.'),
        ),
      );
      return;
    }
    final payment = FeePaymentModel(
      id: '',
      feeId: widget.fee.id,
      studentId: widget.child.id,
      amount: amount,
      submittedOn: DateTime.now(),
      screenshotName: _screenshotName,
      referenceNumber: _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
    );
    context.read<ParentBloc>().add(SubmitFeePayment(payment, widget.child.id));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting =
        context.watch<ParentBloc>().state is ParentFeeSubmitting;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderHover,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pay ${widget.fee.title}',
              style: GoogleFonts.instrumentSerif(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'For ${widget.child.name} · Outstanding: Rs. ${widget.fee.balance.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 20),

            _stepHeader('01', 'Transfer to school bank account'),
            const SizedBox(height: 10),
            _AccountDetailsCard(account: widget.account),
            const SizedBox(height: 20),

            _stepHeader('02', 'Deposit details & screenshot receipt'),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount paid (Rs.)',
                prefixIcon: Icon(Icons.payments_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Transaction / reference no. (optional)',
                prefixIcon: Icon(Icons.confirmation_number_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _attachScreenshot,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _screenshotName == null
                        ? AppColors.border
                        : AppColors.successBorder,
                    width: 1,
                  ),
                  color: _screenshotName == null
                      ? AppColors.surfaceInset
                      : AppColors.successBg,
                ),
                child: Row(
                  children: [
                    Icon(
                      _screenshotName == null
                          ? Icons.add_photo_alternate_outlined
                          : Icons.image_rounded,
                      color: _screenshotName == null
                          ? AppColors.accent
                          : AppColors.success,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _screenshotName ?? 'Attach payment deposit receipt',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            _screenshotName == null
                                ? 'Screenshot required for accounts verification'
                                : 'Tap to replace image',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_screenshotName != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () =>
                            setState(() => _screenshotName = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.infoBorder, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your payment will be marked "Pending" until verified by school finance.',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: isSubmitting ? null : _submit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  isSubmitting ? 'Submitting...' : 'Submit payment slip',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accentTint,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.infoBorder, width: 1),
          ),
          child: Text(
            step,
            style: GoogleFonts.poppins(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  final SchoolAccountModel account;

  const _AccountDetailsCard({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          _row(context, 'Account title', account.accountName, copy: false),
          const Divider(height: 18),
          _row(context, 'Account number / IBAN', account.accountNumber),
          const Divider(height: 18),
          _row(context, 'Bank', '${account.bankName} · ${account.branch}', copy: false),
          if (account.ifscCode.isNotEmpty) ...[
            const Divider(height: 18),
            _row(context, 'Branch code', account.ifscCode),
          ],
          if (account.upiId.isNotEmpty) ...[
            const Divider(height: 18),
            _row(context, 'Reference / UPI ID', account.upiId),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool copy = true,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        if (copy)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.inkSecondary),
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard')),
              );
            },
          ),
      ],
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  final FeePaymentModel payment;

  const _PaymentHistoryCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final (kind, icon) = switch (payment.status) {
      FeePaymentStatus.verified => ('success', Icons.verified_outlined),
      FeePaymentStatus.rejected => ('danger', Icons.highlight_off_rounded),
      FeePaymentStatus.pending => ('warning', Icons.hourglass_top_rounded),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInset,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Icon(icon, color: AppColors.inkSecondary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs. ${payment.amount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Submitted ${DateFormatter.formatDateTime(payment.submittedOn)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill.semantic(
                context,
                label: payment.status == FeePaymentStatus.pending
                    ? 'Pending verification'
                    : (payment.status == FeePaymentStatus.verified ? 'Verified' : 'Rejected'),
                kind: kind,
              ),
            ],
          ),
          if (payment.referenceNumber != null || payment.screenshotName != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (payment.referenceNumber != null)
                  _meta(Icons.confirmation_number_outlined, payment.referenceNumber!),
                if (payment.screenshotName != null && payment.screenshotName!.isNotEmpty)
                  InkWell(
                    onTap: () => _showReceiptViewer(
                      context,
                      payment.screenshotName!,
                      payment.referenceNumber,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 14, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            'View deposit slip',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (payment.verificationRemarks != null &&
              payment.verificationRemarks!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceInset,
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(
                'Accounts remark: ${payment.verificationRemarks}',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.inkSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReceiptViewer(
    BuildContext context,
    String imageUrl,
    String? refNumber,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isNetwork =
            imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
        final isBase64 =
            imageUrl.startsWith('data:image') || imageUrl.length > 250;

        Widget imageWidget;
        if (isNetwork) {
          imageWidget = Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                _placeholderImage(imageUrl, refNumber),
          );
        } else if (isBase64) {
          try {
            final cleanBase64 =
                imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
            imageWidget = Image.memory(
              base64Decode(cleanBase64),
              fit: BoxFit.contain,
            );
          } catch (_) {
            imageWidget = _placeholderImage(imageUrl, refNumber);
          }
        } else {
          imageWidget = _placeholderImage(imageUrl, refNumber);
        }

        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 18, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          'Deposit slip proof',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.55,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppRadius.lg)),
                  child: SingleChildScrollView(
                    child: Center(child: imageWidget),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholderImage(String fileName, String? refNumber) {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceInset,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.image_outlined,
                size: 36, color: AppColors.accent),
          ),
          const SizedBox(height: 12),
          Text(
            fileName.length > 35
                ? '${fileName.substring(0, 32)}...'
                : fileName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.ink),
          ),
          if (refNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ref: $refNumber',
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.inkSecondary),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Deposit receipt attached to submission',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.inkMuted),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 170),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}
