import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../utils/app_colors.dart';
import 'widgets/admin_user_success_actions.dart';
import 'widgets/admin_user_success_header.dart';
import 'widgets/admin_user_success_hero_icon.dart';
import 'widgets/admin_user_success_summary_card.dart';
import 'widgets/admin_user_success_variant.dart';

/// Success screen shown after creating / updating / activating /
/// deactivating a user. Matches the gradient-header + card-form pattern
/// used elsewhere in the app — variant-coloured header (green for happy
/// path, red for deactivation), a hero icon overlapping the gradient
/// edge, the user summary, and a primary CTA.
class AdminUserSuccessView extends StatelessWidget {
  const AdminUserSuccessView({super.key});

  static const _slate600 = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final type = (args['type'] ?? 'create').toString();
    final userData = args['user'] as Map<String, dynamic>? ?? {};

    final userName = (userData['full_name'] ??
            userData['name'] ??
            '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}')
        .toString()
        .trim();
    final userRole = (userData['role'] ?? 'Requestor').toString();
    final email = (userData['email'] ?? '').toString();
    final phone =
        (userData['phone_number'] ?? userData['phone'] ?? '').toString();
    final createdAt = userData['created_at']?.toString();
    final updatedAt = userData['updated_at']?.toString();

    final variant = adminUserSuccessVariantFor(type);
    final isHappy = variant != AdminUserSuccessVariant.deactivate;
    final actionDate = (variant == AdminUserSuccessVariant.create
            ? createdAt
            : (updatedAt ?? createdAt)) ??
        '';

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AdminUserSuccessHeader(variant: variant),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero icon overlapping the gradient — fixed positive
                    // negative-margin via Transform.translate so it sits on
                    // the edge cleanly.
                    Transform.translate(
                      offset: Offset(0, -48.h),
                      child: Align(
                        alignment: Alignment.center,
                        child: AdminUserSuccessHeroIcon(variant: variant),
                      ),
                    ),
                    // Pull the rest up to close the gap left by the icon.
                    Transform.translate(
                      offset: Offset(0, -36.h),
                      child: Column(
                        children: [
                          Text(
                            adminUserSuccessTitleFor(variant, userName),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            adminUserSuccessBodyFor(variant, userName),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: _slate600,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // User summary card — hidden on deactivate, the
                          // header pill already says it all.
                          if (isHappy)
                            AdminUserSuccessSummaryCard(
                              userName: userName,
                              userRole: userRole,
                              email: email,
                              phone: phone,
                              actionDate: actionDate,
                              variant: variant,
                            ),
                          SizedBox(height: 24.h),
                          const AdminUserSuccessPrimaryCta(),
                          if (variant == AdminUserSuccessVariant.create) ...[
                            SizedBox(height: 12.h),
                            const AdminUserSuccessSecondaryCta(),
                          ],
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
