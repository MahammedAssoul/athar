import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/beneficiary.dart';
import '../repositories/beneficiary_repository.dart';

/// Real beneficiary repository backed by the Athar backend.
///
/// SECURITY: the backend only returns beneficiary records to
/// authorized roles (owning charity, platform admins). The donor app
/// only calls [getBeneficiaryCount] which is public and aggregated.
class ApiBeneficiaryRepository implements BeneficiaryRepository {
  ApiBeneficiaryRepository({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<Beneficiary>> getBeneficiaries(String campaignId) async {
    final data = await _client.get(
      ApiEndpoints.campaignBeneficiaries(campaignId),
    );
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => Beneficiary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Beneficiary?> getBeneficiaryById(String id) async {
    final data = await _client.get(ApiEndpoints.beneficiary(id));
    return Beneficiary.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<int> getBeneficiaryCount(String campaignId) async {
    final data = await _client.get(
      ApiEndpoints.campaignBeneficiaryCount(campaignId),
    );
    return (data as Map<String, dynamic>)['count'] as int? ?? 0;
  }

  @override
  Future<List<Need>> getNeeds(String beneficiaryId) async {
    final data = await _client.get(
      ApiEndpoints.beneficiaryNeeds(beneficiaryId),
    );
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data.map((e) => Need.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SupportRecord>> getSupportHistory(String beneficiaryId) async {
    final data = await _client.get(
      ApiEndpoints.beneficiarySupportHistory(beneficiaryId),
    );
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => SupportRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
