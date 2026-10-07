import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/D1CM4_membership_joining/membership_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_list_item.dart';
import '../../widgets/common_search_field.dart';
import '../../widgets/common_section_header.dart';
import '../../widgets/common_status_chip.dart';
import '../../widgets/common_tab_selector.dart';

/// D1CM4 – Membership List Screen showcasing member directories, search, and category filters.
class MembershipListScreen extends StatelessWidget {
  const MembershipListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MembershipController controller = Get.put(MembershipController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'D1CM4 – Member Directory & Plans',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryBright),
            tooltip: 'Register New Member',
            onPressed: () => Get.toNamed(AppRoutes.forms),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    AppConstants.defaultPadding,
                    AppConstants.defaultPadding,
                    4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonSectionHeader(
                        title: 'Gym Members Directory',
                        subtitle:
                            'Search, filter status, inspect profiles, and manage subscription renewals',
                      ),
                      const SizedBox(height: 8),
                      // Search Bar
                      CommonSearchField(
                        controller: controller.searchController,
                        hintText: 'Search by member name, phone, or plan...',
                        onChanged: controller.onSearchChanged,
                      ),
                      const SizedBox(height: 12),
                      // Category Filter Tabs
                      Obx(
                        () => CommonTabSelector(
                          tabs: controller.filterTabs,
                          selectedIndex: controller.selectedFilterIndex.value,
                          onTabSelected: controller.onFilterTabSelected,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Dynamic Member Cards List
                Expanded(
                  child: Obx(() {
                    final members = controller.filteredMembers;

                    if (members.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: AppColors.lightGrey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No members found for "${controller.searchQuery.value}"',
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.defaultPadding,
                        4,
                        AppConstants.defaultPadding,
                        AppConstants.defaultPadding,
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];

                        return CommonListItem(
                          title: member.name,
                          subtitle: '${member.planName} • ID: ${member.id}',
                          leading: CircleAvatar(
                            backgroundColor: member.isActive
                                ? AppColors.primary
                                : (member.isExpiring
                                    ? AppColors.rushYellow
                                    : AppColors.lightGrey),
                            foregroundColor: member.isActive
                                ? AppColors.dark
                                : AppColors.white,
                            radius: 20,
                            child: Text(
                              member.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CommonStatusChip(
                                status: member.status,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () =>
                              controller.selectMemberAndOpenDetail(member),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
