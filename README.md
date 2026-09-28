# fitness_app_clean

**Project Type**: Flutter Mobile Application  
**Purpose**: Gym / Fitness Membership Management System  
**Internship**: Rablo Internship Project – Day 4 (Project Structure & Reusable Components)  
**State Management**: GetX  

---

## 1. Project Overview

`fitness_app_clean` is a modular Flutter application built as the foundation for the Rablo Internship Gym / Fitness Membership Management System. The architecture strictly separates concerns among screens, controllers, reusable widgets, data models, services, repositories, and API modules.

---

## 2. Directory Structure

```
fitness_app_clean/
│
├── assets/
│   ├── images/
│   └── icons/
│
├── lib/
│   ├── core/
│   │   └── common/
│   │
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   │
│   ├── models/
│   │
│   ├── services/
│   │
│   ├── repositories/
│   │
│   ├── screens/
│   │   ├── widget_screen.dart
│   │   └── login_screen.dart
│   │
│   ├── widgets/
│   │   ├── common_app_bar.dart
│   │   ├── common_button.dart
│   │   ├── common_container.dart
│   │   ├── common_popup.dart
│   │   ├── common_section_header.dart
│   │   ├── common_selection_field.dart
│   │   └── common_text_field.dart
│   │
│   ├── controllers/
│   │   ├── widget_controller.dart
│   │   └── login_controller.dart
│   │
│   ├── utils/
│   │   └── validators.dart
│   │
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   │
│   ├── api/
│   │   ├── D1CM1_login/
│   │   │   └── login_api.dart
│   │   ├── D1MM2_account_creation/
│   │   │   └── account_creation_api.dart
│   │   ├── D1MM3_membership_planning/
│   │   │   └── membership_planning_api.dart
│   │   ├── D1MM4_dashboard/
│   │   │   └── dashboard_api.dart
│   │   ├── D1MM5_my_profile/
│   │   │   └── my_profile_api.dart
│   │   ├── D1CC6_attendance/
│   │   │   └── attendance_api.dart
│   │   ├── D1MM8_webpage_creation/
│   │   │   └── webpage_creation_api.dart
│   │   └── D1MM9_kyc/
│   │       └── kyc_api.dart
│   │
│   └── main.dart
│
├── android/
├── ios/
├── web/
├── pubspec.yaml
└── README.md
```

---

## 3. Application Modules Identified

The project structure accommodates the following planned modules:

- **D1CM1**: Login (Google Customer, Google Android, Facebook Customer, LinkedIn Customer)
- **D1MM2**: Account Creation & **D1MM2.2**: Business Account Creation
- **D1MM3**: Membership Planning
- **D1MM4**: Dashboard V1
- **D1MM5**: My Profile
- **D1CC6**: Attendance Verification & Monitoring
- **D1MM8**: Online Webpage Creation & **D1MM8.2**: Webpage Template
- **D1MM9**: KYC Verification
- **D1MM10**: Dashboard V2

---

## 4. Reusable UI Components (`lib/widgets/`)

1. **`CommonButton`**: Standardized button with loading state indicator, customizable colors, and disabled state support.
2. **`CommonTextField`**: Form text input with centralized styling, error states, and obscure-text toggle.
3. **`CommonSelectionField<T>`**: Dropdown selection widget matching text field design specifications.
4. **`CommonContainer`**: Card-like surface container for modular content grouping.
5. **`CommonPopup`**: Modal alert dialog with title, custom content/actions, and a static `show()` helper.

---

## 5. Design System Colors (`lib/constants/app_colors.dart`)

Derived from the project Figma specifications:

- **Primary Green**: `#93CB1B` (`AppColors.primary`)
- **Bright Green**: `#B8FE22` (`AppColors.primaryBright`)
- **Light Green**: `#CEFF65` (`AppColors.primaryLight`)
- **Very Light Green**: `#E3FFA7` (`AppColors.veryLightGreen`)
- **Light Neutral / Background**: `#EDE7FF` (`AppColors.backgroundLight`)
- **Grey**: `#7A7A7A` (`AppColors.grey`)
- **Dark**: `#1E1E1E` (`AppColors.dark`)

---

## 6. Verification & Running

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis
dart analyze

# 3. Run widget tests
flutter test

# 4. Launch the application
flutter run
```
