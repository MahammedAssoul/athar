import '../models/charity.dart';

/// Contract for charity data sources (mock or remote).
abstract class CharityRepository {
  Future<List<Charity>> getCharities();
  Future<Charity?> getCharityById(String id);
}
