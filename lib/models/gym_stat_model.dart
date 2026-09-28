import 'package:flutter/material.dart';

/// Represents a KPI metric displayed on the dashboard or profile.
class GymStatModel {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  const GymStatModel({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });
}
