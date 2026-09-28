# fitness_app_clean

**Project Type**: Flutter Mobile Application  
**Purpose**: Gym / Fitness Membership Management System  
**Internship**: Rablo Internship Project – Day 5 (Screen & Component Development + Firebase Integration)  
**State Management**: GetX  
**Backend**: Firebase (Core & Authentication configured with safe offline fallback)  

---

## 1. Project Overview

`fitness_app_clean` is a modular Flutter application built for the Rablo Internship Gym / Fitness Membership Management System.

In **Day 5**, the project has been architected following the assigned module code words (`D1CM1`, `D1MM2`, `D1MM3`, `D1MM4`, `D1MM5`, `D1CC6`, etc.) across **Screens**, **Controllers**, **Models**, **Services**, and **API** layers.

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
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   │
│   ├── firebase_options.dart
│   ├── main.dart
│   │
│   ├── models/
│   │   ├── D1CM1_login/
│   │   │   └── user_model.dart
│   │   ├── D1MM2_account_creation/
│   │   │   └── account_model.dart
│   │   ├── D1MM3_membership_planning/
│   │   │   ├── member_model.dart
│   │   │   └── membership_plan_model.dart
│   │   ├── D1MM4_dashboard/
│   │   │   └── gym_stat_model.dart
│   │   ├── D1MM5_my_profile/
│   │   │   └── profile_model.dart
│   │   └── D1CC6_attendance/
│   │       └── attendance_record_model.dart
│   │
│   ├── services/
│   │   ├── D1CM1_login/
│   │   │   └── firebase_auth_service.dart
│   │   ├── D1MM2_account_creation/
│   │   │   └── account_creation_service.dart
│   │   ├── D1MM3_membership_planning/
│   │   │   └── membership_service.dart
│   │   ├── D1MM4_dashboard/
│   │   │   └── dashboard_service.dart
│   │   ├── D1MM5_my_profile/
│   │   │   └── profile_service.dart
│   │   └── D1CC6_attendance/
│   │       └── attendance_service.dart
│   │
│   ├── controllers/
│   │   ├── D1CM1_login/
│   │   │   ├── login_controller.dart
│   │   │   └── signup_controller.dart
│   │   ├── D1MM2_account_creation/
│   │   │   └── account_creation_controller.dart
│   │   ├── D1MM3_membership_planning/
│   │   │   └── membership_controller.dart
│   │   ├── D1MM4_dashboard/
│   │   │   └── dashboard_controller.dart
│   │   ├── D1MM5_my_profile/
│   │   │   └── my_profile_controller.dart
│   │   ├── D1CC6_attendance/
│   │   │   └── attendance_controller.dart
│   │   ├── home/
│   │   │   └── home_controller.dart
│   │   ├── settings/
│   │   │   └── settings_controller.dart
│   │   └── widget_controller.dart
│   │
│   ├── screens/
│   │   ├── D1CM1_login/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── D1MM2_account_creation/
│   │   │   └── account_creation_form_screen.dart
│   │   ├── D1MM3_membership_planning/
│   │   │   ├── membership_list_screen.dart
│   │   │   └── membership_detail_screen.dart
│   │   ├── D1MM4_dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── D1MM5_my_profile/
│   │   │   └── my_profile_screen.dart
│   │   ├── D1CC6_attendance/
│   │   │   └── attendance_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   └── widget_screen.dart
│   │
│   ├── widgets/
│   │   ├── common_app_bar.dart
│   │   ├── common_button.dart
│   │   ├── common_container.dart
│   │   ├── common_detail_row.dart
│   │   ├── common_list_item.dart
│   │   ├── common_popup.dart
│   │   ├── common_search_field.dart
│   │   ├── common_section_header.dart
│   │   ├── common_selection_field.dart
│   │   ├── common_stat_card.dart
│   │   ├── common_status_chip.dart
│   │   ├── common_switch_tile.dart
│   │   ├── common_tab_selector.dart
│   │   └── common_text_field.dart
│   │
│   ├── api/
│   │   ├── D1CM1_login/login_api.dart
│   │   ├── D1MM2_account_creation/account_creation_api.dart
│   │   ├── D1MM3_membership_planning/membership_planning_api.dart
│   │   ├── D1MM4_dashboard/dashboard_api.dart
│   │   ├── D1MM5_my_profile/my_profile_api.dart
│   │   ├── D1CC6_attendance/attendance_api.dart
│   │   ├── D1MM8_webpage_creation/webpage_creation_api.dart
│   │   └── D1MM9_kyc/kyc_api.dart
│   │
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   │
│   └── utils/
│       └── validators.dart
│
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

---

## 3. Day 5 Application Screens Implemented

1. **`LoginScreen` & `SignupScreen` (`D1CM1_login`)**: Firebase authentication + mock validation fallback, credentials verification, terms toggle, password visibility switcher.
2. **`HomeScreen` (`home`)**: Modern NavigationBar hosting the multi-screen experience.
3. **`DashboardScreen` (`D1MM4_dashboard`)**: Live KPI metrics (Active Members, Today Check-ins, Revenue, Enrollment), quick desk actions (Check-In Pass, Add Member, Attendance Logs), and recent turnstile feed.
4. **`AccountCreationFormScreen` (`D1MM2_account_creation`)**: Individual & D1MM2.2 Business account creation forms with validation, dropdown selectors, and auto-renew switches.
5. **`MembershipListScreen` (`D1MM3_membership_planning`)**: Member directory with search filtering and category tab selectors (All, Active, Expiring, Inactive).
6. **`MembershipDetailScreen` (`D1MM3_membership_planning`)**: Complete member subscription profile, attendance streak, QR access pass, and membership renewal popup.
7. **`MyProfileScreen` (`D1MM5_my_profile`)**: Staff administrator profile with supervised workout stats, trainer ratings, and profile edit dialog.
8. **`AttendanceScreen` (`D1CC6_attendance`)**: Real-time attendance verification ledger and manual check-in recorder.
9. **`SettingsScreen` (`settings`)**: Firebase sync status (Project: `rablo-rablo`), notifications toggle, biometric lock, and secure sign-out.
10. **`WidgetScreen` (`lib/screens/widget_screen.dart`)**: Comprehensive showcase of all 14 reusable components.

---

## 4. Reusable UI Components (`lib/widgets/`)

1. **`CommonAppBar`**: Brand header with dark surface & green accent styling.
2. **`CommonButton`**: Modular button supporting active, disabled, loading, and custom palettes.
3. **`CommonContainer`**: Centralized elevated card surface.
4. **`CommonPopup`**: Modal alert dialog with title, custom content/actions, and a static `show()` helper.
5. **`CommonSectionHeader`**: Standardized title/subtitle typography hierarchy.
6. **`CommonSelectionField<T>`**: Generic dropdown selection widget with label, validation, and error states.
7. **`CommonTextField`**: Form text input with prefixes, suffixes, and validator hooks.
8. **`CommonStatCard`**: KPI metric card with icons and percentage trend indicators.
9. **`CommonStatusChip`**: Dynamic status pill mapping for Active, Expiring, and Inactive states.
10. **`CommonListItem`**: Standardized list tile with avatar, title, subtitle, and trailing action/chip.
11. **`CommonSearchField`**: Search input with integrated clear action.
12. **`CommonDetailRow`**: Key-value row component for detail and profile views.
13. **`CommonSwitchTile`**: Switch setting tile with brand green active track.
14. **`CommonTabSelector`**: Pill-style filter bar with animated selection highlight.

---

## 5. Design System Colors (`lib/constants/app_colors.dart`)

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
