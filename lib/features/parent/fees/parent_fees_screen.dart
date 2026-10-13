import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../bloc/parent_bloc.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/fee_model.dart';
import '../../auth/models/user_model.dart';
import '../../shared/widgets/stat_card.dart';

/// Parent-facing fee screen: shows outstanding dues, school bank account
/// details, and the history of submitted payments with their verification
/// status. Tapping "Pay Now" opens the payment sheet.
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
      appBar: AppBar(title: const Text('Fees & Payments')),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.children.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final c = profile.children[index];
                          return ChoiceChip(
                            label: Text(c.name),
                            selected: index == state.selectedChildIndex,
                            onSelected: (_) {
                              context.read<ParentBloc>().add(SelectChild(index));
                              _loadFees(c);
                            },
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
                          ),
                        );
                      } else if (state is ParentFeesError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
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
                                  'Fee Dues',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
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
                                  'Payment History',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                if (state.payments.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text('No payments submitted yet.'),
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
            label: 'Total Due',
            value: '₹${outstanding.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet,
            color: outstanding > 0 ? status.danger : status.success,
            caption: outstanding > 0 ? 'Please pay' : 'All clear',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Pending',
            value: '$pendingCount',
            icon: Icons.hourglass_top,
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
      showDragHandle: true,
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
    final status = AppStatusColors.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color color;
    final String badge;
    if (fee.isFullyPaid) {
      color = status.success;
      badge = 'Paid';
    } else if (fee.isOverdue) {
      color = status.danger;
      badge = 'Overdue';
    } else {
      color = status.warning;
      badge = 'Due';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long, color: color),
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
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fee.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusPill(label: badge, color: color),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _amountColumn(
                    context,
                    'Amount',
                    '₹${fee.amount.toStringAsFixed(0)}',
                    colorScheme.onSurface,
                    textTheme,
                  ),
                ),
                Expanded(
                  child: _amountColumn(
                    context,
                    'Balance',
                    '₹${fee.balance.toStringAsFixed(0)}',
                    color,
                    textTheme,
                  ),
                ),
                Expanded(
                  child: _amountColumn(
                    context,
                    'Due Date',
                    DateFormatter.formatShortDate(fee.dueDate),
                    fee.isOverdue ? status.danger : colorScheme.onSurface,
                    textTheme,
                  ),
                ),
              ],
            ),
            if (onPay != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPay,
                  icon: const Icon(Icons.payments_outlined, size: 20),
                  label: const Text('Pay Now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _amountColumn(
    BuildContext context,
    String label,
    String value,
    Color color,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet that shows the school account details and lets the parent
/// attach a screenshot of the transfer, then submit for verification.
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

  void _attachScreenshot() {
    setState(() {
      _screenshotName = 'payment_screenshot_${DateTime.now().second}.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock screenshot attached.')),
    );
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = AppStatusColors.of(context);
    final isSubmitting =
        context.watch<ParentBloc>().state is ParentFeeSubmitting;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pay ${widget.fee.title}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'For ${widget.child.name} · Balance ₹${widget.fee.balance.toStringAsFixed(0)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Step 1: account details
            _stepHeader('1', 'Transfer to the school account'),
            const SizedBox(height: 10),
            _AccountDetailsCard(account: widget.account),
            const SizedBox(height: 20),

            // Step 2: amount + reference + screenshot
            _stepHeader('2', 'Enter details & attach screenshot'),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount paid (₹)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Transaction / Reference No. (optional)',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _attachScreenshot,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _screenshotName == null
                        ? colorScheme.outline.withValues(alpha: 0.6)
                        : status.success,
                    width: _screenshotName == null ? 1 : 1.5,
                  ),
                  color: _screenshotName == null
                      ? colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3)
                      : status.success.withValues(alpha: 0.08),
                ),
                child: Row(
                  children: [
                    Icon(
                      _screenshotName == null
                          ? Icons.add_photo_alternate_outlined
                          : Icons.image,
                      color: _screenshotName == null
                          ? colorScheme.primary
                          : status.success,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _screenshotName ?? 'Attach payment screenshot',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _screenshotName == null
                                ? 'Required for verification'
                                : 'Tap to replace',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_screenshotName != null)
                      IconButton(
                        icon: const Icon(Icons.close),
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
                color: status.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, size: 18, color: status.info),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your payment will be marked "Pending" until the school office verifies it.',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSubmitting ? null : _submit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  isSubmitting ? 'Submitting...' : 'Submit Payment Details',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepHeader(String step, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            step,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

/// Displays the school's bank account details with copy-to-clipboard actions.
class _AccountDetailsCard extends StatelessWidget {
  final SchoolAccountModel account;

  const _AccountDetailsCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row(context, 'Account Name', account.accountName, copy: false),
            const Divider(height: 18),
            _row(context, 'Account Number', account.accountNumber),
            const Divider(height: 18),
            _row(context, 'IFSC Code', account.ifscCode),
            const Divider(height: 18),
            _row(context, 'Bank', '${account.bankName} · ${account.branch}',
                copy: false),
            const Divider(height: 18),
            _row(context, 'UPI ID', account.upiId),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool copy = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        if (copy)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied')),
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
    final status = AppStatusColors.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color color;
    final IconData icon;
    switch (payment.status) {
      case FeePaymentStatus.verified:
        color = status.success;
        icon = Icons.verified;
        break;
      case FeePaymentStatus.rejected:
        color = status.danger;
        icon = Icons.cancel;
        break;
      case FeePaymentStatus.pending:
        color = status.warning;
        icon = Icons.hourglass_top;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${payment.amount.toStringAsFixed(0)}',
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Submitted ${DateFormatter.formatDateTime(payment.submittedOn)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(
                  label: payment.status == FeePaymentStatus.pending
                      ? 'Pending'
                      : payment.status.label,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (payment.referenceNumber != null)
                  _meta(textTheme, colorScheme, Icons.confirmation_number,
                      payment.referenceNumber!),
                if (payment.screenshotName != null)
                  _meta(textTheme, colorScheme, Icons.image,
                      payment.screenshotName!),
              ],
            ),
            if (payment.verificationRemarks != null &&
                payment.verificationRemarks!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Office: ${payment.verificationRemarks}',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _meta(
    TextTheme textTheme,
    ColorScheme colorScheme,
    IconData icon,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 170),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
