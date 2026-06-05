import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_colors.dart';
import 'request_details/request_details_cards.dart';
import 'request_details/request_details_helpers.dart';
import 'request_details/request_details_hero.dart';
import 'request_details/request_details_primitives.dart';
import 'request_details/request_details_variant.dart';

// Re-export the variant enum so consumers that only import this file
// continue to compile without changes.
export 'request_details/request_details_variant.dart' show RequestDetailVariant;

/// One shared expense-details layout used by:
///   * Admin request details (pending / approved / rejected)
///   * Accountant payment-flow request details
///   * Requestor's read-only view
///
/// Renders the same visual pattern as the admin screen — gradient hero
/// header (amount + REQUEST ID + chips), requestor card, details card,
/// attachments, optional rejection reason / timeline — so every flow
/// surfaces an identical look. The caller passes the expense Map plus a
/// variant; an optional [bottomBar] receives whatever action row the role
/// needs (e.g. "Mark as Paid" for accountant, "Approve / Reject" for
/// admin pending).
class RequestDetailsLayout extends StatelessWidget {
  /// Backend expense Map. Both `Map<String, dynamic>` and
  /// `Map<dynamic, dynamic>` are accepted.
  final Map<dynamic, dynamic> request;

  /// Visual variant.
  final RequestDetailVariant variant;

  /// Optional override for the screen title (default: "Request Details").
  final String? headerTitle;

  /// Optional bottom action bar — typically a SafeArea-wrapped row of
  /// buttons. When null, no bottom bar is rendered.
  final Widget? bottomBar;

  const RequestDetailsLayout({
    super.key,
    required this.request,
    required this.variant,
    this.headerTitle,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    final style = RequestVariantStyle.forVariant(variant);

    final amount = (request['amount'] as num?)?.toDouble() ?? 0.0;
    final requestId =
        (request['request_id'] ?? request['id'] ?? '---').toString();
    final purpose =
        (request['purpose'] ?? request['title'] ?? 'Untitled request')
            .toString();
    final description = (request['description'] ?? '').toString().trim();
    final category = prettyEnumLabel((request['category'] ?? '').toString());
    final requestType =
        prettyEnumLabel((request['request_type'] ?? '').toString());
    final createdAt = request['created_at']?.toString() ?? '';
    final updatedAt = request['updated_at']?.toString() ?? createdAt;
    final userName = readUserName(request);
    final department = readDepartment(request);
    final rejectionReason =
        (request['rejection_reason'] ?? request['admin_remarks'] ?? '')
            .toString()
            .trim();
    final hasActionRow = updatedAt.isNotEmpty && updatedAt != createdAt;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RequestDetailsHero(
              style: style,
              headerTitle: headerTitle,
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
                    if (variant == RequestDetailVariant.rejected &&
                        rejectionReason.isNotEmpty) ...[
                      RequestRejectionCard(
                        reason: rejectionReason,
                        whenStr: updatedAt,
                      ),
                      SizedBox(height: 16.h),
                    ],
                    const RequestSectionLabel('REQUESTOR'),
                    SizedBox(height: 10.h),
                    RequestRequestorCard(
                      userName: userName,
                      department: department,
                    ),
                    SizedBox(height: 16.h),
                    const RequestSectionLabel('DETAILS'),
                    SizedBox(height: 10.h),
                    RequestDetailsCard(
                      purpose: purpose,
                      description: description,
                      submittedAt: createdAt,
                      actionAt: hasActionRow ? updatedAt : null,
                      variant: variant,
                    ),
                    SizedBox(height: 16.h),
                    const RequestSectionLabel('ATTACHMENTS'),
                    SizedBox(height: 10.h),
                    RequestAttachmentsCard(request: request),
                    if (variant == RequestDetailVariant.approved) ...[
                      SizedBox(height: 16.h),
                      const RequestSectionLabel('TIMELINE'),
                      SizedBox(height: 10.h),
                      RequestTimelineCard(
                        createdAt: createdAt,
                        updatedAt: hasActionRow ? updatedAt : null,
                      ),
                    ],
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}
