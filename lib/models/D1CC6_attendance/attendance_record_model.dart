/// D1CC6 – Attendance Record Model for check-in verification & monitoring.
class AttendanceRecordModel {
  final String recordId;
  final String memberId;
  final String memberName;
  final String planName;
  final DateTime checkInTime;
  final String accessMethod; // 'QR Code', 'Manual Scan', 'Biometric', 'RFID'
  final String status; // 'Verified', 'Expired Flagged', 'Guest Pass'

  const AttendanceRecordModel({
    required this.recordId,
    required this.memberId,
    required this.memberName,
    required this.planName,
    required this.checkInTime,
    required this.accessMethod,
    this.status = 'Verified',
  });
}
