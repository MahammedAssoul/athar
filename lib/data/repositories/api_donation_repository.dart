import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';

/// Real donation repository backed by the Athar backend.
///
/// Every donation created via the backend receives a unique
/// transaction reference from the server.
class ApiDonationRepository implements DonationRepository {
  ApiDonationRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<Donation>> getDonations() async {
    final data = await _client.get(ApiEndpoints.donations);
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => Donation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Donation?> getDonationById(String id) async {
    final data = await _client.get(ApiEndpoints.donation(id));
    return Donation.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Donation> createDonation({
    required String campaignId,
    required String campaignTitleAr,
    required String campaignTitleEn,
    required String charityNameAr,
    required String charityNameEn,
    required double amount,
    required DonationType type,
    required String paymentMethod,
  }) async {
    final data = await _client.post(
      ApiEndpoints.donations,
      body: {
        'campaignId': campaignId,
        'amount': amount,
        'type': type.name,
        'paymentMethod': paymentMethod,
      },
    );
    return Donation.fromJson(data as Map<String, dynamic>);
  }

  /// Fetches the receipt for a donation.
  Future<Map<String, dynamic>> getReceipt(String donationId) async {
    final data = await _client.get(ApiEndpoints.donationReceipt(donationId));
    return data as Map<String, dynamic>;
  }
}
