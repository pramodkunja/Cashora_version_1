import 'package:dio/dio.dart';
import '../../core/services/network_service.dart';

class OrganizationRepository {
  final NetworkService _networkService;

  OrganizationRepository(this._networkService);

  Future<void> createOrganization({
    required String orgName,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final data = {
        "org_name": orgName,
        "admin_details": {
          "email": email,
          "first_name": firstName,
          "last_name": lastName,
          "phone_number": phoneNumber,
        },
      };

      await _networkService.post('/auth/setup-organization', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getApprovalLimits() async {
    try {
      final response = await _networkService.get('/users/approval-limit');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateApprovalLimits({required int deemedLimit}) async {
    try {
      final data = {'deemed_approval_limit': deemedLimit};
      await _networkService.patch('/users/approval-limit', data: data);
    } catch (e) {
      rethrow;
    }
  }
}
