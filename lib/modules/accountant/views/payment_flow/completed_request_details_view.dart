import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/app_text.dart';
import 'package:cash/utils/widgets/app_loader.dart';
import 'package:cash/modules/accountant/controllers/completed_request_details_controller.dart';

class CompletedRequestDetailsView extends StatelessWidget {
  const CompletedRequestDetailsView({super.key});

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _slate100 = Color(0xFFF1F5F9);
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompletedRequestDetailsController());

    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoader();
        }
        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorState(context, controller.errorMessage.value);
        }
        final payment = controller.paymentDetails;
        if (payment.isEmpty) {
          return _buildErrorState(context, 'No details available');
        }
        return _buildBody(context, payment);
      }),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      children: [
        _buildHeader(context, referenceCode: '---'),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48.sp, color: _slate300),
                  SizedBox(height: 12.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppColors.errorRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> payment) {
    final amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0;
    final createdAt = payment['created_at']?.toString() ?? '';
    final paidAt = payment['paid_at']?.toString() ??
        payment['payment_date']?.toString() ??
        createdAt;

    final requestDate = _formatDate(createdAt);
    final paymentDate = _formatDate(paidAt);

    final requestorMap = payment['requestor'] as Map<String, dynamic>?;
    final requestorName = requestorMap != null
        ? '${requestorMap['first_name'] ?? ''} ${requestorMap['last_name'] ?? ''}'
            .trim()
        : 'Unknown';

    final department = payment['department']?.toString() ?? '---';
    final purpose = payment['purpose']?.toString() ?? '---';
    final description = payment['description']?.toString() ?? '---';
    final categoryKey = payment['category']?.toString() ?? '';
    final categoryMap = {
      'office_supplies': 'Office Supplies',
      'travel': 'Travel',
      'meals': 'Meals',
      'software': 'Software',
      'hardware': 'Hardware',
    };
    final category = categoryMap[categoryKey] ??
        (categoryKey.replaceAll('_', ' ').capitalizeFirst ?? '---');

    final referenceCode = payment['request_id']?.toString() ??
        payment['id']?.toString() ??
        '---';
    final paymentMethod =
        (payment['payment_method'] ?? 'UPI').toString().toUpperCase();
    final transactionId =
        payment['transaction_reference']?.toString() ?? '---';
    final processedAt = _formatTime(paidAt);
    final auditTrail = payment['audit_trail'] as List? ?? [];

    return Column(
      children: [
        _buildHeader(context, referenceCode: referenceCode),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
            child: Column(
              children: [
                _buildSuccessHero(
                  amount: amount,
                  requestDate: requestDate,
                  paymentDate: paymentDate,
                ),
                SizedBox(height: 14.h),
                _buildRequestInfoCard(
                  requestorName: requestorName,
                  department: department,
                  purpose: purpose,
                  description: description,
                  category: category,
                  referenceCode: referenceCode,
                ),
                SizedBox(height: 14.h),
                _buildPaymentCard(
                  method: paymentMethod,
                  transactionId: transactionId,
                  processedAt: processedAt,
                ),
                if (auditTrail.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _buildAuditTrailCard(auditTrail),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────── Header ─────────────────────────────

  Widget _buildHeader(BuildContext context, {required String referenceCode}) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '#$referenceCode',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.8),
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

  // ──────────────────────────── Success hero card ────────────────────────

  Widget _buildSuccessHero({
    required double amount,
    required String requestDate,
    required String paymentDate,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.05),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular success badge with ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 74.w,
                height: 74.w,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 58.w,
                height: 58.w,
                decoration: const BoxDecoration(
                  color: _green,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded,
                    color: Colors.white, size: 32.sp),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Payment Successful',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: _slate900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            AppText.totalPaidAmount,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: _slate500,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${amount.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 34.sp,
                fontWeight: FontWeight.w800,
                color: _slate900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(child: _dateCell('Requested', requestDate)),
                Container(height: 32.h, width: 1.w, color: _slate100),
                Expanded(child: _dateCell('Paid', paymentDate)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCell(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: _slate500,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: _slate900,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────── Request info ────────────────────────────

  Widget _buildRequestInfoCard({
    required String requestorName,
    required String department,
    required String purpose,
    required String description,
    required String category,
    required String referenceCode,
  }) {
    return _sectionCard(
      icon: Icons.description_rounded,
      title: AppText.requestInformation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(AppText.requestor, requestorName),
          _divider(),
          _infoRow(AppText.department, department),
          _divider(),
          _infoRowChip(AppText.category, category),
          _divider(),
          _infoBlock(AppText.purpose, purpose),
          _divider(),
          _infoBlock(AppText.description, description),
          _divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppText.referenceCode,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: _slate500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '#$referenceCode',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _purple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────── Payment card ────────────────────────────

  Widget _buildPaymentCard({
    required String method,
    required String transactionId,
    required String processedAt,
  }) {
    return _sectionCard(
      icon: Icons.payments_rounded,
      title: AppText.paymentDetails,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(_paymentIcon(method),
                    color: _purple, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.paymentSource,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: _slate500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      method,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: _slate900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _greenBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 12.sp, color: _green),
                    SizedBox(width: 4.w),
                    Text(
                      'PAID',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: _green,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _txnRow('UTR / Txn ID', transactionId, mono: true),
                SizedBox(height: 10.h),
                _txnRow('Processed At', processedAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _txnRow(String label, String value, {bool mono = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: _slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: (mono ? GoogleFonts.robotoMono : GoogleFonts.inter)(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: _slate900,
            ),
          ),
        ),
      ],
    );
  }

  IconData _paymentIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('upi')) return Icons.qr_code_2_rounded;
    if (m.contains('cash')) return Icons.payments_rounded;
    if (m.contains('cheque')) return Icons.receipt_long_rounded;
    if (m.contains('neft') || m.contains('rtgs') || m.contains('imps')) {
      return Icons.account_balance_rounded;
    }
    if (m.contains('bank')) return Icons.account_balance_rounded;
    return Icons.account_balance_wallet_rounded;
  }

  // ───────────────────────────── Audit trail ─────────────────────────────

  Widget _buildAuditTrailCard(List auditTrail) {
    return _sectionCard(
      icon: Icons.history_rounded,
      title: AppText.auditTrail,
      child: Column(
        children: auditTrail.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == auditTrail.length - 1;
          final label = item['label']?.toString() ?? '';
          final actor = item['actor']?.toString() ?? '';
          final role = item['actor_role']?.toString() ?? '';
          final note = item['note']?.toString();
          final timestamp = item['timestamp']?.toString() ?? '';
          return _timelineItem(
            title: label,
            actor: actor,
            role: role,
            note: note,
            date: _formatDateTime(timestamp),
            icon: _iconFor(label),
            color: _colorFor(label),
            bg: _bgFor(label),
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _timelineItem({
    required String title,
    required String actor,
    required String role,
    required String? note,
    required String date,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.15), width: 1),
                ),
                child: Icon(icon, color: color, size: 16.sp),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    color: _slate100,
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _slate900,
                    ),
                  ),
                  if (actor.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      role.isNotEmpty ? '$actor • $role' : actor,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: _slate500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (note != null && note.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        note,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: _slate900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  if (date.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: _slate300,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('paid')) return Icons.payments_rounded;
    if (l.contains('approv')) return Icons.check_rounded;
    if (l.contains('submit')) return Icons.send_rounded;
    if (l.contains('clarif')) return Icons.help_outline_rounded;
    if (l.contains('reject')) return Icons.close_rounded;
    return Icons.circle_outlined;
  }

  Color _colorFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('paid')) return _green;
    if (l.contains('approv')) return _purple;
    if (l.contains('reject')) return AppColors.errorRed;
    if (l.contains('submit')) return _slate500;
    return _slate500;
  }

  Color _bgFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('paid')) return _greenBg;
    if (l.contains('approv')) return _purpleLight;
    if (l.contains('reject')) return const Color(0xFFFEF2F2);
    if (l.contains('submit')) return _bg;
    return _bg;
  }

  // ───────────────────────────── Helpers ─────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: _purple, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: _slate900,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: _slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _slate900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRowChip(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: _slate500,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _purpleLight,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: _purple,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBlock(String label, String value) {
    final hasValue = value.isNotEmpty && value != '---';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: _purple,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: _slate500,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _slate100, width: 1),
          ),
          child: Text(
            hasValue ? value : 'Not provided',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
              color: hasValue ? _slate900 : _slate300,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(height: 1.h, color: _slate100),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '---';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String dateStr) {
    if (dateStr.isEmpty) return '---';
    try {
      final dt = DateTime.parse(dateStr);
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m $amPm';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final m = dt.minute.toString().padLeft(2, '0');
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$m $amPm';
    } catch (_) {
      return dateStr;
    }
  }
}
