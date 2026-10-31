enum LeaveStatus {
  pending,
  approved,
  rejected,
  withdrawn,
  unknown;

  static LeaveStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'PENDING':
        return LeaveStatus.pending;
      case 'APPROVED':
        return LeaveStatus.approved;
      case 'REJECTED':
        return LeaveStatus.rejected;
      case 'WITHDRAWN':
      case 'WITHDRAW':
        return LeaveStatus.withdrawn;
      default:
        return LeaveStatus.unknown;
    }
  }

  String toApiString() {
    switch (this) {
      case LeaveStatus.pending:
        return 'PENDING';
      case LeaveStatus.approved:
        return 'APPROVED';
      case LeaveStatus.rejected:
        return 'REJECTED';
      case LeaveStatus.withdrawn:
        return 'WITHDRAWN';
      case LeaveStatus.unknown:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.withdrawn:
        return 'Withdrawn';
      case LeaveStatus.unknown:
        return 'All';
    }
  }
}
