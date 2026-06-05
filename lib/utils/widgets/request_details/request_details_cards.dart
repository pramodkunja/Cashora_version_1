import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';
import '../../date_helper.dart';
import '../attachment_card.dart';
import 'request_details_helpers.dart';
import 'request_details_primitives.dart';
import 'request_details_variant.dart';

/// Requestor card — circle with initials + name and department lines.
class RequestRequestorCard extends StatelessWidget {
  final String userName;
  final String department;

  const RequestRequestorCard({
    super.key,
    required this.userName,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    final initials = initialsFor(userName);
    return RequestWhiteCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: const Color(0xFFE0F2FE),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  department,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Details card — purpose, optional description, submitted timestamp,
/// optional action timestamp (Approved/Rejected/Updated).
class RequestDetailsCard extends StatelessWidget {
  final String purpose;
  final String description;
  final String submittedAt;
  final String? actionAt;
  final RequestDetailVariant variant;

  const RequestDetailsCard({
    super.key,
    required this.purpose,
    required this.description,
    required this.submittedAt,
    required this.actionAt,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return RequestWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RequestKvRow('Purpose', purpose, multiline: true),
          if (description.isNotEmpty && description != purpose) ...[
            const RequestRowDivider(),
            RequestKvRow('Description', description, multiline: true),
          ],
          const RequestRowDivider(),
          RequestKvRow(
            'Submitted',
            DateHelper.formatDateTime(submittedAt, fallback: '—'),
          ),
          if (actionAt != null) ...[
            const RequestRowDivider(),
            RequestKvRow(
              variant == RequestDetailVariant.rejected
                  ? 'Rejected on'
                  : variant == RequestDetailVariant.approved ||
                          variant == RequestDetailVariant.awaitingPayment
                      ? 'Approved on'
                      : 'Updated',
              DateHelper.formatDateTime(actionAt!, fallback: '—'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pink rejection-reason card — shown only on rejected requests.
class RequestRejectionCard extends StatelessWidget {
  final String reason;
  final String whenStr;

  const RequestRejectionCard({
    super.key,
    required this.reason,
    required this.whenStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFFECACA),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.format_quote_rounded,
                    size: 13.sp, color: const Color(0xFFB91C1C)),
              ),
              SizedBox(width: 10.w),
              Text(
                'REASON FOR REJECTION',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7F1D1D),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            reason,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F1D1D),
            ),
          ),
          if (whenStr.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Note from Approver • ${DateHelper.formatDateTime(whenStr, fallback: "—")}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Timeline card — shows Approved → Submitted rows connected by a thin
/// vertical line. Only renders on approved requests.
class RequestTimelineCard extends StatelessWidget {
  final String createdAt;
  final String? updatedAt;

  const RequestTimelineCard({
    super.key,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final hasApproval = updatedAt != null;
    return RequestWhiteCard(
      child: Column(
        children: [
          if (hasApproval) ...[
            _TimelineRow(
              icon: Icons.check_rounded,
              iconBg: const Color(0xFF10B981),
              title: 'Approved',
              subtitle:
                  DateHelper.formatDateTime(updatedAt!, fallback: '—'),
              highlight: true,
            ),
            const _TimelineConnector(),
          ],
          _TimelineRow(
            icon: Icons.send_rounded,
            iconBg: AppColors.primaryBlue,
            title: 'Request submitted',
            subtitle: DateHelper.formatDateTime(createdAt, fallback: '—'),
            highlight: !hasApproval,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool highlight;

  const _TimelineRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 16.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: highlight ? iconBg : AppColors.textDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: AppColors.textSlate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Container(width: 2, height: 22.h, color: const Color(0xFFE2E8F0)),
        ],
      ),
    );
  }
}

/// Attachments card — lists every receipt / QR / bill URL on the
/// request. Renders an empty placeholder when nothing's attached.
class RequestAttachmentsCard extends StatelessWidget {
  final Map<dynamic, dynamic> request;

  const RequestAttachmentsCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final items = collectAttachments(request);
    if (items.isEmpty) {
      return RequestWhiteCard(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Center(
          child: Text(
            'No attachments',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSlate,
            ),
          ),
        ),
      );
    }
    return RequestWhiteCard(
      padding: EdgeInsets.all(12.w),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        // AttachmentCard handles its own tap (downloads / launches URL).
        itemBuilder: (_, i) =>
            AttachmentCard(attachment: items[i], index: i),
      ),
    );
  }
}
