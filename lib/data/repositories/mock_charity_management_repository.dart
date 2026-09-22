import '../models/campaign.dart';
import '../models/campaign_enums.dart';
import '../models/charity_profile.dart';
import '../repositories/charity_management_repository.dart';

/// In-memory charity management repository.
///
/// Demonstrates the campaign approval flow: a charity can create a
/// draft and submit it, but the campaign only becomes `published` after
/// platform approval (simulated here).
class MockCharityManagementRepository implements CharityManagementRepository {
  final List<Campaign> _drafts = [];

  @override
  Future<CharityProfile?> getCharityProfile(String charityId) async {
    // Mock: return a profile for known charities.
    return CharityProfile(
      id: charityId,
      nameAr: 'جمعية الأمل الخيرية',
      nameEn: 'Al-Amal Charity',
      description: 'جمعية خيرية تعنى بدعم الأسر المحتاجة.',
      logoUrl: '',
      location: 'طرابلس',
      verificationStatus: CharityVerificationStatus.verified,
      campaignCount: 12,
      totalRaised: 240000,
      beneficiaryCount: 850,
      rating: 4.8,
      createdAt: DateTime(2024, 1, 15),
    );
  }

  @override
  Future<CharityDonationStats> getCharityStats(String charityId) async {
    return CharityDonationStats(
      charityId: charityId,
      totalDonations: 240000,
      monthlyDonations: 18500,
      donorCount: 3200,
      campaignCount: 12,
      successfulCampaigns: 5,
      beneficiaryCount: 850,
      updatedAt: DateTime(2026, 9, 18),
    );
  }

  @override
  Future<Campaign> submitCampaign(Campaign campaign) async {
    // A charity can never publish directly — the platform approves.
    final submitted = campaign.copyWith(status: CampaignStatus.submitted);
    _drafts.add(submitted);
    return submitted;
  }

  @override
  Future<Campaign> updateDraftCampaign(Campaign campaign) async {
    final index = _drafts.indexWhere((c) => c.id == campaign.id);
    if (index >= 0) {
      _drafts[index] = campaign;
      return campaign;
    }
    _drafts.add(campaign);
    return campaign;
  }
}
