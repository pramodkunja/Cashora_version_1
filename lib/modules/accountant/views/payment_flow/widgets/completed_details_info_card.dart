import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import 'completed_details_primitives.dart';

/// Request information card — requestor, email, department, vendor,
/// category, purpose, description, reference code.
///
/// Rows that don't apply (empty email / vendor) are hidden so the card
/// stays compact instead of showing placeholder "---" entries.
class CompletedDetailsInfoCard extends StatelessWidget {
  final String requestorName;
  final String requestorEmail;
  final String department;
  final String vendorName;
  final String purpose;
  final String description;
  final String category;
  final String referenceCode;

  const CompletedDetailsInfoCard({
    super.key,
    required this.requestorName,
    required this.department,
    required this.purpose,
    required this.description,
    required this.category,
    required this.referenceCode,
    this.requestorEmail = '',
    this.vendorName = '',
  });

  @override
  Widget build(BuildContext context) {
    return CompletedSectionCard(
      icon: Icons.description_rounded,
      title: AppText.requestInformation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompletedInfoRow(AppText.requestor, requestorName),
          if (requestorEmail.isNotEmpty) ...[
            const CompletedRowDivider(),
            CompletedInfoRow('Email', requestorEmail),
          ],
          const CompletedRowDivider(),
          CompletedInfoRow(AppText.department, department),
          if (vendorName.isNotEmpty) ...[
            const CompletedRowDivider(),
            CompletedInfoRow('Paid To', vendorName),
          ],
          const CompletedRowDivider(),
          CompletedInfoRowChip(AppText.category, category),
          const CompletedRowDivider(),
          CompletedInfoBlock(AppText.purpose, purpose),
          const CompletedRowDivider(),
          CompletedInfoBlock(AppText.description, description),
          const CompletedRowDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppText.referenceCode,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textSlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '#$referenceCode',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
