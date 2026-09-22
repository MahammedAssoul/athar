import '../models/app_user.dart';
import '../repositories/user_repository.dart';
import 'mock_auth_repository.dart';

/// User repository backed by the mock auth session.
class MockUserRepository implements UserRepository {
  final MockAuthRepository _auth = MockAuthRepository();

  @override
  Future<AppUser?> getCurrentUser() => _auth.getCurrentUser();
}
