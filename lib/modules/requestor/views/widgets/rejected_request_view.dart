import 'package:flutter/widgets.dart';

import '../../../../utils/widgets/request_details_layout.dart';

/// Read-only view shown when the requestor opens one of their own
/// rejected expenses. A thin wrapper around the shared
/// [RequestDetailsLayout] so the look-and-feel matches the admin's
/// rejected detail screen — red gradient hero, rejection-reason card,
/// requestor & details cards, attachments.
class RejectedRequestView extends StatelessWidget {
  final Map<String, dynamic> request;

  const RejectedRequestView({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return RequestDetailsLayout(
      request: request,
      variant: RequestDetailVariant.rejected,
      headerTitle: 'Request Details',
    );
  }
}
