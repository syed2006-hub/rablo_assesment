import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

enum RushIntensity { low, medium, peak }

/// D1CM9 – Data model representing a single hour bar in the Rush Hours Indicator.
class RushHourDataPoint {
  final String timeLabel;
  final double occupancyPercentage;
  final RushIntensity intensity;

  RushHourDataPoint({
    required this.timeLabel,
    required this.occupancyPercentage,
    required this.intensity,
  });

  Color get barColor {
    switch (intensity) {
      case RushIntensity.low:
        return AppColors.rushGreen;
      case RushIntensity.medium:
        return AppColors.rushYellow;
      case RushIntensity.peak:
        return AppColors.peakRed;
    }
  }

  /// Default 13 hourly points matching Figma Rush Hours Indicator:
  /// 00:00, 1:00, 2:00, 3:00, 4:00, 5:00, 6:00, 7:00, 8:00, 9:00, 10:00, 11:00, 12:00
  static List<RushHourDataPoint> getSampleData() {
    return [
      RushHourDataPoint(timeLabel: '00:00', occupancyPercentage: 8, intensity: RushIntensity.low),
      RushHourDataPoint(timeLabel: '1:00', occupancyPercentage: 6, intensity: RushIntensity.low),
      RushHourDataPoint(timeLabel: '2:00', occupancyPercentage: 5, intensity: RushIntensity.low),
      RushHourDataPoint(timeLabel: '3:00', occupancyPercentage: 12, intensity: RushIntensity.low),
      RushHourDataPoint(timeLabel: '4:00', occupancyPercentage: 20, intensity: RushIntensity.low),
      RushHourDataPoint(timeLabel: '5:00', occupancyPercentage: 35, intensity: RushIntensity.low),
      RushHourDataPoint(timeLabel: '6:00', occupancyPercentage: 55, intensity: RushIntensity.medium),
      RushHourDataPoint(timeLabel: '7:00', occupancyPercentage: 78, intensity: RushIntensity.medium),
      RushHourDataPoint(timeLabel: '8:00', occupancyPercentage: 96, intensity: RushIntensity.peak),
      RushHourDataPoint(timeLabel: '9:00', occupancyPercentage: 90, intensity: RushIntensity.peak),
      RushHourDataPoint(timeLabel: '10:00', occupancyPercentage: 62, intensity: RushIntensity.medium),
      RushHourDataPoint(timeLabel: '11:00', occupancyPercentage: 42, intensity: RushIntensity.low),
      RushHourDataPoint(timeLabel: '12:00', occupancyPercentage: 30, intensity: RushIntensity.low),
    ];
  }
}
