import '../models/donation.dart';

/// Aggregated impact metrics for the "My Impact" dashboard.
class ImpactMetrics {
  const ImpactMetrics({
    required this.totalDonated,
    required this.campaignsSupported,
    required this.beneficiaries,
    required this.monthlyContribution,
    required this.annualContribution,
    required this.donationCount,
  });

  final double totalDonated;
  final int campaignsSupported;
  final int beneficiaries;
  final double monthlyContribution;
  final double annualContribution;
  final int donationCount;
}

/// Computes impact metrics from donation data.
///
/// Phase 3: mock calculations from donation history. A real analytics
/// service can replace this implementation later.
abstract class ImpactService {
  Future<ImpactMetrics> compute(List<Donation> donations);
}

/// Mock impact service used when `isMock == true`.
class MockImpactService implements ImpactService {
  const MockImpactService();

  @override
  Future<ImpactMetrics> compute(List<Donation> donations) async {
    final successful = donations.where((d) => d.isSuccessful).toList();
    final total = successful.fold<double>(0, (sum, d) => sum + d.amount);
    final campaigns = successful.map((d) => d.campaignId).toSet().length;

    final now = DateTime.now();
    final monthly = successful
        .where((d) => d.date.month == now.month && d.date.year == now.year)
        .fold<double>(0, (sum, d) => sum + d.amount);
    final annual = successful
        .where((d) => d.date.year == now.year)
        .fold<double>(0, (sum, d) => sum + d.amount);

    // Mock: each supported campaign benefits ~12 people on average.
    final beneficiaries = campaigns * 12;

    return ImpactMetrics(
      totalDonated: total,
      campaignsSupported: campaigns,
      beneficiaries: beneficiaries,
      monthlyContribution: monthly,
      annualContribution: annual,
      donationCount: successful.length,
    );
  }
}
