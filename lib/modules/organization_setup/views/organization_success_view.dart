import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';

class OrganizationSuccessView extends StatelessWidget {
  const OrganizationSuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Success Icon / Illustration area
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFDCFCE7),
                        width: 8,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Color(0xFF16A34A), // Green
                        size: 64,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  AppText.organizationCreatedSuccess,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2.copyWith(fontSize: 24, height: 1.3),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  AppText.secureWorkspaceReady,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTextStyles.bodyMedium.color,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Info Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.checkInbox,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTextStyles.h3.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppText.checkInboxDesc,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppTextStyles.bodyMedium.color,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Go to Login Button
                PrimaryButton(
                  text: AppText
                      .goToLogin, // TODO: Add to AppText if not present (already checked)
                  onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                // Footer Links
                Center(
                  child: Wrap(
                    spacing: 4,
                    children: [
                      Text(
                        AppText.didntReceiveEmail,
                        style: GoogleFonts.inter(
                          color: AppTextStyles.bodySmall.color,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          AppText.contactSupport,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0EA5E9),
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF0EA5E9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
