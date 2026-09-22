import '../mock/mock_reports.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';

/// In-memory report repository backed by mock data.
class MockReportRepository implements ReportRepository {
  @override
  Future<List<Report>> getDonationReports(ReportPeriod period) async =>
      MockReports.all.where((r) => r.id == 'r1').toList();

  @override
  Future<List<Report>> getCampaignReports(ReportPeriod period) async =>
      MockReports.all.where((r) => r.id == 'r2').toList();

  @override
  Future<List<Report>> getCharityReports(ReportPeriod period) async =>
      MockReports.all.where((r) => r.id == 'r3').toList();

  @override
  Future<DonationReceipt> getDonationReceipt(String donationId) async {
    return DonationReceipt(
      receiptNumber: 'RCP-${donationId.toUpperCase()}',
      donationId: donationId,
      donorName: 'محمد أحمد',
      amount: 50,
      date: DateTime(2026, 9, 15, 10, 30),
      campaignTitleAr: 'علاج الطفلة مريم',
      campaignTitleEn: 'Treatment for little Mariam',
      charityNameAr: 'جمعية الأمل الخيرية',
      charityNameEn: 'Al-Amal Charity',
      transactionReference: 'ATH-1234567890',
      paymentMethod: 'بطاقة مصرفية',
    );
  }
}
