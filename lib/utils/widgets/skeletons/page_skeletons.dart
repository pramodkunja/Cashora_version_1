/// Barrel file re-exporting the page-level skeleton widgets so existing
/// `import '../utils/widgets/skeletons/page_skeletons.dart';` references
/// continue to work after the per-skeleton split.
///
/// Each skeleton mirrors a real screen's layout so the loading → loaded
/// transition is a shimmer-to-content swap with no vertical shift.
library;

export 'page_skeleton_accountant_dashboard.dart';
export 'page_skeleton_profile.dart';
export 'page_skeleton_reports_preview.dart';
export 'page_skeleton_spend_analytics.dart';
export 'page_skeleton_txn_row.dart';
