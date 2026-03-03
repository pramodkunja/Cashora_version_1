import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';

class VerifyPaymentView extends StatelessWidget {
  const VerifyPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Payment')),
      body: Center(
        child: Text(
          'This screen is deprecated in the new UPI flow.',
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
