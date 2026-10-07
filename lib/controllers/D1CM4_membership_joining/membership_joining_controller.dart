import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CM4_membership_joining/member_model.dart';
import '../../models/D1CM4_membership_joining/membership_plan_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM4_membership_joining/membership_service.dart';
import '../../services/firebase/customer_firebase_service.dart';
import '../D1CM5_dashboard_v1/dashboard_v1_controller.dart';

class MembershipJoiningController extends GetxController {
  static MembershipJoiningController get to => Get.find<MembershipJoiningController>();

  final MembershipService _membershipService =
      Get.isRegistered<MembershipService>()
          ? MembershipService.to
          : Get.put(MembershipService());

  // Available Membership Plans
  final RxList<MembershipPlanModel> availablePlans = <MembershipPlanModel>[
    const MembershipPlanModel(
      id: 'PLN-101',
      name: 'Starter Fitness Plan',
      price: 1999.0,
      durationMonths: 1,
      features: [
        'Gym Equipment Access',
        'Locker Room Access',
        'General Fitness Assessment',
        '1 Free Trainer Consultation',
      ],
      isPopular: false,
    ),
    const MembershipPlanModel(
      id: 'PLN-102',
      name: 'Gold Quarterly Plan',
      price: 4999.0,
      durationMonths: 3,
      features: [
        'All Equipment Access',
        'Free Diet & Nutrition Chart',
        'Steam & Sauna Bath (1x/week)',
        '3 Personal Trainer Sessions',
        'Access to Group Yoga / HIIT Classes',
      ],
      isPopular: true,
    ),
    const MembershipPlanModel(
      id: 'PLN-103',
      name: 'Platinum Annual Transformation',
      price: 14999.0,
      durationMonths: 12,
      features: [
        'Unlimited 24/7 Access',
        'Dedicated Personal Trainer (12 sessions)',
        'Comprehensive Body Composition Scans',
        'Unlimited Steam, Sauna & Recovery Lounge',
        'Free Gym Merchandise & Shaker Bottle',
      ],
      isPopular: false,
    ),
  ].obs;

  // Selected Plan
  late final Rx<MembershipPlanModel> selectedPlan;

  // Current active membership info (if any)
  final RxString currentActivePlanName = 'Gold Quarterly Plan'.obs;
  final RxInt remainingDays = 42.obs;
  final RxInt remainingSessions = 18.obs;

  // Preferred 2-hour Time Slot Selection
  final List<String> availableTimeSlots = const [
    '06:00 AM - 08:00 AM',
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '04:00 PM - 06:00 PM',
    '06:00 PM - 08:00 PM',
    '08:00 PM - 10:00 PM',
    '11:00 PM - 01:00 AM', // Out of operating hours
  ];
  final RxString selectedTimeSlot = '06:00 AM - 08:00 AM'.obs;

  // Operating Hours: 06:00 AM to 10:00 PM
  final RxInt outOfHoursAttempts = 0.obs;

  // Overview Tabs (Review, Trainers, Key Features, Objective)
  final RxString selectedOverviewTab = 'Review'.obs;
  final List<String> overviewTabs = const ['Review', 'Trainers', 'Key Features', 'Objective'];

  // Add-on packages (Optional)
  final RxList<String> selectedAddOns = <String>[].obs;
  final Map<String, double> addOnPrices = const {
    'Personal Training (5 sessions)': 1500.0,
    'Diet & Nutrition Consultation': 800.0,
    'Locker Facility (Dedicated)': 500.0,
    'Spa & Recovery Access': 1200.0,
  };

  // Payment Calculation
  final double transactionCharge = 50.0;
  final double serviceCharge = 25.0;

  double get subtotal => selectedPlan.value.price;
  double get addOnsTotal => selectedAddOns.fold(0.0, (sum, key) => sum + (addOnPrices[key] ?? 0.0));
  double get grandTotal => subtotal + addOnsTotal + transactionCharge + serviceCharge;

  // Payment Form Controllers
  final TextEditingController cardNumberController = TextEditingController(text: '4532 •••• •••• 8921');
  final TextEditingController expiryController = TextEditingController(text: '08/28');
  final TextEditingController cvvController = TextEditingController(text: '882');
  final TextEditingController cardHolderController = TextEditingController(text: 'Alex Morgan');
  final RxString selectedPaymentMethod = 'Online Card'.obs; // 'Online Card' or 'Cash at Desk'
  final RxBool isProcessingPayment = false.obs;

  final RxBool isLoadingPlans = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedPlan = availablePlans[1].obs; // Default to Gold Quarterly
    fetchPlansFromFirestore();

    // Real-time synchronization with activePlan in CustomerFirebaseService
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final active = CustomerFirebaseService.to.activePlan.value;
      if (active != null) {
        currentActivePlanName.value = active['planName']?.toString() ?? 'Active Plan';
        remainingSessions.value = (active['sessionsLeft'] as num?)?.toInt() ?? 30;
      }
    }
  }

  /// Properly fetch membership plans dynamically from Cloud Firestore database
  Future<void> fetchPlansFromFirestore() async {
    isLoadingPlans.value = true;
    try {
      if (Get.isRegistered<CustomerFirebaseService>()) {
        final fs = CustomerFirebaseService.to.firestore;
        if (fs != null) {
          final snap = await fs.collection('membership_plans').get();
          if (snap.docs.isNotEmpty) {
            final plans = snap.docs.map((doc) {
              final data = doc.data();
              return MembershipPlanModel(
                id: doc.id,
                name: data['name']?.toString() ?? 'Fitness Plan',
                price: (data['price'] as num?)?.toDouble() ?? 2499.0,
                durationMonths: (data['durationMonths'] as num?)?.toInt() ?? 1,
                features: (data['features'] as List?)?.map((e) => e.toString()).toList() ?? [
                  'Gym Equipment Access',
                  'Locker Room Access',
                ],
                isPopular: data['isPopular'] == true || (data['name']?.toString().contains('Gold') ?? false),
              );
            }).toList();
            availablePlans.assignAll(plans);
            selectedPlan.value = availablePlans.firstWhereOrNull((p) => p.isPopular) ?? availablePlans.first;
            return;
          } else {
            // Seed default plans into Firestore collection 'membership_plans'
            for (final p in availablePlans) {
              await fs.collection('membership_plans').doc(p.id).set({
                'id': p.id,
                'name': p.name,
                'price': p.price,
                'durationMonths': p.durationMonths,
                'features': p.features,
                'isPopular': p.isPopular,
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Firestore fetchPlans notice: $e');
    } finally {
      isLoadingPlans.value = false;
    }
  }

  @override
  void onClose() {
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    cardHolderController.dispose();
    super.onClose();
  }

  void selectPlan(MembershipPlanModel plan) {
    selectedPlan.value = plan;
  }

  void selectTimeSlot(String slot) {
    // DRD 2.2 Validation:
    // If the customer's preferred time slot is different from opening and closing hours (06:00 AM - 10:00 PM),
    // alert the user the first two times.
    // On the third time, inform customer that the system will replace preferred time slot to opening & closing hours.
    if (slot == '11:00 PM - 01:00 AM') {
      outOfHoursAttempts.value++;
      if (outOfHoursAttempts.value < 3) {
        Get.snackbar(
          'Operating Hours Notice (${outOfHoursAttempts.value}/2)',
          'The chosen slot is outside operating hours (06:00 AM - 10:00 PM). Please select a slot within operating hours.',
          backgroundColor: const Color(0xFF163238),
          colorText: Colors.amberAccent,
          duration: const Duration(seconds: 4),
        );
        selectedTimeSlot.value = slot;
      } else {
        // 3rd time: replace with standard operating hours
        selectedTimeSlot.value = '06:00 AM - 08:00 AM';
        Get.snackbar(
          'Time Slot Replaced',
          'Operating hours exceeded 3 times. The system has automatically defaulted your slot to standard operating hours (06:00 AM - 08:00 AM).',
          backgroundColor: const Color(0xFF163238),
          colorText: AppColors.primaryBright,
          duration: const Duration(seconds: 5),
        );
      }
    } else {
      selectedTimeSlot.value = slot;
    }
  }

  void toggleAddOn(String addOn) {
    if (selectedAddOns.contains(addOn)) {
      selectedAddOns.remove(addOn);
    } else {
      selectedAddOns.add(addOn);
    }
  }

  /// Process Payment (Online Card or Cash at Desk)
  Future<void> processPayment() async {
    isProcessingPayment.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    isProcessingPayment.value = false;

    if (selectedPaymentMethod.value == 'Cash at Desk') {
      // DRD: Save into pending amount list on manager interface and alert manager
      _showCashConfirmationDialog();
    } else {
      // Online card payment
      _showOnlineSuccessDialog();
    }
  }

  void _showOnlineSuccessDialog() {
    // Add/Update member in membership service
    _updateActiveMembership();

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF152A2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFF1D3E35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.primaryBright, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Congratulations! You are now enrolled in ${selectedPlan.value.name}.\nPreferred Slot: ${selectedTimeSlot.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 14),
              // Breakdown badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Total Paid: ₹${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                    onPressed: () {
                    Get.back();
                    if (Get.isRegistered<DashboardV1Controller>()) {
                      DashboardV1Controller.to.activateDashboardV2();
                    }
                    Get.offAllNamed(AppRoutes.customerHome);
                  },
                  child: const Text('Go to Full Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Automatically transition straight to the full dashboard after brief confirmation glance
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      if (Get.isRegistered<DashboardV1Controller>()) {
        DashboardV1Controller.to.activateDashboardV2();
      }
      Get.offAllNamed(AppRoutes.customerHome);
    });
  }

  void _showCashConfirmationDialog() {
    _updateActiveMembership(isCash: true);

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF152A2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFF3F3B1A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.point_of_sale_rounded, color: Colors.amberAccent, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Subscription Queued!',
                style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your subscription has been recorded in the Manager\'s Pending Cash Collection list. Please complete payment at the front desk within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Pending Amount: ₹${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Get.back();
                    if (Get.isRegistered<DashboardV1Controller>()) {
                      DashboardV1Controller.to.activateDashboardV2();
                    }
                    Get.offAllNamed(AppRoutes.customerHome);
                  },
                  child: const Text('Go to Full Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Automatically transition straight to the full dashboard after brief confirmation glance
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      if (Get.isRegistered<DashboardV1Controller>()) {
        DashboardV1Controller.to.activateDashboardV2();
      }
      Get.offAllNamed(AppRoutes.customerHome);
    });
  }

  void _updateActiveMembership({bool isCash = false}) {
    final now = DateTime.now();
    final updatedMember = MemberModel(
      id: 'MBR-1005',
      name: 'Alex Morgan',
      email: 'alex.fitness@gmail.com',
      phone: '+91 9876543210',
      gender: 'Male',
      planName: selectedPlan.value.name,
      status: 'Active',
      joinDate: now,
      expiryDate: now.add(Duration(days: selectedPlan.value.durationMonths * 30)),
      attendanceCount: 1,
      emergencyContact: 'Not Provided',
      notes: 'Preferred Slot: ${selectedTimeSlot.value}',
    );
    _membershipService.addMember(updatedMember);

    // Sync to Cloud Firestore in real time & activate Dashboard V2
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final fbService = CustomerFirebaseService.to;
      final uid = fbService.currentUid.value;
      fbService.isDashboardV2Active.value = true;
      if (uid.isNotEmpty) {
        fbService.setDashboardV2Active(uid, true);
        fbService.joinMembershipPlan(
          uid,
          plan: {
            'id': selectedPlan.value.id,
            'name': selectedPlan.value.name,
            'durationMonths': selectedPlan.value.durationMonths,
            'sessionCount': selectedPlan.value.durationMonths * 30,
          },
          timeSlot: selectedTimeSlot.value,
          paymentMethod: isCash ? 'Front Desk Cash' : 'Online Card',
          totalAmount: grandTotal,
          addOns: selectedAddOns.toList(),
        );
      }
    }

    // Advance DashboardV1 Stepper to 100% and activate Full Dashboard (V2) immediately
    if (Get.isRegistered<DashboardV1Controller>()) {
      DashboardV1Controller.to.activeStep.value = 2;
      DashboardV1Controller.to.activateDashboardV2();
    }
  }
}
