import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/D1MM5_my_profile/bank_account_controller.dart';

/// D1MM5 – Bank Account & Transactions Screen.
/// Strictly implements Figma `D1MM5 Bank Account page.png` & Transaction Details Bottom Sheet.
/// Fully responsive across Mobile, Tablet, and Desktop screen sizes.
class BankAccountScreen extends StatelessWidget {
  const BankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BankAccountController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.slateScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Profiles > Bank Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.slateCardLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slateBorder),
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.badgeBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '4',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 650,
          ), // Responsive max width for tablets & desktop
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hidden / Visible Balance Banner
                _buildBalanceBanner(controller),

                const SizedBox(height: 20),

                // Dual Tab Buttons: [Transactions] vs [Bank Account]
                _buildDualTabs(controller),

                const SizedBox(height: 20),

                // Dynamic Content based on Active Tab
                Obx(() {
                  if (controller.activeTab.value ==
                      AccountViewTab.transactions) {
                    return _buildRecentTransactionsList(context, controller);
                  } else {
                    return _buildBankAccountsList(context);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

 
 
  Widget _buildBalanceBanner(BankAccountController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'INR ',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Expanded(
                child: Obx(
                  () => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller.isBalanceVisible.value
                          ? controller.totalAmount
                          : '********************',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Obx(
                  () => Icon(
                    controller.isBalanceVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
                onPressed: controller.toggleBalanceVisibility,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'has been Credited to your bank Account.',
            style: TextStyle(color: AppColors.greyMuted, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

 
  
  Widget _buildDualTabs(BankAccountController controller) {
    return Obx(() {
      final isBank = controller.activeTab.value == AccountViewTab.bankAccount;
      final isTransactions =
          controller.activeTab.value == AccountViewTab.transactions;

      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: isTransactions
                  ? ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBright,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () =>
                          controller.setActiveTab(AccountViewTab.transactions),
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Transactions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: AppColors.slateBorderLight,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () =>
                          controller.setActiveTab(AccountViewTab.transactions),
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Transactions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 46,
              child: isBank
                  ? ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBright,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () =>
                          controller.setActiveTab(AccountViewTab.bankAccount),
                      icon: const Icon(
                        Icons.account_balance_outlined,
                        size: 16,
                      ),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Bank Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: AppColors.slateBorderLight,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () =>
                          controller.setActiveTab(AccountViewTab.bankAccount),
                      icon: const Icon(
                        Icons.account_balance_outlined,
                        size: 16,
                      ),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Bank Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // RECENT TRANSACTIONS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildRecentTransactionsList(
    BuildContext context,
    BankAccountController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = controller.transactions[index];
                return _buildTransactionTile(context, item);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel item) {
    Color statusColor;
    String statusText;

    switch (item.status) {
      case TransactionStatus.success:
        statusColor = const Color(0xFFB4F23E);
        statusText = 'In-Progress';
        break;
      case TransactionStatus.pending:
        statusColor = const Color(0xFF62A0B0);
        statusText = 'Expired';
        break;
      case TransactionStatus.failed:
        statusColor = const Color(0xFFFF4D4D);
        statusText = 'Failed';
        break;
    }

    return InkWell(
      onTap: () => _showTransactionDetailSheet(context, item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF264650),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '2in1',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.planType,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        ' • ',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'INR ${item.amount}',
                    style: TextStyle(
                      color: item.status == TransactionStatus.failed
                          ? const Color(0xFFFF4D4D)
                          : const Color(0xFFB4F23E),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BANK ACCOUNTS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildBankAccountsList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bank Accounts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Add Bank Account',
                    'Redirecting to secure bank account linking...',
                    backgroundColor: AppColors.slateCard,
                    colorText: AppColors.primaryLight,
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: AppColors.primaryBright,
                  size: 16,
                ),
                label: const Text(
                  'Add New',
                  style: TextStyle(
                    color: AppColors.primaryBright,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slateCardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slateBorderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBE1E2D),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'i',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ICICI Bank',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: const [
                          Text(
                            '****498',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '|',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'INR 20014.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '12 Membership Sold',
                      style: TextStyle(
                        color: AppColors.greyMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESPONSIVE TRANSACTION DETAIL BOTTOM SHEET MODAL
  // ---------------------------------------------------------------------------
  void _showTransactionDetailSheet(
    BuildContext context,
    TransactionModel item,
  ) {
    Color themeColor;
    String badgeText;
    Color badgeBg;
    Color badgeTextColor;

    switch (item.status) {
      case TransactionStatus.success:
        themeColor = const Color(0xFFB4F23E);
        badgeText = 'Success!';
        badgeBg = const Color(0xFFB4F23E);
        badgeTextColor = Colors.black;
        break;
      case TransactionStatus.failed:
        themeColor = const Color(0xFFD31037);
        badgeText = 'Failed';
        badgeBg = const Color(0xFFD31037);
        badgeTextColor = Colors.white;
        break;
      case TransactionStatus.pending:
        themeColor = const Color(0xFF42A5F5);
        badgeText = 'Pending';
        badgeBg = const Color(0xFF244754);
        badgeTextColor = const Color(0xFF42A5F5);
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ), // Center and constrain on tablet/desktop
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F3C45),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'ID ${item.id}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Title & Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  item.productName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      item.status == TransactionStatus.pending
                                      ? Border.all(
                                          color: const Color(0xFF42A5F5),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    color: badgeTextColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Validity & Payment Mode Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF152A30),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              item.validity.split(' ')[0],
                                              style: TextStyle(
                                                color: themeColor,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.validity.substring(
                                                item.validity.indexOf(' ') + 1,
                                              ),
                                              style: TextStyle(
                                                color: themeColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Validity',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  width: 1,
                                  height: 32,
                                  color: Colors.white12,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              item.amount,
                                              style: TextStyle(
                                                color: themeColor,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'INR',
                                              style: TextStyle(
                                                color: themeColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Payment Mode',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Additional Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                '> Status',
                                badgeText,
                                valueColor: themeColor,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                '> Transactional ID',
                                item.transactionalId,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow('> Dated of Purchase', item.date),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Bottom Action Buttons
                          if (item.status == TransactionStatus.success)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white38,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () => Get.back(),
                                    icon: const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                    ),
                                    label: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Report',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB4F23E),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.account_balance,
                                      size: 16,
                                    ),
                                    label: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Invoice',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.info_outline, size: 16),
                                label: const Text(
                                  'Report',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating Icon
                Positioned(
                  top: 0,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.sync_alt,
                      color: item.status == TransactionStatus.success
                          ? Colors.black
                          : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color valueColor = Colors.white,
  }) {
    return Row(
      children: [
        Text(
          '$label ',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
