import '../models/recurring_donation.dart';

/// Contract for recurring donation data sources (mock or remote).
abstract class RecurringDonationRepository {
  Future<List<RecurringDonation>> getRecurringDonations();
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
  });
  Future<RecurringDonation> pause(String id);
  Future<RecurringDonation> resume(String id);
  Future<RecurringDonation> cancel(String id);
}
