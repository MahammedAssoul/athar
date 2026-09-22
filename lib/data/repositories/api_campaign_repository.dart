import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/campaign.dart';
import '../models/campaign_enums.dart';
import '../repositories/campaign_repository.dart';

/// In-memory cache for campaigns and categories.
///
/// Phase 4: simple TTL-based cache. A more advanced cache (e.g. disk)
/// can replace this later without touching the repository contract.
class CampaignCache {
  CampaignCache({this.ttl = const Duration(minutes: 5)});

  final Duration ttl;

  List<Campaign>? _campaigns;
  DateTime? _campaignsAt;
  List<String>? _categories;
  DateTime? _categoriesAt;

  bool get hasCampaigns =>
      _campaigns != null &&
      _campaignsAt != null &&
      DateTime.now().difference(_campaignsAt!) < ttl;

  bool get hasCategories =>
      _categories != null &&
      _categoriesAt != null &&
      DateTime.now().difference(_categoriesAt!) < ttl;

  List<Campaign>? get campaigns => _campaigns;

  void storeCampaigns(List<Campaign> campaigns) {
    _campaigns = campaigns;
    _campaignsAt = DateTime.now();
  }

  void storeCategories(List<String> categories) {
    _categories = categories;
    _categoriesAt = DateTime.now();
  }

  void invalidate() {
    _campaigns = null;
    _campaignsAt = null;
  }
}

/// Real campaign repository backed by the Athar backend.
class ApiCampaignRepository implements CampaignRepository {
  ApiCampaignRepository({ApiClient? client, CampaignCache? cache})
    : _client = client ?? ApiClient(),
      _cache = cache ?? CampaignCache();

  final ApiClient _client;
  final CampaignCache _cache;

  @override
  Future<List<Campaign>> getCampaigns() async {
    if (_cache.hasCampaigns) return List.of(_cache.campaigns!);
    final data = await _client.get(ApiEndpoints.campaigns);
    final campaigns = _parseList(data);
    _cache.storeCampaigns(campaigns);
    return campaigns;
  }

  @override
  Future<List<Campaign>> getFeaturedCampaigns() async {
    final campaigns = await getCampaigns();
    return campaigns.where((c) => c.isFeatured).toList();
  }

  @override
  Future<List<Campaign>> getUrgentCampaigns() async {
    final campaigns = await getCampaigns();
    return campaigns.where((c) => c.isUrgent && c.isActive).toList();
  }

  @override
  Future<Campaign?> getCampaignById(String id) async {
    // Prefer cache when fresh.
    if (_cache.hasCampaigns) {
      for (final c in _cache.campaigns!) {
        if (c.id == id) return c;
      }
    }
    final data = await _client.get(ApiEndpoints.campaign(id));
    return Campaign.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<Campaign>> searchCampaigns({
    String query = '',
    CampaignCategory? category,
    String? sort,
    CampaignSearchField? searchField,
    Set<CampaignFilter> filters = const {},
  }) async {
    final campaigns = await getCampaigns();
    var results = List.of(campaigns);

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      results = results.where((c) {
        final field = searchField ?? CampaignSearchField.title;
        return switch (field) {
          CampaignSearchField.title =>
            c.titleAr.toLowerCase().contains(q) ||
                c.titleEn.toLowerCase().contains(q),
          CampaignSearchField.charity => c.charityName.toLowerCase().contains(
            q,
          ),
          CampaignSearchField.city => c.location.toLowerCase().contains(q),
          CampaignSearchField.category =>
            c.category.name.toLowerCase().contains(q),
        };
      }).toList();
    }

    if (category != null) {
      results = results.where((c) => c.category == category).toList();
    }

    if (filters.contains(CampaignFilter.urgent)) {
      results = results.where((c) => c.isUrgent).toList();
    }
    if (filters.contains(CampaignFilter.verified)) {
      // Verified status is resolved via the charity; mock: skip locally.
      // A real backend would apply this filter server-side.
    }
    if (filters.contains(CampaignFilter.nearMe)) {
      // Mock: "near me" = user's city. Real backend would use geo.
    }
    if (filters.contains(CampaignFilter.mostNeeded)) {
      results.sort((a, b) => a.progress.compareTo(b.progress));
    }
    if (filters.contains(CampaignFilter.recentlyAdded)) {
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    switch (sort) {
      case CampaignSort.newest:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CampaignSort.mostCollected:
        results.sort((a, b) => b.collectedAmount.compareTo(a.collectedAmount));
        break;
      case CampaignSort.urgentFirst:
        results.sort((a, b) {
          if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    return results;
  }

  @override
  Future<Campaign> updateCampaignCollected(String id, double amount) async {
    final data = await _client.patch(
      ApiEndpoints.campaign(id),
      body: {'collectedAmount': amount},
    );
    final updated = Campaign.fromJson(data as Map<String, dynamic>);
    // Refresh cache with the updated campaign.
    if (_cache.hasCampaigns) {
      final campaigns = List.of(_cache.campaigns!);
      final index = campaigns.indexWhere((c) => c.id == id);
      if (index >= 0) campaigns[index] = updated;
      _cache.storeCampaigns(campaigns);
    }
    return updated;
  }

  /// Fetches campaign categories from the backend (cached).
  Future<List<String>> getCategories() async {
    if (_cache.hasCategories) return List.of(_cache._categories!);
    final data = await _client.get(ApiEndpoints.campaignCategories);
    final categories = (data as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    _cache.storeCategories(categories);
    return categories;
  }

  List<Campaign> _parseList(dynamic data) {
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
