import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';

import 'dart:ui'; // For BackdropFilter

class LockView extends StatefulWidget {
  const LockView({Key? key}) : super(key: key);

  @override
  State<LockView> createState() => _LockViewState();
}

class _LockViewState extends State<LockView> {
  final BiometricService _biometricService = Get.find<BiometricService>();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    // Delay slightly to allow the view to build before showing biometric dialog
    Future.delayed(const Duration(milliseconds: 200), _authenticate);
  }

  Future<void> _authenticate() async {
    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      _authService.verifySession();
      // Navigate to the correct dashboard via RouteGuard
      Get.offAllNamed(AppRoutes.INITIAL);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.85), // Dark overlay
        body: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ), // Blur effect like PhonePe/GPay
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'App Locked',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Unlock with Biometrics',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 48.h),
                ElevatedButton(
                  onPressed: _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 48.w,
                      vertical: 16.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Unlock',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
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
