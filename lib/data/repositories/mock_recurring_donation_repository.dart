import '../models/recurring_donation.dart';
import '../repositories/recurring_donation_repository.dart';

/// In-memory recurring donation repository backed by mock data.
class MockRecurringDonationRepository implements RecurringDonationRepository {
  final List<RecurringDonation> _items = List.of(_seed);

  static final List<RecurringDonation> _seed = [
    RecurringDonation(
      id: 'r1',
      campaignId: 'c3',
      campaignTitleAr: 'كفالة يتيم لمدة عام',
      campaignTitleEn: 'Sponsor an orphan for a year',
      charityNameAr: 'جمعية كفالة اليتيم',
      charityNameEn: 'Orphan Sponsorship Society',
      amount: 100,
      frequency: RecurringFrequency.monthly,
      startDate: DateTime(2026, 8, 1),
      status: RecurringStatus.active,
      paymentMethod: 'بطاقة مصرفية',
    ),
    RecurringDonation(
      id: 'r2',
      campaignId: 'c4',
      campaignTitleAr: 'حفر بئر مياه في سبها',
      campaignTitleEn: 'Water well in Sabha',
      charityNameAr: 'مؤسسة الرحمة للتنمية',
      charityNameEn: 'Al-Rahma Development Foundation',
      amount: 25,
      frequency: RecurringFrequency.weekly,
      startDate: DateTime(2026, 9, 5),
      status: RecurringStatus.paused,
      paymentMethod: 'Apple Pay',
    ),
  ];

  @override
  Future<List<RecurringDonation>> getRecurringDonations() async =>
      List.of(_items);

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
    final item = RecurringDonation(
      id: 'r${_items.length + 1}',
      campaignId: campaignId,
      campaignTitleAr: campaignTitleAr,
      campaignTitleEn: campaignTitleEn,
      charityNameAr: charityNameAr,
      charityNameEn: charityNameEn,
      amount: amount,
      frequency: frequency,
      startDate: startDate,
      status: RecurringStatus.active,
      paymentMethod: paymentMethod,
    );
    _items.insert(0, item);
    return item;
  }

  @override
  Future<RecurringDonation> pause(String id) async =>
      _updateStatus(id, RecurringStatus.paused);

  @override
  Future<RecurringDonation> resume(String id) async =>
      _updateStatus(id, RecurringStatus.active);

  @override
  Future<RecurringDonation> cancel(String id) async =>
      _updateStatus(id, RecurringStatus.cancelled);

  RecurringDonation _updateStatus(String id, RecurringStatus status) {
    final index = _items.indexWhere((r) => r.id == id);
    final updated = _items[index].copyWith(status: status);
    _items[index] = updated;
    return updated;
  }
}
