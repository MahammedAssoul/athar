import '../mock/mock_charities.dart';
import '../models/charity.dart';
import '../repositories/charity_repository.dart';

/// In-memory charity repository backed by mock data.
class MockCharityRepository implements CharityRepository {
  @override
  Future<List<Charity>> getCharities() async => List.of(MockCharities.all);

  @override
  Future<Charity?> getCharityById(String id) async {
    for (final c in MockCharities.all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
