/// Campaign lifecycle status.
///
/// A campaign cannot be published by a charity directly — it must pass
/// through platform review and approval first:
///
///   draft → submitted → underReview → approved → published
///                                              ↓
///                                     completed / suspended / rejected
///
/// Only `published` campaigns are visible to donors.
enum CampaignStatus {
  /// Charity is still editing; not visible to anyone.
  draft,

  /// Charity submitted the campaign for platform review.
  submitted,

  /// Platform reviewers are checking the campaign.
  underReview,

  /// Approved by the platform but not yet live.
  approved,

  /// Live and accepting donations.
  published,

  /// Fully funded / ended successfully.
  completed,

  /// Rejected by the platform (with a reason).
  rejected,

  /// Suspended by the platform (fraud / policy violation).
  suspended,
}

/// Categories a campaign can belong to.
enum CampaignCategory {
  treatment,
  food,
  housing,
  education,
  orphans,
  families,
  relief,
  mosques,
  water,
  general,
  debtRelief,
  emergency;

  String get key => name;
}

extension CampaignStatusX on CampaignStatus {
  /// Whether the campaign is live and accepting donations.
  bool get isActive => this == CampaignStatus.published;

  /// Whether the campaign is visible to donors.
  bool get isPublic =>
      this == CampaignStatus.published || this == CampaignStatus.completed;

  /// Whether the campaign is in a pre-publication state.
  bool get isDrafting =>
      this == CampaignStatus.draft ||
      this == CampaignStatus.submitted ||
      this == CampaignStatus.underReview ||
      this == CampaignStatus.approved;

  /// Whether the campaign is in a terminal state.
  bool get isTerminal =>
      this == CampaignStatus.completed ||
      this == CampaignStatus.rejected ||
      this == CampaignStatus.suspended;
}
