import '../../core/services/network_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final NetworkService _networkService;

  AuthRepository(this._networkService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _networkService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      User user;
      String? token;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('user')) {
          user = User.fromJson(data['user']);
        } else {
          user = User.fromJson(data);
        }

        // Extract token from various possible keys
        token = data['token'] ?? data['access_token'] ?? data['auth_token'];
      } else {
        throw Exception('Invalid response format');
      }

      return {'user': user, 'token': token};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _networkService.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      await _networkService.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await _networkService.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'otp':
              otp, // Sending OTP again or a token if the previous step returned one. Assuming OTP for now.
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _networkService.post(
        '/users/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    // await _networkService.post('/auth/logout');
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _networkService.get('/auth/users');
      final data = response.data;

      if (data is List) {
        return data.map((user) => user as Map<String, dynamic>).toList();
      } else if (data is Map<String, dynamic> && data.containsKey('users')) {
        final users = data['users'];
        if (users is List) {
          return users.map((user) => user as Map<String, dynamic>).toList();
        }
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _networkService.post(
        '/auth/add-staff',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phone,
          'role': role,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String role,
    required bool isActive,
  }) async {
    try {
      final response = await _networkService.patch(
        '/users/update/$userId',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phone,
          'role': role,
          'is_active': isActive,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deactivateUser({required String userId}) async {
    try {
      final response = await _networkService.patch(
        '/users/update/$userId',
        data: {'is_active': false},
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _networkService.get('/auth/me');
      
      final data = response.data;
      if (data != null) {
         if (data is Map<String, dynamic>) {
            // Handle {user: {...}} or direct {...}
            if (data.containsKey('user')) {
              return User.fromJson(data['user']);
            }
            return User.fromJson(data);
         }
      }
      return null;
    } catch (e) {
      // If 401, returns null, which AuthService handles by logging out
      return null;
    }
  }
}
