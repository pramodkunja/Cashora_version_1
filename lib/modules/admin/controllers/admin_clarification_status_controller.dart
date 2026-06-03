import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../utils/app_text.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../../../core/services/network_service.dart';

enum ClarificationState { pending, responded, askingAgain }

class AdminClarificationStatusController extends GetxController {
  final Rx<ClarificationState> state = ClarificationState.pending.obs;
  final RxMap<String, dynamic> request = <String, dynamic>{}.obs;

  /// Explicit reactive list for the clarification thread. RxMap's `[]`
  /// access doesn't always register listeners reliably (depends on the
  /// GetX version), so we surface the thread as its own RxList for the view
  /// to bind against directly.
  final RxList<Map<String, dynamic>> clarifications =
      <Map<String, dynamic>>[].obs;

  AdminRepository? _adminRepository;

  AdminRepository get repo =>
      _adminRepository ??= AdminRepository(Get.find<NetworkService>());

  final reasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _adminRepository = AdminRepository(Get.find<NetworkService>());

    final args = Get.arguments ?? {};
    request.value = _deepCopy(args);
    _seedClarificationsFromRequest();
    _updateStateFromRequest(request);

    if (kDebugMode) {
      debugPrint('[Clarification] onInit args keys: ${(args is Map ? args.keys.toList() : "non-map")}');
      debugPrint('[Clarification] onInit status: ${request['status']}, clarifications: ${clarifications.length}');
    }

    refreshRequest();
  }

  /// Read clarifications out of [request] and into the reactive [clarifications]
  /// list so the view has a single source of truth bound to an Obx-friendly Rx.
  ///
  /// Different endpoints use different key names:
  ///   - `/admin/history`              → `clarification_history`
  ///   - `/approver/org-expenses`      → `clarifications`
  ///   - `/approver/history/{id}`      → raw list
  /// Try the known keys in order.
  void _seedClarificationsFromRequest() {
    final raw = request['clarifications'] ?? request['clarification_history'];
    final list = <Map<String, dynamic>>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) list.add(Map<String, dynamic>.from(item));
      }
    }
    clarifications.assignAll(list);
  }

  /// Try to extract a numeric expense id. `/admin/history` returns `id` as
  /// the `EXP-…` string (no numeric primary key in the payload), in which
  /// case API calls keyed on numeric id (e.g. /approver/history/{int_id})
  /// must be skipped — we'll surface whatever data the listing already
  /// carries instead.
  int? _numericExpenseId() {
    for (final key in const ['db_id', 'expense_id', 'id']) {
      final v = request[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  Future<void> refreshRequest() async {
    final rawId = request['id'];
    if (rawId == null) {
      _updateStateFromRequest(request);
      return;
    }

    // 1) Try to refresh the expense itself (may return null fields, that's
    //    fine — merge only overrides where the fresh value is meaningful).
    try {
      final results = await repo.getOrgExpenses(status: 'clarification');
      final freshItem = results.firstWhere(
        (item) =>
            item['id'].toString() == rawId.toString() ||
            item['request_id']?.toString() == rawId.toString(),
        orElse: () => <String, dynamic>{},
      );
      if (freshItem.isNotEmpty) {
        final merged = _mergeMaps(
          base: Map<String, dynamic>.from(request),
          overlay: freshItem,
        );
        request.value = _deepCopy(merged);
        _seedClarificationsFromRequest();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Clarification] refresh expense failed: $e');
    }

    // 2) Try the canonical /approver/history/{expense_id} endpoint when we
    //    have a numeric id to address it with. /admin/history returns `id`
    //    as the EXP-… string with no numeric primary key alongside, so this
    //    fallback isn't always reachable from the History tap. When skipped,
    //    we rely on whatever clarification_history the listing already
    //    surfaced (seeded above via _seedClarificationsFromRequest).
    final numericId = _numericExpenseId();
    if (numericId == null) {
      if (kDebugMode) {
        debugPrint(
          '[Clarification] no numeric id (id=$rawId). Skipping /approver/history; using ${clarifications.length} entry/entries already loaded.',
        );
      }
      _updateStateFromRequest(request);
      return;
    }

    try {
      final history = await repo.getApproverClarificationHistory(numericId);
      if (history.isNotEmpty) {
        final updated = Map<String, dynamic>.from(request);
        updated['clarifications'] = history;
        request.value = _deepCopy(updated);
        request.refresh();
        clarifications.assignAll(
          history
              .whereType<Map>()
              .map<Map<String, dynamic>>((m) => Map<String, dynamic>.from(m))
              .toList(),
        );
        if (kDebugMode) {
          debugPrint('[Clarification] loaded ${history.length} entries from /approver/history/$numericId');
        }
      } else {
        if (kDebugMode) {
          debugPrint('[Clarification] /approver/history/$numericId returned empty — keeping previous (${clarifications.length} entries)');
        }
        // If the dedicated endpoint returned nothing but the merged request
        // gained clarifications via /approver/org-expenses, surface those.
        _seedClarificationsFromRequest();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Clarification] /approver/history failed: $e — keeping original clarifications');
      }
    }

    _updateStateFromRequest(request);
  }

  /// Shallow merge: every non-null field in [overlay] wins, otherwise the
  /// value from [base] is preserved. For `clarifications`, the longer (more
  /// recent) list wins so we never regress to an older snapshot.
  Map<String, dynamic> _mergeMaps({
    required Map<String, dynamic> base,
    required Map<String, dynamic> overlay,
  }) {
    final out = Map<String, dynamic>.from(base);
    overlay.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      if (key == 'clarifications') {
        // Prefer whichever clarifications list is longer (i.e. has more
        // history).
        final baseList = base[key];
        if (baseList is List && value is List && baseList.length > value.length) {
          return;
        }
      }
      out[key] = value;
    });
    return out;
  }

  void _updateStateFromRequest(Map<String, dynamic> item) {
    state.value = _determineState(item);
  }

  ClarificationState _determineState(Map<String, dynamic> item) {
    // 1) Strong signal from raw_status (when present) or a status value that
    //    explicitly says "responded".
    final status = item['status']?.toString() ?? '';
    final rawStatus = item['raw_status']?.toString() ?? '';
    if (status == 'clarification_responded' ||
        rawStatus == 'clarification_responded') {
      return ClarificationState.responded;
    }
    if (status == 'clarification_required' ||
        rawStatus == 'clarification_required') {
      return ClarificationState.pending;
    }

    // 2) Source of truth: the latest entry in the thread. /admin/history
    //    uses key `clarification_history`; other endpoints use
    //    `clarifications`. The reactive RxList already holds whichever was
    //    found, so use it directly if populated.
    final List<dynamic> raw = clarifications.isNotEmpty
        ? List<dynamic>.from(clarifications)
        : (item['clarifications'] ??
                item['clarification_history'] ??
                const <dynamic>[])
            as List<dynamic>;

    if (raw.isNotEmpty) {
      final last = raw.last;
      if (last is Map) {
        final response = last['response']?.toString() ?? '';
        return response.isNotEmpty
            ? ClarificationState.responded
            : ClarificationState.pending;
      }
    }

    return ClarificationState.pending;
  }

  /// Deep copy a map so nested Lists/Maps are new instances,
  /// preventing RxMap from losing references.
  Map<String, dynamic> _deepCopy(dynamic source) {
    if (source is Map) {
      return source.map<String, dynamic>((key, value) {
        if (value is Map) return MapEntry(key.toString(), _deepCopy(value));
        if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((e) => e is Map ? _deepCopy(e) : e).toList(),
          );
        }
        return MapEntry(key.toString(), value);
      });
    }
    return {};
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  void startAskAgain() {
    state.value = ClarificationState.askingAgain;
  }

  Future<void> submitAskAgain() async {
    final String question = reasonController.text.trim();
    if (question.isEmpty) {
      Get.snackbar("Error", "Please provide a reason/question");
      return;
    }
    try {
      final id = request['id'];
      if (id == null) return;

      final numericId = id is int ? id : int.parse(id.toString());
      await repo.askClarification(numericId, question);

      Get.snackbar(AppText.success, AppText.sentBackSuccessfully);

      // Update local state
      final updatedClarifications = List<Map<String, dynamic>>.from(
        request['clarifications'] ?? [],
      );
      updatedClarifications.add({
        'question': question,
        'response': '',
        'asked_at': DateTime.now().toIso8601String(),
        'responded_at': '',
      });

      final updatedRequest = Map<String, dynamic>.from(request);
      updatedRequest['clarifications'] = updatedClarifications;
      updatedRequest['status'] = 'clarification_required';
      request.value = updatedRequest;

      state.value = ClarificationState.pending;
      reasonController.clear();
    } catch (e) {
      Get.snackbar("Error", "Failed to ask clarification: $e");
    }
  }

  Future<void> approve() async {
    try {
      final id = request['id'];
      if (id == null) return;

      await repo.approveRequest(id);

      Get.back(result: true);
      Get.snackbar(AppText.approvedSuccessTitle, AppText.approvedSuccessDesc);
    } catch (e) {
      Get.snackbar("Error", "Failed to approve: $e");
    }
  }

  Future<void> reject() async {
    try {
      final id = request['id'];
      if (id == null) return;

      await repo.rejectRequest(id, "Rejected by Admin");

      Get.back(result: true);
      Get.snackbar(AppText.requestRejected, AppText.requestRejectedDesc);
    } catch (e) {
      Get.snackbar("Error", "Failed to reject: $e");
    }
  }
}
