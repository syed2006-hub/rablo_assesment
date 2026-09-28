import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/D1MM5_my_profile/my_profile_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_container.dart';
import '../../widgets/common_detail_row.dart';
import '../../widgets/common_section_header.dart';
import '../../widgets/common_stat_card.dart';

/// D1MM5 – My Profile Screen for gym administrator / master trainer profile.
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MyProfileController controller = Get.put(MyProfileController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'D1MM5 – User & Staff Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.white),
            tooltip: 'Settings',
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Profile Header Hero
                  GetBuilder<MyProfileController>(
                    builder: (_) {
                      final profile = controller.profile;
                      return CommonContainer(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.dark,
                              child: Text(
                                profile.fullName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBright,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile.fullName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.role,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF558B2F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.gymBranch,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Performance Stats
                  Row(
                    children: const [
                      Expanded(
                        child: CommonStatCard(
                          title: 'Workouts Supervised',
                          value: '1,420+',
                          icon: Icons.sports_gymnastics_rounded,
                          changeText: 'Top 5%',
                          isPositive: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: CommonStatCard(
                          title: 'Trainer Rating',
                          value: '4.9 / 5.0',
                          icon: Icons.star_rounded,
                          changeText: '98 Reviews',
                          isPositive: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Credentials & Details Table
                  const CommonSectionHeader(
                    title: 'Account Information',
                    subtitle: 'Verified credentials and branch authorizations',
                  ),
                  GetBuilder<MyProfileController>(
                    builder: (_) {
                      final profile = controller.profile;
                      return CommonContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonDetailRow(
                              label: 'Staff ID',
                              value: profile.id,
                              icon: Icons.badge_outlined,
                            ),
                            CommonDetailRow(
                              label: 'Email',
                              value: profile.email,
                              icon: Icons.email_outlined,
                            ),
                            CommonDetailRow(
                              label: 'Phone Number',
                              value: profile.phoneNumber,
                              icon: Icons.phone_outlined,
                            ),
                            CommonDetailRow(
                              label: 'Branch Location',
                              value: profile.gymBranch,
                              icon: Icons.location_on_outlined,
                            ),
                            CommonDetailRow(
                              label: 'Member Since',
                              value:
                                  '${profile.memberSince.day}/${profile.memberSince.month}/${profile.memberSince.year}',
                              icon: Icons.calendar_month_outlined,
                            ),
                            CommonDetailRow(
                              label: 'Professional Bio',
                              value: profile.bio,
                              icon: Icons.description_outlined,
                              showDivider: false,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // 4. Edit Profile Button
                  CommonButton(
                    text: '✏️ Edit Profile Details',
                    onPressed: controller.openEditProfileDialog,
                  ),
                  const SizedBox(height: 10),
                  CommonButton(
                    text: '⚙️ Open Settings',
                    backgroundColor: AppColors.backgroundLight,
                    textColor: AppColors.dark,
                    onPressed: () => Get.toNamed(AppRoutes.settings),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
