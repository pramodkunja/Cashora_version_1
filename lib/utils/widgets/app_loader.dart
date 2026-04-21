import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

/// Large loader: the word "cashora" is written out in big cursive letters
/// from the left of its container to the right, with a glowing pen-tip dot
/// leading the stroke. The cursive letters themselves form the "line".
///
/// Use this as a full-page or in-card loading indicator.
class AppLineLoader extends StatefulWidget {
  final double fontSize;
  final Color? color;
  const AppLineLoader({super.key, this.fontSize = 84, this.color});

  @override
  State<AppLineLoader> createState() => _AppLineLoaderState();
}

class _AppLineLoaderState extends State<AppLineLoader>
    with SingleTickerProviderStateMixin {
  static const String _word = 'cashora';
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    final fontSize = widget.fontSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = _controller.value;
            // 0 → 0.9: writing sweeps across. 0.9 → 1.0: hold briefly.
            final sweep = (t / 0.9).clamp(0.0, 1.0);
            final writeX = sweep * w;

            return SizedBox(
              width: w,
              height: fontSize * 1.3,
              child: Center(
                child: ClipRect(
                  clipper: _SweepClipper(
                    lineWidth: writeX,
                    containerWidth: w,
                  ),
                  child: Text(
                    _word,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dancingScript(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1.0,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Clips the centered text so only the portion the sweeping line has crossed
/// is visible.
class _SweepClipper extends CustomClipper<Rect> {
  final double lineWidth;
  final double containerWidth;

  _SweepClipper({required this.lineWidth, required this.containerWidth});

  @override
  Rect getClip(Size size) {
    // Text is centered inside containerWidth, so its left edge (in container
    // coordinates) is at (containerWidth - size.width) / 2. The visible width
    // of the text is however far past that point the line has progressed.
    final textLeftInContainer = (containerWidth - size.width) / 2;
    final clipW = (lineWidth - textLeftInContainer).clamp(0.0, size.width);
    return Rect.fromLTWH(0, 0, clipW, size.height);
  }

  @override
  bool shouldReclip(covariant _SweepClipper old) =>
      old.lineWidth != lineWidth || old.containerWidth != containerWidth;
}

/// Compact typewriter-style "cashora" loader, sized for inline use (buttons,
/// small badges). No horizontal line — just the letters writing themselves.
class AppSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  const AppSpinner({super.key, this.size = 32, this.color});

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  static const String _word = 'cashora';
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    final fontSize = widget.size;

    return SizedBox(
      height: fontSize * 1.4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = _controller.value;
          const revealEnd = 0.72;
          final perLetter = revealEnd / _word.length;

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_word.length, (i) {
              final start = i * perLetter;
              final end = start + perLetter * 1.6;
              double p;
              if (t < start) {
                p = 0.0;
              } else if (t > end) {
                p = 1.0;
              } else {
                p = ((t - start) / (end - start)).clamp(0.0, 1.0);
              }
              final eased = Curves.easeOutCubic.transform(p);
              return Opacity(
                opacity: eased,
                child: Transform.translate(
                  offset: Offset(0, (1 - eased) * fontSize * 0.25),
                  child: Transform.scale(
                    scale: 0.85 + eased * 0.15,
                    child: Text(
                      _word[i],
                      style: GoogleFonts.dancingScript(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Drop-in replacement for full-page `CircularProgressIndicator`: shows the
/// big line-sweep "cashora" loader, centered both axes, spanning full width.
class AppLoader extends StatelessWidget {
  final double fontSize;
  final Color? color;
  const AppLoader({super.key, this.fontSize = 84, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppLineLoader(fontSize: fontSize, color: color),
    );
  }
}
