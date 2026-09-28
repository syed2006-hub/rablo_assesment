import 'package:get/get.dart';
import '../../models/D1CC6_attendance/attendance_record_model.dart';
import '../D1MM3_membership_planning/membership_service.dart';

/// D1CC6 – Attendance Verification & Monitoring Service.
class AttendanceService extends GetxService {
  static AttendanceService get to => Get.find<AttendanceService>();

  final RxList<AttendanceRecordModel> attendanceLogs =
      <AttendanceRecordModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initSampleAttendance();
  }

  void _initSampleAttendance() {
    final now = DateTime.now();
    attendanceLogs.assignAll([
      AttendanceRecordModel(
        recordId: 'ATT-101',
        memberId: 'M-1001',
        memberName: 'Alex Turner',
        planName: 'Platinum Annual',
        checkInTime: now.subtract(const Duration(minutes: 18)),
        accessMethod: 'QR Code',
        status: 'Verified',
      ),
      AttendanceRecordModel(
        recordId: 'ATT-102',
        memberId: 'M-1002',
        memberName: 'Sophia Martinez',
        planName: 'Gold Quarterly',
        checkInTime: now.subtract(const Duration(minutes: 45)),
        accessMethod: 'Biometric',
        status: 'Verified',
      ),
      AttendanceRecordModel(
        recordId: 'ATT-103',
        memberId: 'M-1004',
        memberName: 'Ananya Verma',
        planName: 'Crossfit Pro Monthly',
        checkInTime: now.subtract(const Duration(hours: 1, minutes: 12)),
        accessMethod: 'QR Code',
        status: 'Verified',
      ),
      AttendanceRecordModel(
        recordId: 'ATT-104',
        memberId: 'M-1003',
        memberName: 'Rahul Sharma',
        planName: 'Standard Monthly',
        checkInTime: now.subtract(const Duration(hours: 2, minutes: 5)),
        accessMethod: 'RFID Badge',
        status: 'Expiring Soon',
      ),
    ]);
  }

  /// Record a new check-in for a member
  bool recordMemberCheckIn(String memberId, {String accessMethod = 'QR Code'}) {
    final membershipService = Get.isRegistered<MembershipService>()
        ? MembershipService.to
        : null;
    final member = membershipService?.findMemberById(memberId);

    if (member != null) {
      final newRecord = AttendanceRecordModel(
        recordId: 'ATT-${DateTime.now().millisecondsSinceEpoch % 10000}',
        memberId: member.id,
        memberName: member.name,
        planName: member.planName,
        checkInTime: DateTime.now(),
        accessMethod: accessMethod,
        status: member.isExpiring ? 'Expiring Soon' : 'Verified',
      );

      attendanceLogs.insert(0, newRecord);

      // Increment attendance count
      final updated = member.copyWith(
        attendanceCount: member.attendanceCount + 1,
      );
      membershipService?.updateMember(updated);
      return true;
    }
    return false;
  }
}
