import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/D1CM2_account_creation/account_creation_controller.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_container.dart';
import '../../widgets/common_text_field.dart';

/// D1CM2 – Account Creation & Onboarding Screen.
/// Strictly implements the DRD requirements for Customer Account Creation:
/// - Full Name (Auto-filled from social media login)
/// - Profile Picture (Auto-filled / editable)
/// - Contact Number (Required, 18+ check)
/// - Gender (Male, Female, Other)
/// - Date of Birth (Required)
/// - Profession (Single-Select Tabs: Student, Employed, HomeMaker, Retired, Business Person)
/// - Objectives (Checkboxes for 12 fitness objectives)
/// - Personal Address (Address 1, City, State, Country, PIN Code, Address 2)
/// - Language Preference (Dropdown / Selection chips)
/// - Terms & Conditions & Promotional Consent
/// - Submit Button ("Create Account")
class AccountCreationFormScreen extends StatelessWidget {
  const AccountCreationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountCreationController controller =
        Get.put(AccountCreationController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Trainer Photo strictly matching Figma
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (ctx, err, stack) => Container(
              color: const Color(0xFF102124),
              child: const Center(
                child: Icon(Icons.fitness_center,
                    size: 80, color: AppColors.primaryLight),
              ),
            ),
          ),

          // Deep Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.65),
                  Colors.black.withValues(alpha: 0.95),
                  Colors.black,
                ],
                stops: const [0.0, 0.25, 0.45, 0.75, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Scrollable Account Creation Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section matching Figma & DRD typography
                      const SizedBox(height: 12),
                      const Text(
                        "Let's begin!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Create your account to start your journey.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Glassmorphic Card Container
                      CommonContainer(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF22444C),
                              Color(0xFF142B31),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Picture Avatar (DRD 2.1)
                              Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: const Color(0xFF1D3B42),
                                      child: const Icon(Icons.person, size: 44, color: AppColors.primaryLight),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryBright,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // 1. Full Name (Auto-filled from social media login)
                              _buildFieldLabel('Full Name'),
                              CommonTextField(
                                controller: controller.fullNameController,
                                hintText: '(Auto-filled from social media login)',
                                fillColor: const Color(0xFF284E56),
                                textColor: Colors.white,
                                hintColor: Colors.white54,
                                borderColor: Colors.white12,
                                borderRadius: 12,
                              ),
                              const SizedBox(height: 16),

                              // 2. Contact / Phone Number (Required, Min age 18+)
                              _buildFieldLabelWithNote('Phone Number', '(Required, Min age 18+)'),
                              CommonTextField(
                                controller: controller.phoneController,
                                hintText: 'Enter mobile number',
                                keyboardType: TextInputType.phone,
                                prefixText: '+91  |  ',
                                prefixStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                fillColor: const Color(0xFF284E56),
                                textColor: Colors.white,
                                hintColor: Colors.white38,
                                borderColor: Colors.white12,
                                borderRadius: 12,
                              ),
                              const SizedBox(height: 16),

                              // 3. Select Gender (Male, Female, Other - Required)
                              _buildFieldLabel('Select Gender'),
                              Obx(
                                () => Row(
                                  children: controller.genderOptions.map((gender) {
                                    final isSelected =
                                        controller.selectedGender.value == gender;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: InkWell(
                                          onTap: () =>
                                              controller.toggleGender(gender),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 11),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF1D3B42)
                                                  : const Color(0xFF284E56),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryBright
                                                    : Colors.white12,
                                                width: isSelected ? 1.5 : 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isSelected
                                                      ? Icons.radio_button_checked
                                                      : Icons.radio_button_off,
                                                  color: isSelected
                                                      ? AppColors.primaryBright
                                                      : Colors.white54,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  gender,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 4. Date of Birth (Date input, Required, Must be 18+)
                              _buildFieldLabelWithNote('Date of Birth', '(Must be 18+)'),
                              CommonTextField(
                                controller: controller.dobController,
                                readOnly: true,
                                onTap: controller.openCalendarDialog,
                                hintText: 'DD - MM - YYYY',
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  onPressed: controller.openCalendarDialog,
                                ),
                                fillColor: const Color(0xFF284E56),
                                textColor: Colors.white,
                                hintColor: Colors.white54,
                                borderColor: Colors.white12,
                                borderRadius: 12,
                              ),
                              const SizedBox(height: 16),

                              // 5. Profession (DRD 2.1 Single-Select Tabs, Required)
                              _buildFieldLabelWithNote('Profession', '(Single-Select Tabs, Required)'),
                              Obx(
                                () => SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: controller.professionOptions.map((prof) {
                                      final isSelected =
                                          controller.selectedProfession.value == prof;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: InkWell(
                                          onTap: () => controller.selectProfession(prof),
                                          borderRadius: BorderRadius.circular(20),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryBright
                                                  : const Color(0xFF284E56),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryBright
                                                    : Colors.white12,
                                              ),
                                            ),
                                            child: Text(
                                              prof,
                                              style: TextStyle(
                                                color: isSelected ? Colors.black : Colors.white,
                                                fontSize: 13,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 6. Objective (DRD 2.1 Checkbox, Required)
                              _buildFieldLabelWithNote(
                                  'Objective', '(Checkbox, Required)'),
                              Obx(() {
                                final selectedList =
                                    controller.selectedObjectives.toList();
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 8,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 3.2,
                                  ),
                                  itemBuilder: (context, index) {
                                    if (index == 7) {
                                      // "See all.." Capsule
                                      return InkWell(
                                        onTap: controller.openObjectivesModal,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1D3B42),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: AppColors.primaryBright,
                                                width: 1),
                                          ),
                                          child: const Text(
                                            'See all..',
                                            style: TextStyle(
                                              color: AppColors.primaryBright,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final objective =
                                        controller.primaryObjectives[index];
                                    final isSelected =
                                        selectedList.contains(objective);

                                    return InkWell(
                                      onTap: () =>
                                          controller.toggleObjective(objective),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF1D3B42)
                                              : const Color(0xFF284E56),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryBright
                                                : Colors.white12,
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          objective,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                              const SizedBox(height: 16),

                              // 7. Personal Address (DRD 2.1 Text area, Optional)
                              _buildFieldLabelWithNote(
                                  'Personal Address', '(Optional)'),
                              CommonTextField(
                                controller: controller.address1Controller,
                                hintText: 'Enter or Pin the Address',
                                suffixIcon: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                fillColor: const Color(0xFF284E56),
                                textColor: Colors.white,
                                hintColor: Colors.white54,
                                borderColor: Colors.white12,
                                borderRadius: 12,
                              ),
                              const SizedBox(height: 14),

                              // 8. City & State (Side-by-side)
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildFieldLabel('City'),
                                        CommonTextField(
                                          controller: controller.cityController,
                                          hintText: 'Enter City',
                                          fillColor: const Color(0xFF284E56),
                                          textColor: Colors.white,
                                          hintColor: Colors.white54,
                                          borderColor: Colors.white12,
                                          borderRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildFieldLabel('State'),
                                        CommonTextField(
                                          controller: controller.stateController,
                                          hintText: 'Enter State',
                                          fillColor: const Color(0xFF284E56),
                                          textColor: Colors.white,
                                          hintColor: Colors.white54,
                                          borderColor: Colors.white12,
                                          borderRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // 9. Country & PIN Code
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildFieldLabel('Country'),
                                        CommonTextField(
                                          controller:
                                              controller.countryController,
                                          hintText: 'Enter Country',
                                          fillColor: const Color(0xFF284E56),
                                          textColor: Colors.white,
                                          hintColor: Colors.white54,
                                          borderColor: Colors.white12,
                                          borderRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildFieldLabel('PIN Code'),
                                        CommonTextField(
                                          controller:
                                              controller.pinCodeController,
                                          hintText: '------',
                                          keyboardType: TextInputType.number,
                                          fillColor: const Color(0xFF284E56),
                                          textColor: Colors.white,
                                          hintColor: Colors.white54,
                                          borderColor: Colors.white12,
                                          borderRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // 10. Address Line 2
                              _buildFieldLabelWithNote(
                                  'Address Line 2', '(Optional)'),
                              CommonTextField(
                                controller: controller.address2Controller,
                                hintText: 'Enter your colony or locality',
                                fillColor: const Color(0xFF284E56),
                                textColor: Colors.white,
                                hintColor: Colors.white54,
                                borderColor: Colors.white12,
                                borderRadius: 12,
                              ),
                              const SizedBox(height: 16),

                              // 11. Language Preference (DRD 2.1 Dropdown / Selection, Optional)
                              _buildFieldLabelWithNote(
                                  'Language Preference', '(Optional)'),
                              Obx(() {
                                final selectedLangs =
                                    controller.selectedLanguages.toList();
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: controller.languageOptions.map((lang) {
                                    final isSelected =
                                        selectedLangs.contains(lang);
                                    return InkWell(
                                      onTap: () =>
                                          controller.toggleLanguage(lang),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF1D3B42)
                                              : const Color(0xFF284E56),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryBright
                                                : Colors.white12,
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          lang,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }),
                              const SizedBox(height: 20),

                              // 12. Terms & Conditions (DRD 2.1 Checkbox, Required)
                              Obx(
                                () => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: controller.acceptedTerms.value,
                                        activeColor: AppColors.primaryBright,
                                        checkColor: Colors.black,
                                        side: const BorderSide(
                                            color: Colors.white54, width: 1.5),
                                        onChanged: (val) {
                                          controller.acceptedTerms.value =
                                              val ?? false;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'I accept the terms and conditions and acknowledge that I have read and agree to abide by the company\'s policies and guidelines.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Promotional Consent Checkbox
                              Obx(
                                () => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: controller
                                            .promotionalConsent.value,
                                        activeColor: AppColors.primaryBright,
                                        checkColor: Colors.black,
                                        side: const BorderSide(
                                            color: Colors.white54, width: 1.5),
                                        onChanged: (val) {
                                          controller.promotionalConsent.value =
                                              val ?? false;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'I give consent to receive promotional communications from the company.',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 12,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 13. Submit Button (DRD 2.1 Action Button)
                              Obx(
                                () => CommonButton(
                                  text: 'Create Account',
                                  height: 52,
                                  borderRadius: 14,
                                  backgroundColor: AppColors.primaryBright,
                                  textColor: Colors.black,
                                  isLoading: controller.isLoading.value,
                                  onPressed: controller.submitAccountCreation,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFieldLabelWithNote(String label, String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              note,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
