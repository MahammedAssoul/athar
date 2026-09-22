import '../models/app_user.dart';

/// Contract for the currently authenticated user.
abstract class UserRepository {
  /// Returns the logged-in user, or null when signed out.
  Future<AppUser?> getCurrentUser();
}
