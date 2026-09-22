import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/campaign.dart';
import '../models/charity.dart';
import '../repositories/charity_repository.dart';

/// In-memory cache for charities.
class CharityCache {
  CharityCache({this.ttl = const Duration(minutes: 10)});

  final Duration ttl;

  List<Charity>? _charities;
  DateTime? _at;

  bool get hasCharities =>
      _charities != null &&
      _at != null &&
      DateTime.now().difference(_at!) < ttl;

  List<Charity>? get charities => _charities;

  void store(List<Charity> charities) {
    _charities = charities;
    _at = DateTime.now();
  }
}

/// Real charity repository backed by the Athar backend.
class ApiCharityRepository implements CharityRepository {
  ApiCharityRepository({ApiClient? client, CharityCache? cache})
    : _client = client ?? ApiClient(),
      _cache = cache ?? CharityCache();

  final ApiClient _client;
  final CharityCache _cache;

  @override
  Future<List<Charity>> getCharities() async {
    if (_cache.hasCharities) return List.of(_cache.charities!);
    final data = await _client.get(ApiEndpoints.charities);
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    final charities = data
        .map((e) => Charity.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache.store(charities);
    return charities;
  }

  @override
  Future<Charity?> getCharityById(String id) async {
    if (_cache.hasCharities) {
      for (final c in _cache.charities!) {
        if (c.id == id) return c;
      }
    }
    final data = await _client.get(ApiEndpoints.charity(id));
    return Charity.fromJson(data as Map<String, dynamic>);
  }

  /// Fetches the campaigns of a specific charity.
  Future<List<Campaign>> getCharityCampaigns(String charityId) async {
    final data = await _client.get(ApiEndpoints.charityCampaigns(charityId));
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
