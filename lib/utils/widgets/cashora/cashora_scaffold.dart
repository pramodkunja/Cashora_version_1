import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cashora_background.dart';
import 'cashora_colors.dart';
import 'cashora_top_bar.dart';

/// Convenience scaffold that wires up the background, optional top bar,
/// hero content, and a white sheet at the bottom. Use for any screen
/// that follows the auth/form pattern; for screens with custom layouts,
/// compose the primitives above directly.
class CashoraScaffold extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final Widget? topBarTrailing;
  final Widget hero;
  final Widget sheet;
  final bool extraBloom;
  final Widget? floatingActionButton;

  const CashoraScaffold({
    super.key,
    this.title,
    this.onBack,
    this.topBarTrailing,
    required this.hero,
    required this.sheet,
    this.extraBloom = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashoraColors.bgB,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          AppBackground(extraBloom: extraBloom),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                if (title != null)
                  AppTopBar(
                    title: title!,
                    onBack: onBack ?? () => Get.back(),
                    trailing: topBarTrailing,
                  ),
                hero,
                Expanded(child: sheet),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
