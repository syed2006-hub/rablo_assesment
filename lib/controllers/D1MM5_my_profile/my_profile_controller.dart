import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1MM5_my_profile/profile_model.dart';
import '../../services/D1MM5_my_profile/profile_service.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_popup.dart';
import '../../widgets/common_text_field.dart';

/// D1MM5 – Profile Controller managing user profile, credentials, and gym branches.
class MyProfileController extends GetxController {
  final ProfileService _profileService = Get.put(ProfileService());

  ProfileModel get profile => _profileService.profile.value;

  final TextEditingController nameEditController = TextEditingController();
  final TextEditingController phoneEditController = TextEditingController();
  final TextEditingController branchEditController = TextEditingController();

  void openEditProfileDialog() {
    nameEditController.text = profile.fullName;
    phoneEditController.text = profile.phoneNumber;
    branchEditController.text = profile.gymBranch;

    CommonPopup.show(
      title: 'Edit Gym Profile',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonTextField(
              controller: nameEditController,
              label: 'Full Name',
            ),
            const SizedBox(height: 12),
            CommonTextField(
              controller: phoneEditController,
              label: 'Phone Number',
            ),
            const SizedBox(height: 12),
            CommonTextField(
              controller: branchEditController,
              label: 'Gym Branch / Center',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
        ),
        CommonButton(
          text: 'Save Changes',
          width: 140,
          height: 42,
          onPressed: () {
            final updated = profile.copyWith(
              fullName: nameEditController.text.trim(),
              phoneNumber: phoneEditController.text.trim(),
              gymBranch: branchEditController.text.trim(),
            );
            _profileService.updateProfile(updated);
            Get.back();
            Get.snackbar(
              'Profile Updated',
              'Gym profile details saved successfully.',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          },
        ),
      ],
    );
  }

  @override
  void onClose() {
    nameEditController.dispose();
    phoneEditController.dispose();
    branchEditController.dispose();
    super.onClose();
  }
}
