import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/D1CM6_my_profile/my_profile_controller.dart';
import '../../controllers/D1CM6_my_profile/bank_account_controller.dart';
import '../../routes/app_routes.dart';
import 'bank_account_screen.dart';
import 'personal_details_screen.dart';

/// D1CM6 – My Profile Hub Screen.
/// Strictly implements DRD specifications for Customer Profile:
/// - Profile Overview & Membership Status
/// - Personal Details Editing
/// - Business Connects with "What went wrong" Deletion flow
/// - My Trainers (Expertise & Achievement)
/// - Transactions & Invoices
/// - My Account (Promotional Consent & 30-day Account Deactivation)
/// - Logout Confirmation Dialog
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MyProfileController>()
        ? MyProfileController.to
        : Get.put(MyProfileController(), permanent: true);
    controller.ensureControllersValid();

    return Scaffold(
      backgroundColor: AppColors.slateScaffold,
      body: Stack(
        children: [
          // Background Gym overlay image
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) =>
                  Container(color: const Color(0xFF0F262B)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE60D1E22),
                    Color(0xF210282E),
                    Color(0xFA0B1B1F),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar: < My Profiles
                _buildTopAppBar(context),

                // Main Scrollable Profile Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),

                            // Hero Title: My Profile & Manage your account
                            const Center(
                              child: Column(
                                children: [
                                  Text(
                                    'My Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Manage your account as your wish.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 1. User Profile Header Card (Avatar, Name, Verification, Status)
                            _buildProfileHeaderCard(context, controller),

                            const SizedBox(height: 14),

                            // 2. Active Membership Status Card (DRD 2.1)
                            _buildActiveMembershipStatusCard(controller),

                            const SizedBox(height: 18),

                            // 3. Settings Menu Card (Personal & Business, Financials, Trainers)
                            _buildSettingsMenuCard(context, controller),

                            const SizedBox(height: 22),

                            // 4. Logout Button (Outlined cyan/teal button)
                            _buildLogoutButton(context, controller),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Get.back();
              } else {
                Get.offAllNamed(AppRoutes.customerHome);
              }
            },
          ),
          const Expanded(
            child: Text(
              'My Profiles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard(
    BuildContext context,
    MyProfileController controller,
  ) {
    return Obx(() {
      final prof = controller.profile;
      final isVerified = prof.isVerified;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A42).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2E5762)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // User Avatar with edit pencil badge
            Stack(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF38808E),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: (prof.photoUrl != null && prof.photoUrl!.isNotEmpty)
                          ? (prof.photoUrl!.startsWith('assets/')
                              ? AssetImage(prof.photoUrl!) as ImageProvider
                              : NetworkImage(prof.photoUrl!))
                          : const AssetImage('assets/images/welcome_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const PersonalDetailsScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF38808E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Name and Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prof.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    prof.role,
                    style: const TextStyle(
                      color: AppColors.primaryBright,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Verified / Unverified pill badge
            GestureDetector(
              onTap: controller.profileService.toggleVerification,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFF1E5B2A)
                      : const Color(0xFF8F1E2A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.help_outline,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'Verified' : 'Unverified',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// DRD Active Membership Status Card
  Widget _buildActiveMembershipStatusCard(MyProfileController controller) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF14292E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF1B3D46),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_membership_rounded, color: AppColors.primaryBright, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ACTIVE MEMBERSHIP PLAN', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(controller.activePlanName.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    '${controller.remainingSessions.value} Sessions Left • Expires ${controller.expiryDate.value}',
                    style: const TextStyle(color: AppColors.primaryBright, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.membershipJoining),
              child: const Text('Upgrade', style: TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSettingsMenuCard(
    BuildContext context,
    MyProfileController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A42).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2E5762)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Personal & Business
          const Text(
            'Personal & Business',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF2E5762)),
          const SizedBox(height: 12),
          _buildMenuTile(
            icon: Icons.person_outline,
            title: 'Personal Details',
            onTap: () => Get.to(() => const PersonalDetailsScreen()),
          ),
          _buildMenuTile(
            icon: Icons.business_outlined,
            title: 'My Business Connects',
            onTap: () => Get.toNamed(AppRoutes.businessConnects),
          ),
          _buildMenuTile(
            icon: Icons.account_balance_outlined,
            title: 'Bank Account',
            onTap: () {
              if (Get.isRegistered<BankAccountController>()) {
                Get.find<BankAccountController>().setActiveTab(
                  AccountViewTab.bankAccount,
                );
              }
              Get.to(() => const BankAccountScreen());
            },
          ),
          _buildMenuTile(
            icon: Icons.sports_gymnastics,
            title: 'My Trainers',
            onTap: () => Get.toNamed(AppRoutes.myTrainers),
          ),
          _buildMenuTile(
            icon: Icons.card_membership,
            title: 'Membership Plans',
            onTap: () => Get.toNamed(AppRoutes.membershipPlansList),
          ),
          _buildMenuTile(
            icon: Icons.sync_alt,
            title: 'Transactions',
            onTap: () {
              if (Get.isRegistered<BankAccountController>()) {
                Get.find<BankAccountController>().setActiveTab(
                  AccountViewTab.transactions,
                );
              }
              Get.to(() => const BankAccountScreen());
            },
          ),
          _buildMenuTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Affiliation (What went wrong)',
            subtitle: 'Manage or cancel gym connection',
            onTap: () => controller.startDeleteAffiliationFlow('PowerFit Gym'),
          ),

          const SizedBox(height: 14),
          const Text(
            'My Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF2E5762)),
          const SizedBox(height: 8),

          // Promotional Message Consent Checkbox (AutoCheck)
          Obx(() {
            return Row(
              children: [
                Checkbox(
                  value: controller.promotionalConsent.value,
                  activeColor: AppColors.primaryBright,
                  checkColor: Colors.black,
                  onChanged: (val) => controller.promotionalConsent.value = val ?? false,
                ),
                const Expanded(
                  child: Text(
                    'Promotional Message Consent',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            );
          }),

          // Account Deactivation (30 days review)
          _buildMenuTile(
            icon: Icons.person_off_outlined,
            title: 'Deactivate Account',
            subtitle: 'Place account in 30-day review',
            onTap: controller.showAccountDeactivationDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF162D34),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A505A)),
              ),
              child: Center(child: Icon(icon, color: Colors.white70, size: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    MyProfileController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF38808E), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: controller.showLogoutConfirmationDialog,
        child: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
