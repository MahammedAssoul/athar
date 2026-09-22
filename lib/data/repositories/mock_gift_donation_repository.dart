import '../models/gift_donation.dart';
import '../repositories/gift_donation_repository.dart';

/// In-memory gift donation repository backed by mock data.
class MockGiftDonationRepository implements GiftDonationRepository {
  final List<GiftDonation> _items = List.of(_seed);

  static final List<GiftDonation> _seed = [
    GiftDonation(
      id: 'g1',
      campaignId: 'c1',
      campaignTitleAr: 'علاج الطفلة مريم',
      campaignTitleEn: 'Treatment for little Mariam',
      charityNameAr: 'جمعية الأمل الخيرية',
      charityNameEn: 'Al-Amal Charity',
      amount: 50,
      recipientName: 'سارة',
      recipientContact: 'sara@example.com',
      message: 'هدية من القلب 💚',
      date: DateTime(2026, 9, 10, 14, 0),
      reference: 'ATH-G1',
    ),
  ];

  @override
  Future<List<GiftDonation>> getGiftDonations() async => List.of(_items);

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
    final gift = GiftDonation(
      id: 'g${_items.length + 1}',
      campaignId: campaignId,
      campaignTitleAr: campaignTitleAr,
      campaignTitleEn: campaignTitleEn,
      charityNameAr: charityNameAr,
      charityNameEn: charityNameEn,
      amount: amount,
      recipientName: recipientName,
      recipientContact: recipientContact,
      message: message,
      date: DateTime.now(),
      reference: 'ATH-G${_items.length + 1}',
    );
    _items.insert(0, gift);
    return gift;
  }
}
