import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/D1CM6_my_profile/my_profile_controller.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_selection_field.dart';
import '../../widgets/common_text_field.dart';

/// D1CM6 – Personal Details Screen.
/// Strictly implements Figma `personal_details.png` and `personal_details_bottom.png`.
class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

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
          // Background Trainer image with dark cyan gradient overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Container(color: const Color(0xFF0F262B)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xE60D1E22),
                    const Color(0xF210282E),
                    const Color(0xFA0B1B1F),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar: < My Profiles > Personal Details
                _buildTopAppBar(context),

                // Scrollable Form Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: _buildFormCard(context, controller),
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Text(
              'My Profiles > Personal Details',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Bell notification badge
          Container(
            decoration: BoxDecoration(
              color: AppColors.slateCardLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slateBorder),
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.badgeBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '4',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, MyProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A42).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2E5762)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Personal Details
          const Text(
            'Personal Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2E5762)),
          const SizedBox(height: 14),

          // 1. Full Name
          const Text(
            'Full Name',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          const Text(
            '(Auto-filled from social media login)',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
          CommonTextField(
            controller: controller.fullNameController,
            hintText: 'Enter your name',
            fillColor: const Color(0xFF162D34),
            textColor: Colors.white,
            borderColor: const Color(0xFF2A505A),
          ),

          const SizedBox(height: 16),

          // 2. Phone Number
          const Text(
            'Phone Number',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          CommonTextField(
            controller: controller.phoneController,
            hintText: '98765 - 43210',
            keyboardType: TextInputType.phone,
            prefixText: '+91 | ',
            prefixStyle: const TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.bold),
            fillColor: const Color(0xFF162D34),
            textColor: Colors.white,
            borderColor: const Color(0xFF2A505A),
          ),

          const SizedBox(height: 16),

          // 3. Select Gender
          const Text(
            'Select Gender',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: controller.genderOptions.map((g) {
                  final isSelected = controller.selectedGender.value == g;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.toggleGender(g),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBright.withValues(alpha: 0.15)
                              : const Color(0xFF162D34),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBright : const Color(0xFF2A505A),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryBright : Colors.white54,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryBright,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              g,
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryBright : Colors.white,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

          const SizedBox(height: 18),

          // 4. Upload Your Display Profile (Dashed container)
          const Text(
            'Upload Your Display Profile',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildUploadProfileBox(controller),

          const SizedBox(height: 18),

          // 5. Date of Birth
          const Text(
            'Date of Birth',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => controller.pickDateOfBirth(context),
            child: AbsorbPointer(
              child: CommonTextField(
                controller: controller.dobController,
                hintText: '09 - 11 - 2024',
                fillColor: const Color(0xFF162D34),
                textColor: Colors.white,
                borderColor: const Color(0xFF2A505A),
                suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.white70),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 6. What defines you best?
          const Text(
            'What defines you best?',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Obx(() => CommonSelectionField<String>(
                selectedValue: controller.selectedRole.value,
                options: controller.roleOptions,
                onChanged: (val) {
                  if (val != null) controller.selectedRole.value = val;
                },
                optionLabelBuilder: (item) => item,
                fillColor: const Color(0xFF162D34),
                textColor: Colors.white,
                borderColor: const Color(0xFF2A505A),
                dropdownColor: const Color(0xFF162D34),
              )),

          const SizedBox(height: 16),

          // 7. Address Line 1 (or PIN on map)
          const Text(
            'Address Line 1 (or PIN on map)',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          CommonTextField(
            controller: controller.addressLine1Controller,
            hintText: 'User input, Sample text',
            fillColor: const Color(0xFF162D34),
            textColor: Colors.white,
            borderColor: const Color(0xFF2A505A),
            suffixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryBright),
          ),

          const SizedBox(height: 16),

          // 8. Address Line 2 (Optional)
          const Text(
            'Address Line 2 (Optional)',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          CommonTextField(
            controller: controller.addressLine2Controller,
            hintText: 'Enter your colony or locality',
            fillColor: const Color(0xFF162D34),
            textColor: Colors.white,
            borderColor: const Color(0xFF2A505A),
          ),

          const SizedBox(height: 16),

          // 9. Country & State (Dual Column)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Country', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    CommonTextField(
                      controller: controller.countryController,
                      hintText: 'India',
                      readOnly: true,
                      fillColor: const Color(0xFF162D34),
                      textColor: Colors.white,
                      borderColor: const Color(0xFF2A505A),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('State', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Obx(() => CommonSelectionField<String>(
                          selectedValue: controller.selectedState.value,
                          options: controller.stateOptions,
                          onChanged: (val) {
                            if (val != null) controller.selectedState.value = val;
                          },
                          optionLabelBuilder: (item) => item,
                          fillColor: const Color(0xFF162D34),
                          textColor: Colors.white,
                          borderColor: const Color(0xFF2A505A),
                          dropdownColor: const Color(0xFF162D34),
                        )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 10. City & PIN Code (Dual Column)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('City', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    CommonTextField(
                      controller: controller.cityController,
                      hintText: 'Enter City',
                      fillColor: const Color(0xFF162D34),
                      textColor: Colors.white,
                      borderColor: const Color(0xFF2A505A),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PIN Code', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    CommonTextField(
                      controller: controller.pincodeController,
                      hintText: '560038',
                      keyboardType: TextInputType.number,
                      fillColor: const Color(0xFF162D34),
                      textColor: Colors.white,
                      borderColor: const Color(0xFF2A505A),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 11. Preferred Language (Optional)
          const Text(
            'Preferred Language (Optional)',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.languageOptions.map((lang) {
                  final isSelected = controller.selectedLanguages.contains(lang);
                  return GestureDetector(
                    onTap: () => controller.toggleLanguage(lang),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBright.withValues(alpha: 0.2)
                            : const Color(0xFF162D34),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBright : const Color(0xFF2A505A),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        lang,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryBright : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

          const SizedBox(height: 20),

          // 12. Terms & Conditions
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => Checkbox(
                    value: controller.agreeToTerms.value,
                    onChanged: (val) => controller.agreeToTerms.value = val ?? false,
                    activeColor: AppColors.primaryBright,
                    checkColor: Colors.black,
                  )),
              const Expanded(
                child: Text(
                  "By clicking the Update button, you'll agree to the T&C.",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 13. Update Button (Figma Vivid Bright Green)
          CommonButton(
            text: 'Update',
            backgroundColor: AppColors.primaryBright,
            textColor: Colors.black,
            height: 52,
            onPressed: controller.savePersonalDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProfileBox(MyProfileController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF162D34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A505A),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          // Open Camera Button
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBright,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => controller.simulateUploadPhoto('Camera'),
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Open Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),

          const SizedBox(height: 8),

          const Text('Or', style: TextStyle(color: Colors.white60, fontSize: 12)),

          const SizedBox(height: 4),

          GestureDetector(
            onTap: () => controller.simulateUploadPhoto('Gallery'),
            child: const Text(
              'Choose from Gallery',
              style: TextStyle(
                color: AppColors.primaryBright,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryBright,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
