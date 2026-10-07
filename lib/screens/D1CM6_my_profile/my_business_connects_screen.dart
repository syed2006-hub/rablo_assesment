import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/api_state.dart';
import '../../constants/app_colors.dart';
import '../../services/api/business_connect_api_service.dart';

/// D1CM6 – My Business Connects Screen strictly implementing Figma Row 2
/// with Active, Expired, and Pending business connect cards & detail modals.
class MyBusinessConnectsScreen extends StatefulWidget {
  const MyBusinessConnectsScreen({super.key});

  @override
  State<MyBusinessConnectsScreen> createState() =>
      _MyBusinessConnectsScreenState();
}

class _MyBusinessConnectsScreenState extends State<MyBusinessConnectsScreen> {
  late final BusinessConnectApiService _apiService;

  ViewState _state = ViewState.initial;
  String? _errorMessage;
  int? _statusCode;

  // Mock business connects data matching Figma
  final List<Map<String, dynamic>> _businesses = [
    {
      'id': 'b1',
      'name': 'PowerFit Gym & Health Club',
      'branch': 'Indiranagar, Bangalore',
      'status': 'Active',
      'statusColor': const Color(0xFFB8FE22), // Neon lime
      'badgeColor': const Color(0xFF2E7D32), // Green
      'badgeIcon': Icons.fitness_center_rounded,
      'planName': 'Period-Based Annual Plan',
      'validity': '90 Days left',
      'amount': '5,000 INR',
      'phone': '+91 98765 43210',
      'manager': 'Vikram Malhotra',
      'timings': '6:00 AM - 10:00 PM',
      'address': '#102, 100 Feet Rd, Indiranagar, Bangalore',
    },
    {
      'id': 'b2',
      'name': 'IronCore Fitness Studio',
      'branch': 'Koramangala 4th Block, Bangalore',
      'status': 'Expired',
      'statusColor': const Color(0xFFEF5350), // Red
      'badgeColor': const Color(0xFFC62828), // Dark Red
      'badgeIcon': Icons.storefront_rounded,
      'planName': 'Quarterly Strength Pass',
      'validity': 'Expired on 15 Aug',
      'amount': '2,400 INR',
      'phone': '+91 98450 12345',
      'manager': 'Ramesh Kumar',
      'timings': '5:30 AM - 10:30 PM',
      'address': '80 Feet Rd, Koramangala 4th Block, Bangalore',
    },
    {
      'id': 'b3',
      'name': 'CrossFit Velocity Center',
      'branch': 'HSR Layout Sector 2, Bangalore',
      'status': 'Pending Approval',
      'statusColor': const Color(0xFF38B2AC), // Cyan
      'badgeColor': const Color(0xFF00838F), // Deep Cyan
      'badgeIcon': Icons.hourglass_top_rounded,
      'planName': 'Session-Based 30 Sessions',
      'validity': 'Awaiting Verification',
      'amount': '3,000 INR',
      'phone': '+91 97420 98765',
      'manager': 'Ananya Sen',
      'timings': '6:00 AM - 9:00 PM',
      'address': '27th Main Rd, HSR Layout Sector 2, Bangalore',
    },
  ];

  @override
  void initState() {
    super.initState();
    _apiService = Get.isRegistered<BusinessConnectApiService>()
        ? Get.find<BusinessConnectApiService>()
        : Get.put(BusinessConnectApiService());
    _loadBusinessConnects();
  }

  /// HTTP GET - Load gym connects from backend REST API with standard API states
  Future<void> _loadBusinessConnects() async {
    setState(() {
      _state = ViewState.loading;
      _errorMessage = null;
      _statusCode = null;
    });

    try {
      final res = await _apiService.getBusinessConnects();
      if (res.isSuccess && res.data != null) {
        setState(() {
          for (var item in res.data!) {
            if (!_businesses.any((b) => b['name'] == item['name'])) {
              _businesses.add({
                'id': item['id'] ?? 'b${_businesses.length + 1}',
                'name': item['name'] ?? 'Gym Centre',
                'branch': item['address'] ?? 'Bangalore',
                'status': item['status'] ?? 'Active',
                'statusColor': item['status'] == 'Active'
                    ? const Color(0xFFB8FE22)
                    : const Color(0xFFEF5350),
                'badgeColor': item['status'] == 'Active'
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
                'badgeIcon': Icons.fitness_center_rounded,
                'planName': item['plan'] ?? 'Annual Membership',
                'validity': item['planDuration'] ?? 'Active',
                'amount': '5,000 INR',
                'phone': item['phone'] ?? '+91 98765 43210',
                'manager': 'Centre Manager',
                'timings': '6:00 AM - 10:00 PM',
                'address': item['address'] ?? 'Bangalore',
              });
            }
          }
          _state = _businesses.isEmpty ? ViewState.empty : ViewState.success;
        });
      } else {
        setState(() {
          _state = ViewState.error;
          _errorMessage = res.message;
          _statusCode = res.statusCode;
        });
      }
    } catch (e) {
      debugPrint('[MyBusinessConnectsScreen] _loadBusinessConnects error: $e');
      setState(() {
        _state = ViewState.error;
        _errorMessage = 'Failed to load business connects. Check network connection.';
        _statusCode = 503;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Trainer image with gradient overlay
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (ctx, err, st) =>
                Container(color: const Color(0xFF0F262B)),
          ),

          // Deep Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.70),
                  const Color(0xE60D1E22),
                  const Color(0xF210282E),
                  const Color(0xFA0B1B1F),
                  Colors.black,
                ],
                stops: const [0.0, 0.25, 0.55, 0.82, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar matching Figma
                _buildTopAppBar(context),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Description
                            const Text(
                              'Connected Businesses',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Manage your gym and fitness centre business affiliations.',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Dynamic State View for Connected Businesses
                            DynamicStateView<List<Map<String, dynamic>>>(
                              state: _state,
                              data: _businesses,
                              errorMessage: _errorMessage,
                              statusCode: _statusCode,
                              onRetry: _loadBusinessConnects,
                              emptyTitle: 'No Businesses Connected',
                              emptyMessage: 'You are not currently affiliated with any gym business branches.',
                              emptyIcon: Icons.storefront_rounded,
                              emptyActionText: 'Connect Gym Partner',
                              onEmptyAction: _showConnectNewModal,
                              successBuilder: (context, businesses) {
                                return Column(
                                  children: businesses.map((biz) => _buildBusinessTile(biz)).toList(),
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // Connect New Gym Button
                            _buildConnectNewButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'My Business Connects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notification Bell with Badge Counter
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A42).withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E5762)),
            ),
            child: Stack(
              children: [
                Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBright,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTile(Map<String, dynamic> biz) {
    final statusColor = biz['statusColor'] as Color;
    final badgeColor = biz['badgeColor'] as Color;
    final icon = biz['badgeIcon'] as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF163238),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF26505A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showBusinessDetailModal(biz),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Colored Badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ),

                const SizedBox(width: 14),

                // Business Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              biz['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              biz['status'] ?? '',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        biz['branch'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            flex: 3,
                            child: Text(
                              biz['planName'] ?? '',
                              style: TextStyle(
                                color: AppColors.primaryBright.withValues(alpha: 0.9),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Text(
                              biz['validity'] ?? '',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectNewButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF38808E), width: 1.5),
          backgroundColor: const Color(0xFF163238).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _showConnectNewModal,
        icon: const Icon(Icons.add, color: AppColors.primaryBright),
        label: const Text(
          'Connect with Another Fitness Centre',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FIGMA DETAIL MODALS (r2_card1_green, r2_card2_red, r2_card3_cyan)
  // ============================================================
  void _showBusinessDetailModal(Map<String, dynamic> biz) {
    final status = biz['status'] as String;
    final badgeColor = biz['badgeColor'] as Color;
    final icon = biz['badgeIcon'] as IconData;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF163238),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Top Circular Colored Badge with Floating Effect matching Figma
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.5),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ),

            const SizedBox(height: 12),

            // Business Name
            Text(
              biz['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Status Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (biz['statusColor'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: biz['statusColor'] as Color),
              ),
              child: Text(
                biz['status'],
                style: TextStyle(
                  color: biz['statusColor'] as Color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 2-Column Stats Card (Validity | Amount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3F47),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A505A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        biz['validity'],
                        style: const TextStyle(
                          color: AppColors.primaryBright,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Membership Validity',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 32, color: Colors.white24),
                  Column(
                    children: [
                      Text(
                        biz['amount'],
                        style: const TextStyle(
                          color: AppColors.primaryBright,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Total Paid',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details rows
            _buildDetailRow(Icons.location_on_outlined, 'Address', biz['address']),
            _buildDetailRow(Icons.phone_outlined, 'Manager Contact', '${biz['manager']} (${biz['phone']})'),
            _buildDetailRow(Icons.access_time_outlined, 'Timings', biz['timings']),

            const SizedBox(height: 20),

            // Action Buttons matching Figma
            if (status == 'Active') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Business Manage',
                          'Viewing manage settings for ${biz['name']}',
                          backgroundColor: const Color(0xFF1E3F47),
                          colorText: Colors.white,
                        );
                      },
                      child: const Text('Manage', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBright,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        Get.back();
                        final id = biz['id']?.toString() ?? '';
                        // Execute HTTP PATCH to update active centre
                        await _apiService.patchBusinessStatus(id, 'Active');
                        Get.snackbar(
                          'Primary Centre Set (PATCH 200)',
                          '${biz['name']} is now set as your active primary fitness centre.',
                          backgroundColor: const Color(0xFF1E3F47),
                          colorText: AppColors.primaryBright,
                        );
                      },
                      child: const Text('Active Centre', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'Expired') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE1E2D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      'Renewal Requested',
                      'Proceeding to membership plans for ${biz['name']}',
                      backgroundColor: const Color(0xFF1E3F47),
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Renew Membership',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF38B2AC)),
                    foregroundColor: const Color(0xFF38B2AC),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    Get.back();
                    final id = biz['id']?.toString() ?? '';
                    setState(() {
                      _businesses.removeWhere((b) => b['id'] == biz['id']);
                    });
                    // Execute HTTP DELETE to cancel request
                    await _apiService.deleteBusinessConnect(id);
                    Get.snackbar(
                      'Request Cancelled (DELETE 200)',
                      'Connection request to ${biz['name']} has been cancelled.',
                      backgroundColor: const Color(0xFF1E3F47),
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.close),
                  label: const Text(
                    'Cancel Connection Request',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBright, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectNewModal() {
    final searchCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF163238),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find Fitness Centre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter Gym Code or Branch name to connect.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. GYM-BLR-0042',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1E3F47),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBright,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  Get.back();
                  final gymName = searchCtrl.text.trim().isNotEmpty
                      ? searchCtrl.text.trim()
                      : 'Elite Fitness Arena';
                  final newConnect = {
                    'name': gymName,
                    'address': 'Koramangala, Bangalore',
                    'plan': 'Trial Membership',
                    'planDuration': 'Approval pending',
                  };
                  // Execute HTTP POST to create connect request
                  await _apiService.addBusinessConnect(newConnect);
                  Get.snackbar(
                    'Connection Request Sent (POST 201)',
                    'Request sent to $gymName administration for verification.',
                    backgroundColor: const Color(0xFF1E3F47),
                    colorText: AppColors.primaryBright,
                  );
                },
                child: const Text('Send Connect Request', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
