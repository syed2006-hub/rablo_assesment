import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/D1MM3_membership_planning/membership_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_container.dart';
import '../../widgets/common_list_item.dart';
import '../../widgets/common_search_field.dart';
import '../../widgets/common_section_header.dart';
import '../../widgets/common_status_chip.dart';
import '../../widgets/common_tab_selector.dart';

/// D1MM3 – Membership List Screen showcasing member directories, search, and category filters.
class MembershipListScreen extends StatelessWidget {
  const MembershipListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MembershipController controller = Get.put(MembershipController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'D1MM3 – Member Directory & Plans',
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
                        onChanged: controller.onSearchChanged,
                      ),
                      const SizedBox(height: 6),
                      // Tab Filters
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

                // Members List View
                Expanded(
                  child: Obx(() {
                    final members = controller.filteredMembers;

                    if (members.isEmpty) {
                      return Center(
                        child: CommonContainer(
                          margin: const EdgeInsets.all(AppConstants.defaultPadding),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No members found matching the criteria.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Try clearing the search query or changing filter tabs.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: 8,
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return CommonListItem(
                          title: member.name,
                          subtitle:
                              '${member.id} • ${member.planName} • ${member.phone}',
                          leading: CircleAvatar(
                            backgroundColor: AppColors.dark,
                            radius: 20,
                            child: Text(
                              member.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryBright,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CommonStatusChip(status: member.status),
                              const SizedBox(width: 8),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.primaryBright,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Member'),
        onPressed: () => Get.toNamed(AppRoutes.forms),
      ),
    );
  }
}
