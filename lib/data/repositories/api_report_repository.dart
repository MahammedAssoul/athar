import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';

/// Real report repository backed by the Athar backend.
///
/// The backend generates reports and can render them as PDF/Excel.
/// The app consumes structured rows and formats them locally.
class ApiReportRepository implements ReportRepository {
  ApiReportRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<Report>> getDonationReports(ReportPeriod period) async {
    final data = await _client.get(
      ApiEndpoints.reports,
      query: {'type': 'donations', 'period': period.name},
    );
    return _parseList(data);
  }

  @override
  Future<List<Report>> getCampaignReports(ReportPeriod period) async {
    final data = await _client.get(
      ApiEndpoints.reports,
      query: {'type': 'campaigns', 'period': period.name},
    );
    return _parseList(data);
  }

  @override
  Future<List<Report>> getCharityReports(ReportPeriod period) async {
    final data = await _client.get(
      ApiEndpoints.reports,
      query: {'type': 'charities', 'period': period.name},
    );
    return _parseList(data);
  }

  @override
  Future<DonationReceipt> getDonationReceipt(String donationId) async {
    final data = await _client.get(ApiEndpoints.donationReceipt(donationId));
    return DonationReceipt.fromJson(data as Map<String, dynamic>);
  }

  List<Report> _parseList(dynamic data) {
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data.map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
  }
}
