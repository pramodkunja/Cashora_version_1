import 'package:get/get.dart';
import '../../core/services/network_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_update_request.dart';
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

  // Update user profile.
  //
  // Accepts a typed [UserUpdateRequest] so only non-null fields go on the
  // wire — this prevents unrelated columns from being nulled out by a
  // partial profile edit. The PATCH endpoint does not accept email changes.
  Future<User?> updateUser(String userId, UserUpdateRequest request) async {
    try {
      final body = request.toJson();
      if (body.isEmpty) return getMe();

      final response = await _networkService.patch(
        '/users/update/$userId',
        data: body,
      );

      if (response.statusCode == 200) {
        return await getMe();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
