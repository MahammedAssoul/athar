import '../mock/mock_beneficiaries.dart';
import '../models/beneficiary.dart';
import '../repositories/beneficiary_repository.dart';

/// In-memory beneficiary repository backed by mock data.
///
/// SECURITY: mock data is fictional. In API mode the backend enforces
/// authorization before serving beneficiary records.
class MockBeneficiaryRepository implements BeneficiaryRepository {
  @override
  Future<List<Beneficiary>> getBeneficiaries(String campaignId) async =>
      MockBeneficiaries.all.where((b) => b.campaignId == campaignId).toList();

  @override
  Future<Beneficiary?> getBeneficiaryById(String id) async {
    for (final b in MockBeneficiaries.all) {
      if (b.id == id) return b;
    }
    return null;
  }

  @override
  Future<int> getBeneficiaryCount(String campaignId) async =>
      MockBeneficiaries.all.where((b) => b.campaignId == campaignId).length;

  @override
  Future<List<Need>> getNeeds(String beneficiaryId) async => MockBeneficiaries
      .needs
      .where((n) => n.beneficiaryId == beneficiaryId)
      .toList();

  @override
  Future<List<SupportRecord>> getSupportHistory(String beneficiaryId) async =>
      MockBeneficiaries.supportHistory
          .where((s) => s.beneficiaryId == beneficiaryId)
          .toList();
}
