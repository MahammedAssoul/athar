import '../models/beneficiary.dart';

/// Contract for beneficiary data sources (mock or remote).
///
/// SECURITY: beneficiary records contain sensitive personal data.
/// Implementations must only return records to authorized callers —
/// the backend enforces role-based access. The donor app only ever
/// sees aggregated counts via [getBeneficiaryCount].
abstract class BeneficiaryRepository {
  /// Returns beneficiaries for a campaign (authorized roles only).
  Future<List<Beneficiary>> getBeneficiaries(String campaignId);

  /// Returns a single beneficiary (authorized roles only).
  Future<Beneficiary?> getBeneficiaryById(String id);

  /// Public, safe: total beneficiary count for a campaign.
  Future<int> getBeneficiaryCount(String campaignId);

  /// Returns the needs of a beneficiary (authorized roles only).
  Future<List<Need>> getNeeds(String beneficiaryId);

  /// Returns the support history of a beneficiary (authorized roles only).
  Future<List<SupportRecord>> getSupportHistory(String beneficiaryId);
}
