import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/services/network_service.dart';
import '../../data/models/user_model.dart';
import '../../core/services/auth_service.dart';

class UserRepository {
  NetworkService get _networkService => Get.find<NetworkService>();
  AuthService get _authService => Get.find<AuthService>();

  // Fetch current user profile
  Future<User?> getMe() async {
    try {
      final response = await _networkService.get('/users/me');
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data;
        // Assuming response.data is the User Map, or nested in 'data' key?
        // Adjusting based on common pattern:
        final userMap = userData is Map<String, dynamic>
            ? userData
            : Map<String, dynamic>.from(userData);

        final user = User.fromJson(userMap);

        // Update local auth service state to keep it in sync
        _authService.currentUser.value = user;

        return user;
      }
      return null;
    } catch (e) {
      // Allow controller to handle error
      rethrow;
    }
  }

  // Update user profile
  Future<User?> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _networkService.patch(
        '/users/update/$userId',
        data: data,
      );

      if (response.statusCode == 200) {
        // Refetch profile to be sure we have latest state
        return await getMe();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
