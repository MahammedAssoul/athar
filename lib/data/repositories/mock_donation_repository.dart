import '../mock/mock_donations.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';

/// In-memory donation repository backed by mock data.
class MockDonationRepository implements DonationRepository {
  final List<Donation> _donations = List.of(MockDonations.all);

  @override
  Future<List<Donation>> getDonations() async => List.of(_donations);

  @override
  Future<Donation?> getDonationById(String id) async {
    for (final d in _donations) {
      if (d.id == id) return d;
    }
    return null;
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
    final donation = Donation(
      id: 'd${_donations.length + 1}',
      campaignId: campaignId,
      campaignTitleAr: campaignTitleAr,
      campaignTitleEn: campaignTitleEn,
      charityNameAr: charityNameAr,
      charityNameEn: charityNameEn,
      amount: amount,
      date: DateTime.now(),
      status: DonationStatus.success,
      type: type,
      paymentMethod: paymentMethod,
    );
    _donations.insert(0, donation);
    return donation;
  }
}
