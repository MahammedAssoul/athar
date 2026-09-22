import '../models/campaign.dart';
import '../models/charity_profile.dart';

/// Contract for charity management data (mock or remote).
///
/// Charities manage their profile via the charity dashboard (separate
/// app/web). The donor app only reads public profile data through
/// [CharityRepository]; this repository serves the charity-facing and
/// admin-facing operations.
abstract class CharityManagementRepository {
  /// Returns the charity profile (charity/admin roles only).
  Future<CharityProfile?> getCharityProfile(String charityId);

  /// Returns donation statistics for a charity (charity/admin only).
  Future<CharityDonationStats> getCharityStats(String charityId);

  /// Submits a campaign for platform review.
  ///
  /// A charity can never publish a campaign directly — the platform
  /// must approve it first.
  Future<Campaign> submitCampaign(Campaign campaign);

  /// Updates a draft campaign (charity role only).
  Future<Campaign> updateDraftCampaign(Campaign campaign);
}
