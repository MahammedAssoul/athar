import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/app_user.dart';
import '../repositories/user_repository.dart';

/// Real user repository backed by the Athar backend.
class ApiUserRepository implements UserRepository {
  ApiUserRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<AppUser?> getCurrentUser() async {
    final data = await _client.get(ApiEndpoints.me);
    return AppUser.fromJson(data as Map<String, dynamic>);
  }
}
