import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../controllers/admin_request_details_controller.dart';
import 'admin_attachments_section.dart';
import 'admin_details_hero.dart';
import 'admin_request_banners.dart';
import 'admin_request_details_helpers.dart';
import 'admin_request_details_info_card.dart';
import 'admin_request_details_requestor_card.dart';
import 'admin_timeline_card.dart';

/// Variant-specific colour / icon palette for the Admin Request Details
/// screen. Drives the gradient hero, status pill, and any accent
/// surfaces below it.
class AdminRequestDetailsVariantStyle {
  final Color gradientStart;
  final Color gradientEnd;
  final Color accent;
  final Color accentBg;
  final IconData statusIcon;
  final String statusLabel;
  const AdminRequestDetailsVariantStyle({
    required this.gradientStart,
    required this.gradientEnd,
    required this.accent,
    required this.accentBg,
    required this.statusIcon,
    required this.statusLabel,
  });

  static AdminRequestDetailsVariantStyle forVariant(
      AdminRequestDetailsVariant v) {
    switch (v) {
      case AdminRequestDetailsVariant.approved:
        return const AdminRequestDetailsVariantStyle(
          gradientStart: Color(0xFF10B981),
          gradientEnd: Color(0xFF047857),
          accent: Color(0xFF047857),
          accentBg: Color(0xFFD1FAE5),
          statusIcon: Icons.check_circle_rounded,
          statusLabel: 'APPROVED',
        );
      case AdminRequestDetailsVariant.rejected:
        return const AdminRequestDetailsVariantStyle(
          gradientStart: Color(0xFFE25C5C),
          gradientEnd: Color(0xFFB91C1C),
          accent: Color(0xFFB91C1C),
          accentBg: Color(0xFFFEE2E2),
          statusIcon: Icons.block_rounded,
          statusLabel: 'REJECTED',
        );
      case AdminRequestDetailsVariant.pending:
        return const AdminRequestDetailsVariantStyle(
          gradientStart: Color(0xFF7C68D4),
          gradientEnd: Color(0xFF5B45B0),
          accent: AppColors.primary,
          accentBg: Color(0xFFF0EDFF),
          statusIcon: Icons.hourglass_top_rounded,
          statusLabel: 'PENDING',
        );
    }
  }
}

/// Scrolling content of the Admin Request Details screen — the gradient
/// hero plus the requestor / details / attachments / timeline blocks.
/// The pending-action bar lives outside this widget (it's a
/// bottomNavigationBar).
class AdminRequestDetailsBody extends StatelessWidget {
  final AdminRequestDetailsController controller;
  final AdminRequestDetailsVariant variant;

  const AdminRequestDetailsBody({
    super.key,
    required this.controller,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final req = controller.request;
    final style = AdminRequestDetailsVariantStyle.forVariant(variant);

    final amount = (req['amount'] as num?)?.toDouble() ?? 0.0;
    final requestId =
        (req['request_id'] ?? req['id'] ?? '---').toString();
    final purpose =
        (req['purpose'] ?? req['title'] ?? 'Untitled request').toString();
    final description = (req['description'] ?? '').toString().trim();
    final category = AdminRequestDetailsHelpers.prettyCategory(
        (req['category'] ?? '').toString());
    final requestType = AdminRequestDetailsHelpers.prettyCategory(
        (req['request_type'] ?? '').toString());
    final createdAt = req['created_at']?.toString() ?? '';
    final updatedAt = req['updated_at']?.toString() ?? createdAt;
    final userName = AdminRequestDetailsHelpers.getUserName(req);
    final department = AdminRequestDetailsHelpers.getDepartment(req);
    final rejectionReason =
        (req['rejection_reason'] ?? req['admin_remarks'] ?? '')
            .toString()
            .trim();
    final hasUpdatedActionRow =
        updatedAt.isNotEmpty && updatedAt != createdAt;

    // Approved + payment still pending → surface an UNPAID notice at the
    // top of the body. The approvals tab calls this "Unpaid" too.
    final paymentStatus =
        (req['payment_status'] ?? '').toString().toLowerCase();
    final showUnpaidBanner = variant == AdminRequestDetailsVariant.approved &&
        paymentStatus == 'pending';

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AdminDetailsHero(
            gradientStart: style.gradientStart,
            gradientEnd: style.gradientEnd,
            statusIcon: style.statusIcon,
            statusLabel: style.statusLabel,
            amount: amount,
            requestId: requestId,
            category: category,
            requestType: requestType,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rejection reason — only for rejected.
                  if (variant == AdminRequestDetailsVariant.rejected &&
                      rejectionReason.isNotEmpty) ...[
                    AdminRejectionCard(
                      reason: rejectionReason,
                      whenStr: updatedAt,
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Unpaid notice — approved but payment still pending.
                  if (showUnpaidBanner) ...[
                    const AdminUnpaidBanner(),
                    SizedBox(height: 16.h),
                  ],

                  _sectionLabel('REQUESTOR'),
                  SizedBox(height: 10.h),
                  AdminRequestDetailsRequestorCard(
                    userName: userName,
                    department: department,
                  ),
                  SizedBox(height: 16.h),

                  _sectionLabel('DETAILS'),
                  SizedBox(height: 10.h),
                  AdminRequestDetailsInfoCard(
                    purpose: purpose,
                    description: description,
                    submittedAt: createdAt,
                    actionAt: hasUpdatedActionRow ? updatedAt : null,
                    variant: variant,
                  ),
                  SizedBox(height: 16.h),

                  _sectionLabel('ATTACHMENTS'),
                  SizedBox(height: 10.h),
                  AdminAttachmentsSection(
                    request: controller.request,
                    onAttachmentTap: controller.viewAttachment,
                  ),
                  SizedBox(height: 16.h),

                  if (variant == AdminRequestDetailsVariant.approved) ...[
                    _sectionLabel('TIMELINE'),
                    SizedBox(height: 10.h),
                    AdminTimelineCard(
                      createdAt: createdAt,
                      updatedAt: hasUpdatedActionRow ? updatedAt : null,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),
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
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSlate,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
