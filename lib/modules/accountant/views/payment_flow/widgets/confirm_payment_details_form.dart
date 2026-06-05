import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'confirm_payment_primitives.dart';

/// Conditional details form on the confirm-payment screen — renders
/// either a single UPI ID field or the account-holder / number / IFSC
/// trio depending on the [selectedMethod].
class ConfirmPaymentDetailsForm extends StatelessWidget {
  final String selectedMethod;
  final TextEditingController vpaController;
  final TextEditingController accountHolderController;
  final TextEditingController accountNumberController;
  final TextEditingController ifscController;

  const ConfirmPaymentDetailsForm({
    super.key,
    required this.selectedMethod,
    required this.vpaController,
    required this.accountHolderController,
    required this.accountNumberController,
    required this.ifscController,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedMethod == 'VPA') {
      return ConfirmPaymentSectionCard(
        icon: Icons.qr_code_rounded,
        title: 'UPI Details',
        child: ConfirmPaymentField(
          label: 'UPI ID *',
          controller: vpaController,
          hint: 'e.g., user@upi',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
      );
    }
    return ConfirmPaymentSectionCard(
      icon: Icons.account_balance_rounded,
      title: 'Bank Account Details',
      child: Column(
        children: [
          ConfirmPaymentField(
            label: 'Account Holder Name *',
            controller: accountHolderController,
            hint: 'Enter account holder name',
            icon: Icons.person_rounded,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: 14.h),
          ConfirmPaymentField(
            label: 'Account Number *',
            controller: accountNumberController,
            hint: 'Enter account number',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: 14.h),
          ConfirmPaymentField(
            label: 'IFSC Code *',
            controller: ifscController,
            hint: 'e.g., SBIN0001234',
            icon: Icons.code_rounded,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              LengthLimitingTextInputFormatter(11),
            ],
          ),
        ],
      ),
    );
  }
}
