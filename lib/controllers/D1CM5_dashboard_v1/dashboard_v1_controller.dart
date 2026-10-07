import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CM9_dashboard_v2/rush_hour_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api/business_connect_api_service.dart';
import '../../services/firebase/customer_firebase_service.dart';
import '../../widgets/trainer_bottom_sheet.dart';
import '../D1CM9_dashboard_v2/dashboard_v2_controller.dart' as cm9_ctrl;

/// D1CM5 – Dashboard V1 Controller.
/// Strictly implements the Figma Dashboard V1 design matching the reference image:
/// - 3-Step Round-and-Bar Stepper:
///     State 1 (20%): Connect Your Business (Affiliation scanning)
///     State 2 (60%): Join the Membership (Plan selection & payment)
///     State 3 (100%): Scan Your First Session (Attendance pass scanning)
/// - Top bar with "Hi John!" / member name, "Unverified" pill badge, and "This is Rablo.."
/// - 4 Accessibility Tabs: Membership, Trainers, My Transactions, Support
/// - Locked Cards Grid with centered lock icons
/// - Interactive Rush Hours Indicator
class DashboardV1Controller extends GetxController {
  static DashboardV1Controller get to => Get.find<DashboardV1Controller>();

  final BusinessConnectApiService _businessService =
      Get.isRegistered<BusinessConnectApiService>()
          ? BusinessConnectApiService.to
          : Get.put(BusinessConnectApiService());

  final RxBool isLoading = false.obs;
  final RxBool isAffiliated = false.obs;
  final RxString affiliatedBusinessName = ''.obs;

  // Activation Step: 0 = 20%, 1 = 60%, 2 = 100%
  final RxInt activeStep = 0.obs;
  final RxBool isDashboardV2Active = false.obs;

  // Header State
  final RxString memberName = 'John'.obs;
  final RxBool isVerified = false.obs;

  // Rush hour data points (kept for DRD & test compatibility)
  final rushHourPoints = <RushHourDataPoint>[].obs;
  final selectedHour = Rxn<RushHourDataPoint>();

  @override
  void onInit() {
    super.onInit();
    rushHourPoints.assignAll(RushHourDataPoint.getSampleData());
    selectedHour.value = rushHourPoints.firstWhereOrNull((p) => p.timeLabel == '8:00') ?? rushHourPoints.first;

    checkJourneyProgress();

    // Real-time synchronization with CustomerFirebaseService
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final fbService = CustomerFirebaseService.to;

      ever(fbService.currentAffiliation, (_) => checkJourneyProgress());
      ever(fbService.activePlan, (plan) {
        if (plan != null) {
          isDashboardV2Active.value = true;
        }
        checkJourneyProgress();
      });
      ever(fbService.hasScannedFirstSession, (_) => checkJourneyProgress());
      ever(fbService.isDashboardV2Active, (active) {
        isDashboardV2Active.value = active;
      });
      isDashboardV2Active.value = fbService.isDashboardV2Active.value;

      ever(fbService.currentUserProfile, (profile) {
        if (profile != null) {
          if (profile['fullName'] != null && profile['fullName'].toString().isNotEmpty) {
            memberName.value = profile['fullName'].toString().split(' ').first;
          }
          if (profile['isVerified'] != null) {
            isVerified.value = profile['isVerified'] == true;
          }
          if (profile['isDashboardV2Active'] == true) {
            isDashboardV2Active.value = true;
          }
        }
      });

      final current = fbService.currentUserProfile.value;
      if (current != null) {
        if (current['fullName'] != null && current['fullName'].toString().isNotEmpty) {
          memberName.value = current['fullName'].toString().split(' ').first;
        }
        if (current['isDashboardV2Active'] == true) {
          isDashboardV2Active.value = true;
        }
      }
    }
  }

  void checkJourneyProgress() {
    bool affiliated = false;
    String bizName = '';

    if (Get.isRegistered<CustomerFirebaseService>()) {
      final aff = CustomerFirebaseService.to.currentAffiliation.value;
      if (aff != null) {
        affiliated = true;
        bizName = aff['businessName']?.toString() ?? aff['name']?.toString() ?? 'Rablo Fitness Elite';
      }
    }

    if (!affiliated) {
      final connects = _businessService.businessConnects;
      if (connects.isNotEmpty) {
        affiliated = true;
        bizName = connects.first['name']?.toString() ?? 'PowerFit Gym';
      }
    }

    isAffiliated.value = affiliated;
    affiliatedBusinessName.value = bizName;

    // Check if user has joined a membership plan
    bool hasPlan = false;
    if (Get.isRegistered<CustomerFirebaseService>()) {
      hasPlan = CustomerFirebaseService.to.activePlan.value != null;
    }

    // Determine current active step matching user instructions:
    // State 0: 20% - 1 filled icon, 1 filled bar -> "Connect Your Business"
    // State 1: 60% - 2 filled icons, 1 filled bar -> "Join the Membership"
    // State 2: 100% - 3 filled icons, 2 filled bars -> Completed Message!
    if (!affiliated) {
      activeStep.value = 0; // 20%: Connect Your Business
    } else if (!hasPlan) {
      activeStep.value = 1; // 60%: Join the Membership
    } else {
      activeStep.value = 2; // 100%: Completed!
      isDashboardV2Active.value = true; // Push straight to full dashboard
    }
  }

  String get percentageText {
    switch (activeStep.value) {
      case 0:
        return '20%';
      case 1:
        return '60%';
      default:
        return '100%';
    }
  }

  String get stepCtaText {
    switch (activeStep.value) {
      case 0:
        return 'Connect Your Business';
      case 1:
        return 'Join the Membership';
      default:
        return 'Open Full Dashboard';
    }
  }

  void cycleStepForDemo() {
    activeStep.value = (activeStep.value + 1) % 3;
  }

  void setStep(int step) {
    if (step >= 0 && step <= 2) {
      activeStep.value = step;
    }
  }

  void handleCurrentStepAction() {
    switch (activeStep.value) {
      case 0:
        Get.toNamed(AppRoutes.customerQr);
        break;
      case 1:
        Get.toNamed(AppRoutes.membershipJoining);
        break;
      default:
        activateDashboardV2();
        break;
    }
  }

  /// Mark first session attendance as completed (advances to 100%)
  void markFirstSessionCompleted() {
    activeStep.value = 2;
    if (Get.isRegistered<CustomerFirebaseService>()) {
      CustomerFirebaseService.to.hasScannedFirstSession.value = true;
    }
  }

  /// Activates Dashboard V2 with the user's current real-time details
  void activateDashboardV2() {
    isDashboardV2Active.value = true;

    // Persist to Cloud Firestore & local storage
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final fbService = CustomerFirebaseService.to;
      final uid = fbService.currentUid.value;
      fbService.isDashboardV2Active.value = true;
      if (uid.isNotEmpty) {
        fbService.setDashboardV2Active(uid, true);
      }
    }

    // Refresh Dashboard V2 with the freshest details
    if (Get.isRegistered<cm9_ctrl.DashboardV2Controller>()) {
      cm9_ctrl.DashboardV2Controller.to.syncWithCurrentDetails();
    }

    Get.snackbar(
      'Dashboard V2 Activated!',
      'Welcome to your full-access customer dashboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF163238),
      colorText: AppColors.primaryBright,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.rocket_launch_rounded, color: AppColors.primaryBright),
      duration: const Duration(seconds: 3),
    );
  }

  /// In-place Business Connection Modal supporting ONLY Scan QR or Enter PIN
  void showConnectBusinessModal() {
    final pinController = TextEditingController(text: '4001');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF13282E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF244F59), width: 1.5),
            left: BorderSide(color: Color(0xFF244F59), width: 1.5),
            right: BorderSide(color: Color(0xFF244F59), width: 1.5),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Connect Your Business',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Scan the gym QR code or enter the 4-digit PIN below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // --- Process 1: Scan Gym QR Code ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF17333B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF244F59)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1E22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryBright, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.primaryBright,
                          size: 58,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBright,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => connectBusinessWithPin('4001'),
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text('Scan Gym QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // "— OR —" divider
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: Colors.white12)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('— OR —', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Container(height: 1, color: Colors.white12)),
                ],
              ),

              const SizedBox(height: 16),

              // --- Process 2: Enter 4-Digit PIN ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF17333B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF244F59)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Gym PIN (4 Digits)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primaryBright,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 16,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFF0F1E22),
                        hintText: '4001',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.2),
                          letterSpacing: 16,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF244F59)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryBright, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBright,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final pin = pinController.text.trim();
                          connectBusinessWithPin(pin.isNotEmpty ? pin : '4001');
                        },
                        child: const Text('Connect via PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Connect business via PIN or QR
  Future<void> connectBusinessWithPin(String pin) async {
    isLoading.value = true;
    try {
      final bizData = {
        'id': 'BIZ-4001',
        'businessId': 'BIZ-4001',
        'name': 'Rablo Fitness Elite',
        'businessName': 'Rablo Fitness Elite',
        'branch': 'Indiranagar 100ft Rd',
        'pin': pin,
        'managerName': 'Rajesh Sharma',
        'operatingHours': '06:00 AM - 10:00 PM',
        'connectedAt': DateTime.now().toIso8601String(),
      };

      _businessService.connectBusiness(bizData);

      if (Get.isRegistered<CustomerFirebaseService>()) {
        final fbService = CustomerFirebaseService.to;
        await fbService.connectBusiness(
          pin: pin,
          businessData: bizData,
        );
      }
      isAffiliated.value = true;
      affiliatedBusinessName.value = 'Rablo Fitness Elite';
      activeStep.value = 1;

      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Business Connected!',
        'Linked to Rablo Fitness Elite. You can now join a membership plan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF163238),
        colorText: AppColors.primaryBright,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error connecting business: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectHour(RushHourDataPoint point) {
    selectedHour.value = point;
  }

  void onTabPressed(String tabName) {
    switch (tabName) {
      case 'Membership':
        if (!isAffiliated.value) {
          showLockedDialog(
            feature: 'Membership Plans',
            requiredStep: 'Step 1: Connect your Business to explore exclusive plans.',
            ctaText: 'Scan to Connect',
            onCta: () {
              Get.back();
              Get.toNamed(AppRoutes.customerQr);
            },
          );
        } else {
          Get.toNamed(AppRoutes.membershipJoining);
        }
        break;

      case 'Trainers':
        TrainerBottomSheet.show(Get.context!);
        break;

      case 'My Transactions':
        showLockedDialog(
          feature: 'Transactions',
          requiredStep: 'Step 2: Payment receipts and invoices appear here once you subscribe to a membership plan.',
          ctaText: 'Join the Membership',
          onCta: () {
            Get.back();
            Get.toNamed(AppRoutes.membershipJoining);
          },
        );
        break;

      case 'Support':
        _showSupportDialog();
        break;
    }
  }

  void showLockedDialog({
    required String feature,
    required String requiredStep,
    required String ctaText,
    required VoidCallback onCta,
  }) {
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
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2419),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded, color: Colors.amberAccent, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                '$feature Locked',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                requiredStep,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBright,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: onCta,
                      child: Text(ctaText, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF152A2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.support_agent_rounded, color: AppColors.primaryBright, size: 48),
              const SizedBox(height: 14),
              const Text(
                'Customer Support',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Need help getting started or linking your fitness center? We are here for you 24/7.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.primaryBright),
                title: const Text('Call Support Desk', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('+91 98765 43210', style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () => Get.back(),
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryBright),
                title: const Text('Live Chat Assistant', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Typical reply in 2 mins', style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () => Get.back(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
