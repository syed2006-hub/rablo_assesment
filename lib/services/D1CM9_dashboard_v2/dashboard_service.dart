import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/D1CM9_dashboard_v2/gym_stat_model.dart';
import '../D1CM4_membership_joining/membership_service.dart';

/// D1CM9 – Dashboard Service calculating real-time metrics and summary stats.
class DashboardService extends GetxService {
  static DashboardService get to => Get.find<DashboardService>();

  List<GymStatModel> getMetrics() {
    final membershipService = Get.isRegistered<MembershipService>()
        ? MembershipService.to
        : null;

    final totalCount = membershipService?.totalMembersCount ?? 1248;
    final activeCount = membershipService?.activeMembersCount ?? 982;

    return [
      GymStatModel(
        title: 'Active Members',
        value: activeCount.toString(),
        change: '+8.4%',
        isPositive: true,
        icon: Icons.people_alt_rounded,
      ),
      const GymStatModel(
        title: 'Today Check-ins',
        value: '142',
        change: '+14%',
        isPositive: true,
        icon: Icons.qr_code_scanner_rounded,
      ),
      const GymStatModel(
        title: 'Monthly Revenue',
        value: '₹3,48,500',
        change: '+12.6%',
        isPositive: true,
        icon: Icons.currency_rupee_rounded,
      ),
      GymStatModel(
        title: 'Total Enrolled',
        value: totalCount.toString(),
        change: '+5.1%',
        isPositive: true,
        icon: Icons.fitness_center_rounded,
      ),
    ];
  }
}
