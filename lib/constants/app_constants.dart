/// Centralized application constants used across modules.
class AppConstants {
  AppConstants._();

  static const String appName = 'Fitness App';

  // API Base URLs
  static const String apiBaseUrlDev = 'http://localhost:6500';
  static const String apiBaseUrlProd = 'https://membes.shop';

  // Active Base URL (Development environment by default)
  static const String apiBaseUrl = apiBaseUrlDev;

  // Layout metrics
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}
