import '../models/donation.dart';

/// Contract for donation data sources (mock or remote).
abstract class DonationRepository {
  Future<List<Donation>> getDonations();
  Future<Donation?> getDonationById(String id);
  Future<Donation> createDonation({
    required String campaignId,
    required String campaignTitleAr,
    required String campaignTitleEn,
    required String charityNameAr,
    required String charityNameEn,
    required double amount,
    required DonationType type,
    required String paymentMethod,
  });
}
