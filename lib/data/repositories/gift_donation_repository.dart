import '../models/gift_donation.dart';

/// Contract for gift donation data sources (mock or remote).
abstract class GiftDonationRepository {
  Future<List<GiftDonation>> getGiftDonations();
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
  });
}
