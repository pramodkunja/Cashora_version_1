import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/app_colors.dart';
import '../../../controllers/create_request_controller.dart';

/// Category-picker grid on the create-request screen. 3-column grid of
/// coloured chip tiles; tapping a tile toggles the selection.
class CreateRequestCategoryGrid extends StatelessWidget {
  final CreateRequestController controller;
  const CreateRequestCategoryGrid({super.key, required this.controller});

  static const _borderColors = <Color>[
    Color(0xFFEF4444), Color(0xFFEF4444),
    Color(0xFF10B981), Color(0xFF10B981),
    Color(0xFFEF4444), Color(0xFF10B981),
    Color(0xFF10B981), Color(0xFFEF4444),
    Color(0xFF10B981), Color(0xFF10B981),
    Color(0xFF10B981), Color(0xFFEF4444),
  ];

  static const _iconColors = <Color>[
    Color(0xFF3B82F6), Color(0xFFEC4899),
    Color(0xFF3B82F6), Color(0xFFF59E0B),
    Color(0xFF8B5CF6), Color(0xFF10B981),
    Color(0xFFEF4444), Color(0xFF06B6D4),
    Color(0xFF3B82F6), Color(0xFF8B5CF6),
    Color(0xFF10B981), Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateRequestController>(
      id: 'category_grid',
      builder: (_) {
        final bool isExpanded = controller.expenseCategories.isNotEmpty;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Category',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSlate,
                    size: 24.sp,
                  ),
                ],
              ),
              if (isExpanded) ...[
                SizedBox(height: 6.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: controller.expenseCategories.length,
                  itemBuilder: (context, index) => _CategoryTile(
                    controller: controller,
                    cat: controller.expenseCategories[index],
                    borderColor: _borderColors[index % _borderColors.length],
                    iconColor: _iconColors[index % _iconColors.length],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CreateRequestController controller;
  final Map cat;
  final Color borderColor;
  final Color iconColor;

  const _CategoryTile({
    required this.controller,
    required this.cat,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        controller.selectedExpenseCategory.value != null &&
            controller.selectedExpenseCategory.value!['id'] == cat['id'];
    final iconBgColor = iconColor.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSelected) {
            controller.selectedExpenseCategory.value = null;
          } else {
            controller.selectedExpenseCategory.value =
                Map<String, dynamic>.from(cat);
          }
          controller.update(['category_grid']);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.purpleSurface : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  cat['icon'] as IconData,
                  color: iconColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  cat['name'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
