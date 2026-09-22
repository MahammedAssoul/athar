import '../models/app_notification.dart';

/// Demo notifications. Fictional content used for Phase 1 only.
class MockNotifications {
  MockNotifications._();

  static final List<AppNotification> all = [
    AppNotification(
      id: 'n1',
      titleAr: 'تم استلام تبرعك بنجاح',
      titleEn: 'Your donation was received',
      bodyAr: 'شكراً لك! تم استلام تبرعك لحملة علاج الطفلة مريم بمبلغ 50 د.ل.',
      bodyEn:
          'Thank you! Your donation of 50 LYD to Mariam\'s treatment campaign was received.',
      date: DateTime(2026, 9, 15, 10, 30),
      type: NotificationType.donation,
      isRead: false,
    ),
    AppNotification(
      id: 'n2',
      titleAr: 'تم اكتمال حملة سلة رمضان',
      titleEn: 'Ramadan baskets campaign completed',
      bodyAr:
          'الحمد لله، تم جمع الهدف الكامل لحملة سلة رمضان وتم توزيع السلال على 500 أسرة.',
      bodyEn:
          'Praise be to God, the full target for the Ramadan baskets campaign was reached and baskets were distributed to 500 families.',
      date: DateTime(2026, 9, 14, 18, 0),
      type: NotificationType.campaign,
      isRead: false,
    ),
    AppNotification(
      id: 'n3',
      titleAr: 'لديك فرصة تبرع جديدة',
      titleEn: 'New donation opportunity',
      bodyAr:
          'حملة حفر بئر مياه في سبها تحتاج دعمك الآن. تبرعك يصنع فرقاً حقيقياً.',
      bodyEn:
          'The Sabha water well campaign needs your support now. Your donation makes a real difference.',
      date: DateTime(2026, 9, 13, 9, 15),
      type: NotificationType.general,
      isRead: true,
    ),
    AppNotification(
      id: 'n4',
      titleAr: 'تذكير بصدقتك الجارية',
      titleEn: 'Recurring sadaqah reminder',
      bodyAr: 'سيتم تجديد تبرعك الشهري لكفالة يتيم خلال 3 أيام.',
      bodyEn: 'Your monthly orphan sponsorship donation will renew in 3 days.',
      date: DateTime(2026, 9, 12, 20, 45),
      type: NotificationType.recurring,
      isRead: true,
    ),
    AppNotification(
      id: 'n5',
      titleAr: 'حملة جديدة من جمعية موثقة',
      titleEn: 'New campaign from a verified charity',
      bodyAr:
          'أطلقت مؤسسة النور الإنسانية حملة علاج مرضى الفشل الكلوي في سبها.',
      bodyEn:
          'Al-Noor Humanitarian Foundation launched a kidney failure treatment campaign in Sabha.',
      date: DateTime(2026, 9, 10, 14, 20),
      type: NotificationType.campaign,
      isRead: true,
    ),
    AppNotification(
      id: 'n6',
      titleAr: 'تحديث أثرك',
      titleEn: 'Your impact update',
      bodyAr: 'وصل إجمالي تبرعاتك إلى 535 د.ل — واصل صنع الأثر!',
      bodyEn: 'Your total donations reached 535 LYD — keep making an impact!',
      date: DateTime(2026, 9, 8, 9, 0),
      type: NotificationType.impact,
      isRead: true,
    ),
    AppNotification(
      id: 'n7',
      titleAr: 'تحديث حملة علاج الطفلة مريم',
      titleEn: 'Mariam\'s treatment campaign update',
      bodyAr: 'تم إجراء العملية بنجاح والحمد لله، الطفلة مريم في حالة جيدة.',
      bodyEn:
          'The surgery was successful, praise be to God. Mariam is in good condition.',
      date: DateTime(2026, 9, 5, 16, 30),
      type: NotificationType.campaign,
      isRead: true,
    ),
    AppNotification(
      id: 'n8',
      titleAr: 'رسالة من فريق أثر',
      titleEn: 'Message from the Athar team',
      bodyAr: 'نعمل على تحسين تجربتك — شكراً لكونك جزءاً من مجتمع العطاء.',
      bodyEn:
          'We are working to improve your experience — thank you for being part of the giving community.',
      date: DateTime(2026, 9, 1, 11, 0),
      type: NotificationType.system,
      isRead: true,
    ),
  ];
}
