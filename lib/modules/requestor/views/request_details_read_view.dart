import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/attachment_card.dart';
import 'widgets/rejected_request_view.dart';

class RequestDetailsReadView extends StatelessWidget {
  const RequestDetailsReadView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _amber = AppColors.warningOrange;
  static const _amberBg = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    final request = Get.arguments as Map<String, dynamic>? ?? {};
    final status = (request['status'] ?? 'Pending').toString().toLowerCase();

    if (status == 'rejected') {
      return RejectedRequestView(request: request);
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildContent(request)),
        ],
      ),
    );
  }

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
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            AppText.requestDetails,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> request) {
    final status = (request['status'] ?? 'Pending').toString().toLowerCase();
    final category = (request['category'] ?? 'General').toString();
    final title = (request['title'] ?? request['purpose'] ?? 'Request').toString();

    String dateStr = request['created_at']?.toString() ??
        request['date']?.toString() ??
        DateTime.now().toString();
    String date = dateStr;
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      date = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      if (date.contains('T')) date = date.split('T')[0];
    }

    final amount = (request['amount'] as num?)?.toDouble() ?? 0.0;

    final isApproved =
        status == 'approved' || status == 'auto_approved' || status == 'paid';
    final statusColor = isApproved ? _green : _amber;
    final statusBg = isApproved ? _greenBg : _amberBg;
    final statusIcon = isApproved
        ? Icons.check_circle_rounded
        : Icons.pending_rounded;
    final statusText = isApproved ? 'Approved' : 'Pending';
    final catIcon = _iconForCategory(category);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero amount card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(22.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(catIcon, size: 32.sp, color: _purple),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: _slate500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 38.sp,
                    fontWeight: FontWeight.w800,
                    color: _slate900,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14.sp, color: statusColor),
                      SizedBox(width: 6.w),
                      Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Info row — Category + Date
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  label: 'CATEGORY',
                  value: category,
                  icon: Icons.category_rounded,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _infoCard(
                  label: 'DATE',
                  value: date,
                  icon: Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Description
          _sectionLabel('DESCRIPTION'),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
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
            child: Text(
              request['description']?.toString() ?? 'No description provided.',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: _slate900,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Attachments
          _sectionLabel('ATTACHMENTS'),
          SizedBox(height: 10.h),
          _buildAttachments(request),

          // Clarification history
          if ((request['clarifications'] != null &&
                  (request['clarifications'] as List).isNotEmpty) ||
              (request['admin_remarks'] != null &&
                  request['admin_remarks'].toString().isNotEmpty)) ...[
            SizedBox(height: 20.h),
            _sectionLabel('CLARIFICATION HISTORY'),
            SizedBox(height: 10.h),
            _buildConversation(request),
          ],

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.sp, color: _purple),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: _slate500,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _slate900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: _slate500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAttachments(Map<String, dynamic> request) {
    final List<dynamic> all = [];
    if (request['attachments'] is List) all.addAll(request['attachments']);
    if (request['payment_qr_url'] != null || request['qr_url'] != null) {
      all.add({
        'name': 'QR Code',
        'url': request['payment_qr_url'] ?? request['qr_url'],
      });
    }
    if (request['receipt_url'] != null) {
      all.add({'name': 'Receipt', 'url': request['receipt_url']});
    }
    if (request['bill_urls'] is List) {
      final bills = request['bill_urls'] as List;
      for (int i = 0; i < bills.length; i++) {
        all.add({'name': 'Bill ${i + 1}', 'url': bills[i]});
      }
    } else if (request['bill_url'] != null) {
      all.add({'name': 'Bill', 'url': request['bill_url']});
    }

    if (all.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            'No attachments',
            style: GoogleFonts.inter(fontSize: 12.sp, color: _slate300),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: all.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) =>
            AttachmentCard(attachment: all[index], index: index),
      ),
    );
  }

  Widget _buildConversation(Map<String, dynamic> request) {
    final raw = request['clarifications'];
    final items = <Map<String, dynamic>>[];
    if (raw is List) {
      for (final it in raw) {
        if (it is Map) items.add(Map<String, dynamic>.from(it));
      }
    }

    if (items.isEmpty) {
      final adminComment = request['admin_remarks'] ?? request['comments'];
      if (adminComment != null && adminComment.toString().isNotEmpty) {
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: _msg(true, adminComment.toString(), AppText.recently),
        );
      }
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          final q = item['question']?.toString() ?? '';
          final r = item['response']?.toString() ?? '';
          final askedAt = _formatDate(item['asked_at']?.toString() ?? '');
          final respondedAt =
              _formatDate(item['responded_at']?.toString() ?? '');
          return Column(
            children: [
              if (q.isNotEmpty) _msg(true, q, askedAt),
              if (r.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _msg(false, r, respondedAt),
              ],
              SizedBox(height: 12.h),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _msg(bool fromApprover, String text, String time) {
    final bg = fromApprover ? _purpleLight : _greenBg;
    final color = fromApprover ? _purple : _green;
    final label = fromApprover ? AppText.approver : 'You';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          fromApprover ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: fromApprover
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: _slate500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(fromApprover ? 4.r : 14.r),
                    topRight: Radius.circular(fromApprover ? 14.r : 4.r),
                    bottomLeft: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r),
                  ),
                ),
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: _slate900,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('food') || c.contains('meal'))
      return Icons.restaurant_rounded;
    if (c.contains('travel') || c.contains('flight'))
      return Icons.flight_rounded;
    if (c.contains('office')) return Icons.work_rounded;
    if (c.contains('transport')) return Icons.directions_car_rounded;
    if (c.contains('supplies')) return Icons.shopping_bag_rounded;
    return Icons.receipt_long_rounded;
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return AppText.recently;
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return AppText.recently;
    }
  }
}
