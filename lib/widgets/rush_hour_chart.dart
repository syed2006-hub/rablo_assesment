import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/D1CM9_dashboard_v2/rush_hour_model.dart';

class RushHourChartWidget extends StatefulWidget {
  final List<RushHourDataPoint> points;
  final RushHourDataPoint? selectedPoint;
  final ValueChanged<RushHourDataPoint>? onPointSelected;

  const RushHourChartWidget({
    super.key,
    required this.points,
    this.selectedPoint,
    this.onPointSelected,
  });

  @override
  State<RushHourChartWidget> createState() => _RushHourChartWidgetState();
}

class _RushHourChartWidgetState extends State<RushHourChartWidget> {
  late RushHourDataPoint? _currentSelected;

  @override
  void initState() {
    super.initState();
    _currentSelected = widget.selectedPoint;
  }

  @override
  void didUpdateWidget(covariant RushHourChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPoint != oldWidget.selectedPoint) {
      _currentSelected = widget.selectedPoint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Real-time Bar Graph
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: widget.points.map((pt) {
              final isSelected = _currentSelected?.timeLabel == pt.timeLabel;
              final heightFraction = (pt.occupancyPercentage / 100).clamp(0.08, 1.0);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentSelected = pt);
                    widget.onPointSelected?.call(pt);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: pt.barColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${pt.occupancyPercentage.toInt()}%',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 70 * heightFraction,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            color: pt.barColor,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: pt.barColor.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Time label
                        Text(
                          pt.timeLabel,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.greyMuted,
                            fontSize: 8.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Peak Rush Hour Banner matching Figma
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF4C1D24).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.peakRed.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.peakRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.access_time_filled, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '8:00 AM — 9:00 AM ',
                    style: TextStyle(
                      color: AppColors.peakRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: 'Peak Rush Hour (Yesterday)',
                        style: TextStyle(
                          color: AppColors.greyMuted,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
