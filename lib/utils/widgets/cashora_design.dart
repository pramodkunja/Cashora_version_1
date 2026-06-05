// Cashora shared design system — barrel file.
//
// The design system is split into a sibling `cashora/` folder, one file
// per logical group, so each component file stays small and focused.
// This barrel re-exports every public API so existing imports keep
// working without changes:
//
//     import '<rel>/utils/widgets/cashora_design.dart';
//
// Composing a screen typically pulls in:
//
//   • [CashoraColors]            — design tokens
//   • [AppBackground] / [Bloom]  — full-screen lavender backdrop
//   • [CircleIconButton]         — circular white icon button
//   • [AppTopBar]                — back chevron + centred title + trailing
//   • [HeroBadge]                — gradient icon disc with accent ring
//   • [EyebrowPill]              — small caps tag pill
//   • [SectionHeader]            — icon-in-square + section title
//   • [HeroHeadline]             — eyebrow → headline → subtitle stack
//   • [WhiteSheet] / [SheetHandle] — curved-top white form/list container
//   • [GradientButton]           — full-width primary CTA
//   • [EntranceWrap]             — one-shot fade-in slide-up
//   • [cashoraInputDecoration]   — M3 floating-label input style
//   • [CashoraScaffold]          — full screen wired together
//
// New screens should prefer composing from here over inlining patterns.

export 'cashora/cashora_background.dart';
export 'cashora/cashora_button.dart';
export 'cashora/cashora_colors.dart';
export 'cashora/cashora_entrance.dart';
export 'cashora/cashora_hero.dart';
export 'cashora/cashora_input.dart';
export 'cashora/cashora_scaffold.dart';
export 'cashora/cashora_sheet.dart';
export 'cashora/cashora_top_bar.dart';
