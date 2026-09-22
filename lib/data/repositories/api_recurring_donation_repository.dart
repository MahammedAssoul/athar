import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/recurring_donation.dart';
import '../repositories/recurring_donation_repository.dart';

/// Real recurring donation repository backed by the Athar backend.
class ApiRecurringDonationRepository implements RecurringDonationRepository {
  ApiRecurringDonationRepository({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<RecurringDonation>> getRecurringDonations() async {
    final data = await _client.get(ApiEndpoints.recurringDonations);
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => RecurringDonation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RecurringDonation> createRecurringDonation({
    required String campaignId,
    required String campaignTitleAr,
    required String campaignTitleEn,
    required String charityNameAr,
    required String charityNameEn,
    required double amount,
    required RecurringFrequency frequency,
    required DateTime startDate,
    required String paymentMethod,
  }) async {
    final data = await _client.post(
      ApiEndpoints.recurringDonations,
      body: {
        'campaignId': campaignId,
        'amount': amount,
        'frequency': frequency.key,
        'startDate': startDate.toIso8601String(),
        'paymentMethod': paymentMethod,
      },
    );
    return RecurringDonation.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<RecurringDonation> pause(String id) async {
    final data = await _client.post(
      '${ApiEndpoints.recurringDonation(id)}/pause',
    );
    return RecurringDonation.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<RecurringDonation> resume(String id) async {
    final data = await _client.post(
      '${ApiEndpoints.recurringDonation(id)}/resume',
    );
    return RecurringDonation.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<RecurringDonation> cancel(String id) async {
    final data = await _client.post(
      '${ApiEndpoints.recurringDonation(id)}/cancel',
    );
    return RecurringDonation.fromJson(data as Map<String, dynamic>);
  }
}
