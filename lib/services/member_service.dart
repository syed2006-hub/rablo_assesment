import 'package:get/get.dart';
import '../models/member_model.dart';
import '../models/membership_plan_model.dart';

/// Reactive repository and data service for gym members and plans.
class MemberService extends GetxService {
  static MemberService get to => Get.find<MemberService>();

  final RxList<MemberModel> members = <MemberModel>[].obs;
  final RxList<MembershipPlanModel> plans = <MembershipPlanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initSamplePlans();
    _initSampleMembers();
  }

  void _initSamplePlans() {
    plans.assignAll([
      const MembershipPlanModel(
        id: 'PLAN-01',
        name: 'Standard Monthly',
        price: 1499,
        durationMonths: 1,
        features: ['Gym Floor Access', 'Locker Room', 'Cardio Zone'],
      ),
      const MembershipPlanModel(
        id: 'PLAN-02',
        name: 'Gold Quarterly',
        price: 3999,
        durationMonths: 3,
        isPopular: true,
        features: [
          'Full Gym Access',
          'Group Classes (Yoga, HIIT)',
          'Sauna & Steam Bath',
          '1 Trainer Consultation',
        ],
      ),
      const MembershipPlanModel(
        id: 'PLAN-03',
        name: 'Platinum Annual',
        price: 12999,
        durationMonths: 12,
        features: [
          '24/7 VIP Gym Access',
          'Unlimited Personal Training',
          'Diet & Nutrition Coaching',
          'Complimentary Protein Bar',
          'Spa & Recovery Zone',
        ],
      ),
      const MembershipPlanModel(
        id: 'PLAN-04',
        name: 'Crossfit Pro',
        price: 2499,
        durationMonths: 1,
        features: ['Full Crossfit Box', 'Olympic Lifting Arena', 'Strength Coach'],
      ),
    ]);
  }

  void _initSampleMembers() {
    final now = DateTime.now();
    members.assignAll([
      MemberModel(
        id: 'M-1001',
        name: 'Alex Turner',
        email: 'alex.turner@gmail.com',
        phone: '+91 98765 43210',
        gender: 'Male',
        planName: 'Platinum Annual',
        status: 'Active',
        joinDate: now.subtract(const Duration(days: 120)),
        expiryDate: now.add(const Duration(days: 245)),
        attendanceCount: 78,
        emergencyContact: '+91 98765 11111 (Father)',
        notes: 'Pre-existing knee ligament sprain, avoid heavy squats.',
      ),
      MemberModel(
        id: 'M-1002',
        name: 'Sophia Martinez',
        email: 'sophia.m@gmail.com',
        phone: '+91 91234 56789',
        gender: 'Female',
        planName: 'Gold Quarterly',
        status: 'Active',
        joinDate: now.subtract(const Duration(days: 60)),
        expiryDate: now.add(const Duration(days: 30)),
        attendanceCount: 42,
        emergencyContact: '+91 91234 22222 (Spouse)',
        notes: 'Goal: Half-marathon cardio endurance training.',
      ),
      MemberModel(
        id: 'M-1003',
        name: 'Rahul Sharma',
        email: 'rahul.sharma@yahoo.com',
        phone: '+91 94567 89012',
        gender: 'Male',
        planName: 'Standard Monthly',
        status: 'Expiring',
        joinDate: now.subtract(const Duration(days: 27)),
        expiryDate: now.add(const Duration(days: 3)),
        attendanceCount: 19,
        emergencyContact: '+91 94567 33333 (Brother)',
        notes: 'Renewal reminder sent via WhatsApp.',
      ),
      MemberModel(
        id: 'M-1004',
        name: 'Ananya Verma',
        email: 'ananya.v@outlook.com',
        phone: '+91 93456 78901',
        gender: 'Female',
        planName: 'Crossfit Pro',
        status: 'Active',
        joinDate: now.subtract(const Duration(days: 45)),
        expiryDate: now.add(const Duration(days: 15)),
        attendanceCount: 35,
        emergencyContact: '+91 93456 44444 (Mother)',
        notes: 'Interested in competitive weightlifting.',
      ),
      MemberModel(
        id: 'M-1005',
        name: 'David Miller',
        email: 'david.m@fitness.org',
        phone: '+91 98111 22334',
        gender: 'Male',
        planName: 'Standard Monthly',
        status: 'Inactive',
        joinDate: now.subtract(const Duration(days: 90)),
        expiryDate: now.subtract(const Duration(days: 5)),
        attendanceCount: 22,
        emergencyContact: '+91 98111 55555 (Friend)',
        notes: 'Membership expired. Follow-up discount offered.',
      ),
      MemberModel(
        id: 'M-1006',
        name: 'Pooja Patel',
        email: 'pooja.patel@gmail.com',
        phone: '+91 97222 33445',
        gender: 'Female',
        planName: 'Gold Quarterly',
        status: 'Active',
        joinDate: now.subtract(const Duration(days: 15)),
        expiryDate: now.add(const Duration(days: 75)),
        attendanceCount: 11,
        emergencyContact: '+91 97222 66666 (Sister)',
        notes: 'Attends morning 7:00 AM Yoga and HIIT batch.',
      ),
    ]);
  }

  void addMember(MemberModel member) {
    members.insert(0, member);
  }

  void updateMember(MemberModel updated) {
    final index = members.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      members[index] = updated;
    }
  }

  MemberModel? findById(String id) {
    return members.firstWhereOrNull((m) => m.id == id);
  }

  int get totalMembersCount => members.length;
  int get activeMembersCount => members.where((m) => m.isActive).length;
  int get expiringMembersCount => members.where((m) => m.isExpiring).length;
  int get inactiveMembersCount => members.where((m) => m.isInactive).length;
}
