import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../routes/app_routes.dart';

class AdminUserSuccessView extends StatelessWidget {
  const AdminUserSuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('DEBUG: AdminUserSuccessView arguments: ${Get.arguments}');
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final type = args['type'] ?? 'create'; // 'create', 'update', 'deactivate'

    // Get user data from arguments or use defaults
    final userData = args['user'] as Map<String, dynamic>? ?? {};
    final String userName =
        userData['full_name'] ??
        userData['name'] ??
        '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
    final String userRole = userData['role'] ?? 'Requestor';
    final String email = userData['email'] ?? '';
    final String phone = userData['phone_number'] ?? userData['phone'] ?? '';
    final String createdDate = userData['created_at'] != null
        ? _formatDate(userData['created_at'])
        : _getCurrentDate();
    final String updatedDate = userData['updated_at'] != null
        ? _formatDate(userData['updated_at'])
        : _getCurrentDate();

    final bool isUpdate = type == 'update';
    final bool isDeactivate = type == 'deactivate';
    final bool isActivate = type == 'activate';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ), // Responsive top spacing
              // Success Icon with Glow
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).size.width * 0.3,
                constraints: const BoxConstraints(
                  minWidth: 100,
                  maxWidth: 140,
                  minHeight: 100,
                  maxHeight: 140,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.successGreen.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.successBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.successGreen,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                isDeactivate
                    ? AppText.userDeactivatedSuccess
                    : isActivate
                    ? AppText.userActivatedSuccess
                    : isUpdate
                    ? AppText.userUpdatedSuccessTitle
                    : AppText.userCreatedSuccessTitle,
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              if (isDeactivate)
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: userName,
                    style: AppTextStyles.h3.copyWith(fontSize: 14),
                    children: [
                      TextSpan(
                        text: ' has been deactivated.\n',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                        ),
                      ),
                      TextSpan(
                        text:
                            'Their access to the petty cash system has been revoked.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  isActivate
                      ? 'The user has been successfully activated and can now access the system.'
                      : isUpdate
                      ? AppText.userUpdatedSuccessDesc
                      : AppText.userCreatedSuccessDesc,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSlate,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 32),

              // Only show user summary card if not deactivating
              if (!isDeactivate)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: const NetworkImage(
                              'https://i.pravatar.cc/150?u=sarah',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: AppTextStyles.h3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    userRole,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 10,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildSummaryRow(
                        Icons.email,
                        AppText.emailAddress,
                        email,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                        Icons.phone,
                        AppText.phone,
                        phone.isNotEmpty ? phone : 'Not provided',
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                        Icons.calendar_today,
                        (isUpdate || isActivate)
                            ? AppText.updatedOn
                            : AppText.createdOn,
                        (isUpdate || isActivate) ? updatedDate : createdDate,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: AppText.goToManageUsers,
                onPressed: () => Get.until(
                  (route) => route.settings.name == AppRoutes.ADMIN_USER_LIST,
                ),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 16),

              if (type ==
                  'create') // Only show "Add another user" for create flow
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : AppColors.primaryLight.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : AppColors.primaryLight.withOpacity(0.5),
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.person_add,
                      color: AppColors.primaryBlue,
                    ),
                    label: Text(
                      AppText.addAnotherUser,
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSlate),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSlate,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.h3.copyWith(fontSize: 14),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return _getCurrentDate();

    try {
      if (dateValue is String) {
        // Try to parse ISO date string
        final dateTime = DateTime.parse(dateValue);
        return '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
      }
    } catch (e) {
      // If parsing fails, return current date
      return _getCurrentDate();
    }

    return _getCurrentDate();
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${_getMonthName(now.month)} ${now.day}, ${now.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
