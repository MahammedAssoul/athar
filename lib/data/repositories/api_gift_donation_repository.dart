import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/gift_donation.dart';
import '../repositories/gift_donation_repository.dart';

/// Real gift donation repository backed by the Athar backend.
class ApiGiftDonationRepository implements GiftDonationRepository {
  ApiGiftDonationRepository({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<GiftDonation>> getGiftDonations() async {
    final data = await _client.get(ApiEndpoints.giftDonations);
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => GiftDonation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GiftDonation> createGiftDonation({
    required String campaignId,
    required String campaignTitleAr,
    required String campaignTitleEn,
    required String charityNameAr,
    required String charityNameEn,
    required double amount,
    required String recipientName,
    required String recipientContact,
    String? message,
  }) async {
    final data = await _client.post(
      ApiEndpoints.giftDonations,
      body: {
        'campaignId': campaignId,
        'amount': amount,
        'recipientName': recipientName,
        'recipientContact': recipientContact,
        'message': ?message,
      },
    );
    return GiftDonation.fromJson(data as Map<String, dynamic>);
  }
}
