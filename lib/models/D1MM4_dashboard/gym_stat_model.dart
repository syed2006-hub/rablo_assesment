import 'package:flutter/material.dart';

/// D1MM4 – Gym Stat KPI Model.
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
