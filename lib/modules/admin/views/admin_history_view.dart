import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../controllers/admin_history_controller.dart';

class AdminHistoryView extends GetView<AdminHistoryController> {
  const AdminHistoryView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _red = AppColors.errorRed;
  static const _redBg = Color(0xFFFEF2F2);
  static const _amber = AppColors.warningOrange;
  static const _amberBg = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const SkeletonListView();
              }
              if (controller.filteredRequests.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                color: _purple,
                onRefresh: controller.fetchHistory,
                child: ListView.separated(
                  controller: controller.scrollController,
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                  itemCount: controller.filteredRequests.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) {
                    final item = controller.filteredRequests[i];
                    return GestureDetector(
                      onTap: () => controller.viewDetails(item),
                      child: _buildCard(item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        22.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.pastApprovalsTitle,
                  style: GoogleFonts.inter(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Obx(
                  () => Text(
                    '${controller.filteredRequests.length} records',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.filter_list_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips (no double-layer) ───────────────────────────────────
  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Obx(
          () => Row(
            children: [
              _chip(AppText.filterAll, 'All'),
              SizedBox(width: 8.w),
              _chip(AppText.filterApproved, 'Approved'),
              SizedBox(width: 8.w),
              _chip(AppText.filterRejected, 'Rejected'),
              SizedBox(width: 8.w),
              _chip(AppText.clarified, 'Clarified'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = controller.selectedFilter.value == value;
    return GestureDetector(
      onTap: () => controller.updateFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.white,
          borderRadius: BorderRadius.circular(100.r),
          border: selected
              ? null
              : Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _purple.withOpacity(0.25),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _slate500,
          ),
        ),
      ),
    );
  }

  // ── History Card ─────────────────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> item) {
    final status = (item['status']?.toString() ?? 'unknown').toLowerCase();
    final isApproved = status == 'approved' || status == 'auto_approved';
    final isRejected = status == 'rejected';

    final statusColor = isApproved
        ? _green
        : isRejected
            ? _red
            : _amber;
    final statusBg = isApproved
        ? _greenBg
        : isRejected
            ? _redBg
            : _amberBg;
    final statusIcon = isApproved
        ? Icons.check_circle_rounded
        : isRejected
            ? Icons.cancel_rounded
            : Icons.help_outline_rounded;
    final statusLabel = isApproved
        ? 'APPROVED'
        : isRejected
            ? 'REJECTED'
            : 'CLARIFICATION';

    final requestId = item['request_id']?.toString() ??
        item['id']?.toString() ??
        'N/A';
    final actionDate =
        _formatDate(item['updated_at']?.toString() ?? item['created_at']?.toString());
    final amount = (item['amount'] is num)
        ? (item['amount'] as num).toDouble()
        : double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;

    String userName = 'Unknown';
    if (item['requestor'] is Map) {
      final r = item['requestor'];
      userName = '${r['first_name'] ?? ''} ${r['last_name'] ?? ''}'.trim();
      if (userName.isEmpty) userName = r['email']?.toString() ?? 'Unknown';
    } else if (item['user'] != null) {
      userName = item['user'].toString();
    }

    final title = item['purpose']?.toString() ??
        item['title']?.toString() ??
        'Expense Request';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: request ID + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REQUEST ID',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: _slate500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    requestId,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _slate900,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ACTION DATE',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: _slate500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    actionDate,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _slate900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
          SizedBox(height: 12.h),

          // User + amount row
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    _initials(userName),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _purple,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _slate900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: _slate500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: _slate900,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Status + chevron
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 13.sp),
                    SizedBox(width: 5.w),
                    Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: _slate300, size: 20.sp),
            ],
          ),

          // Clarification response hint
          if (status == 'clarification' ||
              status == 'clarification_responded') ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.mark_email_read_rounded,
                      size: 14.sp, color: _purple),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Response received — review next steps',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: _slate500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 56.sp, color: _slate300),
          SizedBox(height: 14.h),
          Text(
            AppText.noRequests,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _slate500,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr.split('T').first;
    }
  }
}
