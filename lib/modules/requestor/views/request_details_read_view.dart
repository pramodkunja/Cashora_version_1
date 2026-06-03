import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/request_repository.dart';
import '../../../../utils/widgets/request_details_layout.dart';
import 'widgets/rejected_request_view.dart';

/// Read-only expense detail screen for the requestor. Reuses the shared
/// [RequestDetailsLayout] so it matches the admin's request-details
/// design exactly.
///
/// Routing rules elsewhere mean this screen never sees:
///   * `clarification` status → routed to the Provide-Clarification screen
///   * `rejected` status → routed to [RejectedRequestView] (own design)
///
/// On open, the list-row data from `Get.arguments` is shown immediately
/// (no flicker / spinner — the user already saw it in the list). In the
/// background we hit `GET /requestor/requests/{id}` to pick up the full
/// shape: `approved_at`, `rejected_at`, `paid_at`, `clarification_history`,
/// receipts, etc. When the fetch returns, the screen rebuilds with the
/// merged data. If the call fails (network / 403 / 404) we silently keep
/// showing the cached row so the user still sees something useful.
class RequestDetailsReadView extends StatefulWidget {
  const RequestDetailsReadView({super.key});

  @override
  State<RequestDetailsReadView> createState() => _RequestDetailsReadViewState();
}

class _RequestDetailsReadViewState extends State<RequestDetailsReadView> {
  late Map<String, dynamic> _request;
  late final RequestRepository _repo;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _request = (args is Map) ? Map<String, dynamic>.from(args) : {};
    _repo = Get.find<RequestRepository>();
    // Refresh from backend on the next frame so the initial paint uses
    // the cached row data — no spinner, no jump.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    // Pick the most reliable identifier the backend will accept.
    // `id` is preferred (numeric DB id); `request_id` works too (string).
    final raw = _request['id'] ?? _request['request_id'];
    if (raw == null) return;
    final id = raw.toString();
    if (id.isEmpty) return;

    try {
      final fresh = await _repo.getRequestById(id);
      if (!mounted) return;
      // Merge so any cache-only fields stay if the fresh response omits
      // them, but fresh values override cached ones (status / dates etc).
      setState(() {
        _request = {..._request, ...fresh};
      });
    } catch (e) {
      // Silent fallback — the cached row data is already on screen.
      if (kDebugMode) {
        debugPrint('[request_details_read] refresh failed for id=$id: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = (_request['status'] ?? 'pending').toString().toLowerCase();

    if (status == 'rejected') {
      return RejectedRequestView(request: _request);
    }

    final isApproved = status == 'approved' ||
        status == 'auto_approved' ||
        status == 'paid';
    final variant = isApproved
        ? RequestDetailVariant.approved
        : RequestDetailVariant.pending;

    return RequestDetailsLayout(
      request: _request,
      variant: variant,
      headerTitle: 'Request Details',
    );
  }
}
