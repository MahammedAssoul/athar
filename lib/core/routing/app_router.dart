import 'package:flutter/material.dart';

import '../../features/campaigns/presentation/campaign_details_page.dart';
import '../../features/donations/presentation/donation_details_page.dart';
import '../../features/donations/presentation/donation_flow_page.dart';
import '../../features/donations/presentation/receipt_page.dart';
import '../../features/favorites/presentation/favorites_page.dart';
import '../../features/gifts/presentation/gift_donation_page.dart';
import '../../features/gifts/presentation/gift_success_page.dart';
import '../../features/impact/presentation/impact_page.dart';
import '../../features/notifications/presentation/notification_preferences_page.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/quick_donation/presentation/quick_donation_page.dart';
import '../../features/recurring/presentation/recurring_donations_page.dart';
import '../../features/zakat/presentation/zakat_page.dart';

/// Central route names for the app.
class AppRoutes {
  AppRoutes._();

  static const String campaignDetails = '/campaign';
  static const String donationFlow = '/donation-flow';
  static const String donationDetails = '/donation-details';
  static const String receipt = '/receipt';
  static const String notifications = '/notifications';
  static const String notificationPreferences = '/notification-preferences';
  static const String profile = '/profile';
  static const String recurringDonations = '/recurring-donations';
  static const String giftDonation = '/gift-donation';
  static const String giftSuccess = '/gift-success';
  static const String quickDonation = '/quick-donation';
  static const String zakat = '/zakat';
  static const String favorites = '/favorites';
  static const String impact = '/impact';
}

/// Builds the named route table.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.campaignDetails:
        return _page(
          CampaignDetailsPage(campaignId: settings.arguments as String),
        );
      case AppRoutes.donationFlow:
        return _page(
          DonationFlowPage(campaignId: settings.arguments as String),
        );
      case AppRoutes.donationDetails:
        return _page(
          DonationDetailsPage(donationId: settings.arguments as String),
        );
      case AppRoutes.receipt:
        return _page(ReceiptPage(donationId: settings.arguments as String));
      case AppRoutes.notifications:
        return _page(const NotificationsPage());
      case AppRoutes.notificationPreferences:
        return _page(const NotificationPreferencesPage());
      case AppRoutes.profile:
        return _page(const ProfilePage());
      case AppRoutes.recurringDonations:
        return _page(const RecurringDonationsPage());
      case AppRoutes.giftDonation:
        return _page(
          GiftDonationPage(campaignId: settings.arguments as String),
        );
      case AppRoutes.giftSuccess:
        return _page(GiftSuccessPage(giftId: settings.arguments as String));
      case AppRoutes.quickDonation:
        return _page(const QuickDonationPage());
      case AppRoutes.zakat:
        return _page(const ZakatPage());
      case AppRoutes.favorites:
        return _page(const FavoritesPage());
      case AppRoutes.impact:
        return _page(const ImpactPage());
      default:
        return _page(const Scaffold(body: SizedBox.shrink()));
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child) =>
      MaterialPageRoute<dynamic>(builder: (_) => child);
}
