import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'routes/app_pages.dart';

void main() {
  runApp(const FitnessApp());
}

/// Root widget of the application.
class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.white,
        ),
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
