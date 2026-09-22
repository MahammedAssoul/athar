import 'package:flutter/material.dart';

import 'app_locales.dart';
import 'app_localizations_delegate.dart';

/// All user-facing strings for the Athar app (Arabic default, English fallback).
class AppStrings {
  AppStrings(this._code);

  final String _code;

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  static const LocalizationsDelegate<AppStrings> delegate =
      AppLocalizationsDelegate();

  bool get isAr => _code == AppLocales.ar;

  String _t(String ar, String en) => isAr ? ar : en;

  // ── App ────────────────────────────────────────────────
  String get appName => _t('أثر', 'Athar');
  String get appTagline => _t('منصة العطاء الليبية', 'Libyan giving platform');

  // ── Navigation ─────────────────────────────────────────
  String get navHome => _t('الرئيسية', 'Home');
  String get navOpportunities => _t('فرص التبرع', 'Opportunities');
  String get navDonations => _t('تبرعاتي', 'My Donations');
  String get navNotifications => _t('الإشعارات', 'Notifications');
  String get navProfile => _t('حسابي', 'Profile');

  // ── Common ─────────────────────────────────────────────
  String get donateNow => _t('تبرع الآن', 'Donate Now');
  String get shareCampaign => _t('شارك الحملة', 'Share Campaign');
  String get viewAll => _t('عرض الكل', 'View All');
  String get search => _t('بحث', 'Search');
  String get searchHint =>
      _t('ابحث عن حملة أو جمعية...', 'Search campaigns or charities...');
  String get filters => _t('تصفية', 'Filters');
  String get sort => _t('ترتيب', 'Sort');
  String get apply => _t('تطبيق', 'Apply');
  String get reset => _t('إعادة تعيين', 'Reset');
  String get cancel => _t('إلغاء', 'Cancel');
  String get close => _t('إغلاق', 'Close');
  String get retry => _t('إعادة المحاولة', 'Retry');
  String get loading => _t('جارٍ التحميل...', 'Loading...');
  String get noResults => _t('لا توجد نتائج', 'No results found');
  String get noResultsHint => _t(
    'جرّب تغيير البحث أو التصفية.',
    'Try changing your search or filters.',
  );
  String get somethingWrong => _t('حدث خطأ ما', 'Something went wrong');
  String get somethingWrongHint =>
      _t('يرجى المحاولة مرة أخرى.', 'Please try again.');
  String get lyd => _t('د.ل', 'LYD');
  String get back => _t('رجوع', 'Back');
  String get next => _t('التالي', 'Next');
  String get confirm => _t('تأكيد', 'Confirm');
  String get pay => _t('ادفع', 'Pay');
  String get done => _t('تم', 'Done');
  String get optional => _t('اختياري', 'Optional');
  String get demoData => _t('بيانات تجريبية', 'Demo data');
  String get demoDataHint => _t(
    'هذه بيانات تجريبية لأغراض العرض فقط.',
    'This is demo data for display purposes only.',
  );

  // ── Home ───────────────────────────────────────────────
  String greeting(String name) => _t('مرحباً $name 👋', 'Hello $name 👋');
  String get homeCtaTitle => _t('اصنع أثراً اليوم', 'Make an impact today');
  String get homeCtaSubtitle => _t(
    'تبرعك قد يصنع فرقاً في حياة شخص يحتاجك',
    'Your donation can change a life in need',
  );
  String get quickDonate => _t('تبرع سريع', 'Quick Donate');
  String get categories => _t('فئات التبرع', 'Donation Categories');
  String get featuredCampaigns => _t('حملات مميزة', 'Featured Campaigns');
  String get urgentCampaigns => _t('حملات عاجلة', 'Urgent Campaigns');
  String get impactStats => _t('أثرنا معاً', 'Our Impact');
  String get beneficiaries => _t('مستفيد', 'Beneficiaries');
  String get projects => _t('مشروع', 'Projects');
  String get charities => _t('جمعية', 'Charities');

  // ── Campaigns ──────────────────────────────────────────
  String get opportunitiesTitle => _t('فرص التبرع', 'Donation Opportunities');
  String get allCategories => _t('كل الفئات', 'All Categories');
  String get sortNewest => _t('الأحدث', 'Newest');
  String get sortMostCollected => _t('الأعلى جمعاً', 'Most Collected');
  String get sortUrgentFirst => _t('العاجلة أولاً', 'Urgent First');
  String get target => _t('الهدف', 'Target');
  String get collected => _t('تم جمع', 'Collected');
  String get remaining => _t('المتبقي', 'Remaining');
  String get progress => _t('نسبة التحصيل', 'Progress');
  String get beneficiariesCount => _t('عدد المستفيدين', 'Beneficiaries');
  String get deadline => _t('آخر موعد', 'Deadline');
  String get location => _t('الموقع', 'Location');
  String get urgent => _t('عاجل', 'Urgent');
  String get aboutCampaign => _t('عن الحملة', 'About this campaign');
  String get campaignStatus => _t('حالة الحملة', 'Status');
  String get statusActive => _t('نشطة', 'Active');
  String get statusCompleted => _t('مكتملة', 'Completed');
  String get statusClosed => _t('مغلقة', 'Closed');
  String get daysLeft => _t('يوم متبقي', 'days left');
  String get noCampaigns => _t('لا توجد حملات', 'No campaigns found');

  // ── Donation flow ──────────────────────────────────────
  String get chooseAmount => _t('اختر مبلغ التبرع', 'Choose Donation Amount');
  String get otherAmount => _t('مبلغ آخر', 'Other Amount');
  String get enterAmount => _t('أدخل المبلغ', 'Enter amount');
  String get recurringSadaqah =>
      _t('اجعل تبرعي صدقة جارية', 'Make my donation a recurring Sadaqah');
  String get recurringSadaqahHint => _t(
    'تبرع شهري متكرر يصل تلقائياً كل شهر.',
    'A monthly recurring donation sent automatically.',
  );
  String get summary => _t('ملخص التبرع', 'Donation Summary');
  String get payment => _t('الدفع', 'Payment');
  String get paymentMethod => _t('طريقة الدفع', 'Payment Method');
  String get card => _t('بطاقة مصرفية', 'Bank Card');
  String get applePay => _t('Apple Pay', 'Apple Pay');
  String get bankTransfer => _t('تحويل مصرفي', 'Bank Transfer');
  String get mockPaymentNote => _t(
    'هذه محاكاة دفع تجريبية — لن يتم خصم أي مبلغ.',
    'This is a mock payment — no amount will be charged.',
  );
  String get processing => _t('جارٍ معالجة الدفع...', 'Processing payment...');
  String get paymentFailed => _t('فشل الدفع', 'Payment Failed');
  String get paymentFailedHint =>
      _t('يرجى المحاولة مرة أخرى.', 'Please try again.');
  String get donationSuccess =>
      _t('تم التبرع بنجاح ❤️', 'Donation Successful ❤️');
  String get donationSuccessHint =>
      _t('شكراً لمساهمتك في صنع أثر.', 'Thank you for making an impact.');
  String get viewReceipt => _t('عرض الإيصال', 'View Receipt');
  String get backHome => _t('العودة للرئيسية', 'Back to Home');
  String get donationReceipt => _t('إيصال التبرع', 'Donation Receipt');
  String get receiptNo => _t('رقم الإيصال', 'Receipt No.');
  String get date => _t('التاريخ', 'Date');
  String get amount => _t('المبلغ', 'Amount');
  String get campaign => _t('الحملة', 'Campaign');
  String get charity => _t('الجمعية', 'Charity');
  String get status => _t('الحالة', 'Status');
  String get statusSuccess => _t('ناجح', 'Successful');
  String get statusPending => _t('قيد المعالجة', 'Pending');
  String get statusFailed => _t('فشل', 'Failed');
  String get recurring => _t('صدقة جارية', 'Recurring');
  String get oneTime => _t('تبرع لمرة واحدة', 'One-time');

  // ── My Donations ───────────────────────────────────────
  String get myDonations => _t('تبرعاتي', 'My Donations');
  String get totalDonated => _t('إجمالي التبرعات', 'Total Donated');
  String get donationsCount => _t('عدد التبرعات', 'Donations');
  String get thisMonth => _t('هذا الشهر', 'This Month');
  String get recentDonations => _t('أحدث التبرعات', 'Recent Donations');
  String get noDonations => _t('لا توجد تبرعات بعد', 'No donations yet');
  String get noDonationsHint => _t(
    'ابدأ رحلة العطاء واصنع أثراً اليوم.',
    'Start giving and make an impact today.',
  );
  String get donationDetails => _t('تفاصيل التبرع', 'Donation Details');
  String get receipt => _t('الإيصال', 'Receipt');

  // ── Charities ──────────────────────────────────────────
  String get verified => _t('جهة موثقة', 'Verified');
  String get campaignsCount => _t('حملة', 'Campaigns');
  String get aboutCharity => _t('عن الجمعية', 'About the Charity');
  String get noCharities => _t('لا توجد جمعيات', 'No charities found');

  // ── Notifications ──────────────────────────────────────
  String get notifications => _t('الإشعارات', 'Notifications');
  String get markAllRead => _t('تعليم الكل كمقروء', 'Mark all as read');
  String get noNotifications => _t('لا توجد إشعارات', 'No notifications');
  String get noNotificationsHint => _t(
    'ستظهر هنا تحديثات تبرعاتك.',
    'Updates about your donations will appear here.',
  );
  String get read => _t('مقروء', 'Read');
  String get unread => _t('غير مقروء', 'Unread');

  // ── Profile ────────────────────────────────────────────
  String get profile => _t('حسابي', 'Profile');
  String get settings => _t('الإعدادات', 'Settings');
  String get language => _t('اللغة', 'Language');
  String get languageHint => _t('العربية / English', 'Arabic / English');
  String get notificationsSetting => _t('الإشعارات', 'Notifications');
  String get notificationsSettingHint =>
      _t('إدارة تنبيهات التطبيق', 'Manage app alerts');
  String get privacy => _t('الخصوصية', 'Privacy');
  String get about => _t('حول التطبيق', 'About');
  String get terms => _t('الشروط والأحكام', 'Terms & Conditions');
  String get logout => _t('تسجيل الخروج', 'Log Out');
  String get logoutHint => _t(
    'سيتم تفعيل تسجيل الدخول في مرحلة لاحقة.',
    'Authentication will be enabled in a later phase.',
  );
  String get memberSince => _t('عضو منذ', 'Member since');
  String get editProfile => _t('تعديل الملف', 'Edit Profile');

  // ── Misc ───────────────────────────────────────────────
  String get demoUser => _t('محمد', 'Mohammed');
  String get demoUserFull => _t('محمد أحمد', 'Mohammed Ahmed');
  String get demoEmail => 'mohammed@example.com';
  String get demoPhone => '091 234 5678';
  String get demoLocation => _t('طرابلس، ليبيا', 'Tripoli, Libya');

  // ── Auth ───────────────────────────────────────────────
  String get welcome => _t('مرحباً بك في أثر', 'Welcome to Athar');
  String get welcomeSubtitle => _t(
    'أدخل رقم هاتفك للبدء في رحلة العطاء',
    'Enter your phone number to start giving',
  );
  String get phone => _t('رقم الهاتف', 'Phone Number');
  String get phoneHint => _t('09X XXX XXXX', '09X XXX XXXX');
  String get firstName => _t('الاسم الأول', 'First Name');
  String get lastName => _t('اسم العائلة', 'Last Name');
  String get email => _t('البريد الإلكتروني', 'Email');
  String get emailHint => _t('name@example.com', 'name@example.com');
  String get city => _t('المدينة', 'City');
  String get cityHint =>
      _t('طرابلس، بنغازي، مصراتة...', 'Tripoli, Benghazi, Misrata...');
  String get login => _t('تسجيل الدخول', 'Log In');
  String get register => _t('إنشاء حساب', 'Create Account');
  String get registerTitle => _t('إنشاء حساب جديد', 'Create a new account');
  String get registerSubtitle => _t(
    'أدخل بياناتك لإنشاء حسابك على أثر',
    'Enter your details to create your Athar account',
  );
  String get sendOtp => _t('إرسال الرمز', 'Send Code');
  String get verify => _t('تحقق', 'Verify');
  String get otpTitle => _t('رمز التحقق', 'Verification Code');
  String get otpSubtitle => _t(
    'أدخل الرمز المكون من 4 أرقام المرسل إلى هاتفك',
    'Enter the 4-digit code sent to your phone',
  );
  String get otpHint => _t('أدخل رمز التحقق', 'Enter verification code');
  String get otpDemoNote =>
      _t('في الوضع التجريبي، الرمز هو 1234', 'In demo mode, the code is 1234');
  String get resendCode => _t('إعادة إرسال الرمز', 'Resend Code');
  String get forgotPassword => _t('نسيت كلمة المرور؟', 'Forgot Password?');
  String get forgotPasswordTitle => _t('استعادة كلمة المرور', 'Reset Password');
  String get forgotPasswordSubtitle => _t(
    'أدخل رقم هاتفك وكلمة المرور الجديدة',
    'Enter your phone and a new password',
  );
  String get newPassword => _t('كلمة المرور الجديدة', 'New Password');
  String get newPasswordHint =>
      _t('أدخل كلمة مرور جديدة', 'Enter a new password');
  String get resetPassword => _t('إعادة تعيين', 'Reset Password');
  String get passwordResetSuccess =>
      _t('تم تغيير كلمة المرور بنجاح', 'Password reset successfully');
  String get invalidOtp =>
      _t('رمز التحقق غير صحيح', 'Invalid verification code');
  String get invalidPhone =>
      _t('يرجى إدخال رقم هاتف صحيح', 'Please enter a valid phone number');
  String get requiredField => _t('هذا الحقل مطلوب', 'This field is required');
  String get otpSent => _t('تم إرسال الرمز بنجاح', 'Code sent successfully');
  String get needAccount => _t('ليس لديك حساب؟', 'Don\'t have an account?');
  String get haveAccount => _t('لديك حساب بالفعل؟', 'Already have an account?');
  String get signUp => _t('سجّل الآن', 'Sign Up');
  String get signIn => _t('سجّل دخول', 'Sign In');
  String get authFailed => _t('فشل تسجيل الدخول', 'Login failed');
  String get verifyOtpFailed => _t('فشل التحقق', 'Verification failed');

  // ── Onboarding ─────────────────────────────────────────
  String get skip => _t('تخطي', 'Skip');
  String get continueLabel => _t('متابعة', 'Continue');
  String get getStarted => _t('ابدأ الآن', 'Get Started');
  String get onboardingTitle1 => _t('سهولة التبرع', 'Easy Donations');
  String get onboardingSub1 => _t(
    'تبرع لأي حملة بخطوات بسيطة وسريعة',
    'Donate to any campaign in a few simple steps',
  );
  String get onboardingTitle2 => _t('فرص موثوقة', 'Verified Opportunities');
  String get onboardingSub2 => _t(
    'حملات من جمعيات موثوقة ومدققة',
    'Campaigns from verified and trusted charities',
  );
  String get onboardingTitle3 => _t('أثر واضح', 'Clear Impact');
  String get onboardingSub3 => _t(
    'تابع أثر تبرعاتك ونتائجها أولاً بأول',
    'Track your donations and their impact in real time',
  );
  String get onboardingTitle4 => _t('تبرع آمن', 'Secure Donations');
  String get onboardingSub4 => _t(
    'مدفوعات آمنة وخصوصية كاملة لبياناتك',
    'Secure payments and full privacy for your data',
  );

  // ── Profile (phase 2) ──────────────────────────────────
  String get personalInfo => _t('المعلومات الشخصية', 'Personal Information');
  String get security => _t('الأمان', 'Security');
  String get securityHint =>
      _t('كلمة المرور والتحقق', 'Password & verification');
  String get save => _t('حفظ', 'Save');
  String get saved => _t('تم الحفظ بنجاح', 'Saved successfully');
  String get edit => _t('تعديل', 'Edit');
  String get confirmLogout =>
      _t('هل تريد تسجيل الخروج؟', 'Are you sure you want to log out?');
  String get logoutConfirm => _t('تسجيل الخروج', 'Log Out');
  String get logoutSuccess => _t('تم تسجيل الخروج', 'Logged out successfully');
  String get loginRequired =>
      _t('يرجى تسجيل الدخول أولاً', 'Please log in first');
  String get notVerified => _t('غير موثق', 'Not verified');

  // ── Donation history filters ───────────────────────────
  String get filterAll => _t('الكل', 'All');
  String get filterThisMonth => _t('هذا الشهر', 'This Month');
  String get filterThisYear => _t('هذه السنة', 'This Year');
  String get campaignsSupported =>
      _t('الحملات المدعومة', 'Campaigns Supported');

  // ── Phase 3: Recurring donations ───────────────────────
  String get recurringDonations =>
      _t('التبرعات المتكررة', 'Recurring Donations');
  String get recurringDonationsHint => _t(
    'تبرعات تلقائية تصنع أثراً مستمراً',
    'Automatic donations that create lasting impact',
  );
  String get newRecurringDonation =>
      _t('تبرع متكرر جديد', 'New Recurring Donation');
  String get frequency => _t('التكرار', 'Frequency');
  String get daily => _t('يومي', 'Daily');
  String get weekly => _t('أسبوعي', 'Weekly');
  String get monthly => _t('شهري', 'Monthly');
  String get startDate => _t('تاريخ البدء', 'Start Date');
  String get recurringStatusActive => _t('نشط', 'Active');
  String get statusPaused => _t('متوقف مؤقتاً', 'Paused');
  String get statusCancelled => _t('ملغي', 'Cancelled');
  String get pause => _t('إيقاف مؤقت', 'Pause');
  String get resume => _t('استئناف', 'Resume');
  String get cancelRecurring => _t('إلغاء', 'Cancel');
  String get noRecurringDonations =>
      _t('لا توجد تبرعات متكررة', 'No recurring donations');
  String get noRecurringDonationsHint => _t(
    'أنشئ تبرعاً متكرراً ليصل تلقائياً كل يوم أو أسبوع أو شهر.',
    'Create a recurring donation to be sent automatically daily, weekly or monthly.',
  );
  String get recurringPaused => _t('تم إيقاف التبرع مؤقتاً', 'Donation paused');
  String get recurringResumed => _t('تم استئناف التبرع', 'Donation resumed');
  String get recurringCancelled => _t('تم إلغاء التبرع', 'Donation cancelled');
  String get confirmCancelRecurring => _t(
    'هل تريد إلغاء هذا التبرع المتكرر؟',
    'Are you sure you want to cancel this recurring donation?',
  );
  String get confirmPauseRecurring => _t(
    'هل تريد إيقاف هذا التبرع المتكرر مؤقتاً؟',
    'Are you sure you want to pause this recurring donation?',
  );
  String get recurringCreated => _t(
    'تم إنشاء التبرع المتكرر بنجاح',
    'Recurring donation created successfully',
  );
  String get nextPayment => _t('الدفعة القادمة', 'Next Payment');
  String get everyDay => _t('كل يوم', 'Every day');
  String get everyWeek => _t('كل أسبوع', 'Every week');
  String get everyMonth => _t('كل شهر', 'Every month');

  // ── Phase 3: Gift donation ─────────────────────────────
  String get giftDonation => _t('تبرع كهدية', 'Gift Donation');
  String get giftDonationHint => _t(
    'أهدِ تبرعاً لشخص عزيز على قلبك',
    'Give a donation as a gift to someone you care about',
  );
  String get recipientName => _t('اسم المستلم', 'Recipient Name');
  String get recipientNameHint => _t('مثال: سارة أحمد', 'e.g. Sara Ahmed');
  String get recipientContact =>
      _t('هاتف أو بريد المستلم', 'Recipient Phone/Email');
  String get recipientContactHint => _t(
    '09X XXX XXXX أو name@example.com',
    '09X XXX XXXX or name@example.com',
  );
  String get giftMessage => _t('رسالة الهدية', 'Gift Message');
  String get giftMessageHint => _t(
    'اكتب رسالة جميلة للمستلم (اختياري)',
    'Write a nice message for the recipient (optional)',
  );
  String get previewGift => _t('معاينة الهدية', 'Preview Gift');
  String get giftPreview => _t('معاينة الهدية', 'Gift Preview');
  String get giftTo => _t('إلى', 'To');
  String get giftFrom => _t('من', 'From');
  String get giftSent => _t('تم إرسال الهدية 🎁', 'Gift Sent 🎁');
  String get giftSentHint => _t(
    'سيصلك إشعار عند استلام المستلم لهديتك.',
    'You will be notified when the recipient receives your gift.',
  );
  String get giftConfirmation => _t('تأكيد الهدية', 'Gift Confirmation');
  String get giftDetails => _t('تفاصيل الهدية', 'Gift Details');
  String get giftReference => _t('مرجع الهدية', 'Gift Reference');
  String get sendGift => _t('إرسال الهدية', 'Send Gift');
  String get myGifts => _t('هداياي', 'My Gifts');
  String get noGifts => _t('لا توجد هدايا بعد', 'No gifts yet');
  String get noGiftsHint => _t(
    'أهدِ تبرعاً لشخص عزيز وشاركه الأثر.',
    'Give a donation as a gift and share the impact.',
  );
  String get giftFor => _t('هدية لـ', 'Gift for');
  String get giftMessageLabel => _t('الرسالة', 'Message');

  // ── Phase 3: Quick donation ────────────────────────────
  String get quickDonation => _t('تبرع سريع', 'Quick Donation');
  String get quickDonationHint => _t(
    'اختر الفئة والمبلغ وتبرع مباشرة',
    'Choose a category and amount, then donate directly',
  );
  String get chooseCategory => _t('اختر الفئة', 'Choose Category');
  String get chooseQuickAmount => _t('اختر المبلغ', 'Choose Amount');
  String get quickDonateNow => _t('تبرع الآن', 'Donate Now');
  String get quickDonationSuccess =>
      _t('تم التبرع السريع بنجاح', 'Quick donation successful');

  // ── Phase 3: Zakat ─────────────────────────────────────
  String get zakat => _t('الزكاة', 'Zakat');
  String get zakatCalculator => _t('حاسبة الزكاة', 'Zakat Calculator');
  String get zakatHint => _t(
    'احسب زكاتك بسهولة ودقة',
    'Calculate your zakat easily and accurately',
  );
  String get zakatCash => _t('النقود', 'Cash');
  String get zakatGold => _t('الذهب', 'Gold');
  String get zakatSilver => _t('الفضة', 'Silver');
  String get zakatInvestments => _t('الاستثمارات', 'Investments');
  String get zakatOther => _t('أصول أخرى', 'Other Assets');
  String get zakatTotalAssets => _t('إجمالي الأصول', 'Total Assets');
  String get zakatDue => _t('الزكاة المستحقة', 'Zakat Due');
  String get zakatRate => _t('نسبة الزكاة', 'Zakat Rate');
  String get zakatRateValue => _t('2.5%', '2.5%');
  String get zakatAddAsset => _t('إضافة أصل', 'Add Asset');
  String get zakatAssetAmount => _t('قيمة الأصل', 'Asset Value');
  String get zakatDisclaimer => _t(
    'هذه الحاسبة إرشادية فقط — يرجى مراجعة الجهات المختصة وفق الضوابط الشرعية المعمول بها.',
    'This calculator is informational only — please review it according to applicable religious guidance.',
  );
  String get zakatEmpty =>
      _t('أضف أصولك لحساب الزكاة', 'Add your assets to calculate zakat');
  String get zakatRemove => _t('حذف', 'Remove');

  // ── Phase 3: Favorites ─────────────────────────────────
  String get favorites => _t('المفضلة', 'Favorites');
  String get favoritesHint =>
      _t('احفظ الحملات التي تهمك', 'Save campaigns you care about');
  String get noFavorites => _t('لا توجد حملات مفضلة', 'No favorite campaigns');
  String get noFavoritesHint => _t(
    'اضغط على أيقونة القلب لإضافة حملة إلى المفضلة.',
    'Tap the heart icon to add a campaign to your favorites.',
  );
  String get addToFavorites => _t('أضف إلى المفضلة', 'Add to Favorites');
  String get removeFromFavorites =>
      _t('إزالة من المفضلة', 'Remove from Favorites');
  String get addedToFavorites =>
      _t('تمت الإضافة إلى المفضلة', 'Added to favorites');
  String get removedFromFavorites =>
      _t('تمت الإزالة من المفضلة', 'Removed from favorites');

  // ── Phase 3: Impact ────────────────────────────────────
  String get myImpact => _t('أثري', 'My Impact');
  String get impactHint =>
      _t('أثرك يظهر في كل تبرع', 'Your impact shows in every donation');
  String get totalDonatedImpact => _t('إجمالي ما تبرعت به', 'Total Donated');
  String get campaignsSupportedImpact =>
      _t('حملات دعمتها', 'Campaigns Supported');
  String get beneficiariesImpact => _t('مستفيدون', 'Beneficiaries');
  String get monthlyContribution =>
      _t('مساهمة هذا الشهر', 'Monthly Contribution');
  String get annualContribution =>
      _t('مساهمة هذه السنة', 'Annual Contribution');
  String get donationCountImpact => _t('عدد التبرعات', 'Donations');
  String get impactSummary => _t('ملخص الأثر', 'Impact Summary');
  String get keepGoing => _t('واصل العطاء', 'Keep Giving');

  // ── Phase 3: Receipt actions ───────────────────────────
  String get downloadPdf => _t('تحميل PDF', 'Download PDF');
  String get shareReceipt => _t('مشاركة الإيصال', 'Share Receipt');
  String get printReceipt => _t('طباعة الإيصال', 'Print Receipt');
  String get receiptDownloaded => _t('تم تحميل الإيصال', 'Receipt downloaded');
  String get receiptShared => _t('تمت مشاركة الإيصال', 'Receipt shared');
  String get receiptPrinted => _t('تمت طباعة الإيصال', 'Receipt printed');
  String get receiptPdfReady => _t('ملف PDF جاهز', 'PDF file ready');
  String get donor => _t('المتبرع', 'Donor');
  String get transactionReference =>
      _t('مرجع العملية', 'Transaction Reference');
  String get donationTypeLabel => _t('نوع التبرع', 'Donation Type');

  // ── Phase 3: Notifications expansion ───────────────────
  String get notificationPreferences =>
      _t('تفضيلات الإشعارات', 'Notification Preferences');
  String get notificationPreferencesHint => _t(
    'اختر الإشعارات التي تريد استلامها',
    'Choose which notifications you want to receive',
  );
  String get prefDonationSuccess => _t('نجاح التبرع', 'Donation Success');
  String get prefCampaignCompleted => _t('اكتمال الحملة', 'Campaign Completed');
  String get prefCampaignUpdates => _t('تحديثات الحملات', 'Campaign Updates');
  String get prefRecurringDonation =>
      _t('التبرعات المتكررة', 'Recurring Donations');
  String get prefImpactUpdates => _t('تحديثات الأثر', 'Impact Updates');
  String get prefSystemMessages => _t('رسائل النظام', 'System Messages');
  String get preferencesSaved => _t('تم حفظ التفضيلات', 'Preferences saved');

  // ── Phase 3: Home personalization ──────────────────────
  String get recommendedForYou => _t('موصى بها لك', 'Recommended for You');
  String get recentlyViewed => _t('شاهدتها مؤخراً', 'Recently Viewed');
  String get continueDonating => _t('أكمل التبرع', 'Continue Donating');
  String get causesYouSupport => _t('قضايا تدعمها', 'Causes You Support');
  String get noRecommendations => _t(
    'لا توجد توصيات بعد — تبرع لتظهر لك توصيات مخصصة.',
    'No recommendations yet — donate to see personalized picks.',
  );

  // ── Phase 3: Campaign search & filters ─────────────────
  String get filterUrgent => _t('عاجلة', 'Urgent');
  String get filterVerified => _t('موثقة', 'Verified');
  String get filterNearMe => _t('قريبة مني', 'Near Me');
  String get filterMostNeeded => _t('الأكثر احتياجاً', 'Most Needed');
  String get filterRecentlyAdded => _t('أضيفت مؤخراً', 'Recently Added');
  String get searchByTitle => _t('عنوان الحملة', 'Campaign title');
  String get searchByCharity => _t('اسم الجمعية', 'Charity name');
  String get searchByCity => _t('المدينة', 'City');
  String get searchByCategory => _t('الفئة', 'Category');
  String get searchIn => _t('البحث في', 'Search in');
  String get clearFilters => _t('مسح التصفية', 'Clear Filters');
  String get activeFilters => _t('تصفية نشطة', 'Active Filters');
  String get nearMe => _t('قريب مني', 'Near me');
  String get mostNeeded => _t('الأكثر احتياجاً', 'Most needed');
  String get recentlyAdded => _t('أضيفت مؤخراً', 'Recently added');

  // ── Phase 3: Profile links ─────────────────────────────
  String get myImpactShort => _t('أثري', 'My Impact');
  String get myImpactShortHint =>
      _t('إحصائيات تبرعاتك وأثرك', 'Your donation stats and impact');
  String get recurringShort => _t('التبرعات المتكررة', 'Recurring Donations');
  String get recurringShortHint =>
      _t('إدارة تبرعاتك التلقائية', 'Manage your automatic donations');
  String get favoritesShort => _t('المفضلة', 'Favorites');
  String get favoritesShortHint =>
      _t('حملاتك المحفوظة', 'Your saved campaigns');
  String get zakatShort => _t('حاسبة الزكاة', 'Zakat Calculator');
  String get zakatShortHint =>
      _t('احسب زكاتك بسهولة', 'Calculate your zakat easily');
  String get giftShort => _t('تبرع كهدية', 'Gift Donation');
  String get giftShortHint =>
      _t('أهدِ تبرعاً لشخص عزيز', 'Give a donation as a gift');
  String get quickShort => _t('تبرع سريع', 'Quick Donation');
  String get quickShortHint =>
      _t('تبرع بخطوات بسيطة', 'Donate in simple steps');

  // ── Phase 5: Platform ecosystem ───────────────────────
  String get platformStats => _t('إحصائيات المنصة', 'Platform Statistics');
  String get totalDonationsPlatform => _t('إجمالي التبرعات', 'Total Donations');
  String get monthlyDonationsPlatform =>
      _t('تبرعات هذا الشهر', 'Monthly Donations');
  String get donorsCount => _t('عدد المتبرعين', 'Donors');
  String get campaignsCountPlatform => _t('عدد الحملات', 'Campaigns');
  String get charitiesCount => _t('عدد الجمعيات', 'Charities');
  String get beneficiariesCountPlatform =>
      _t('عدد المستفيدين', 'Beneficiaries');
  String get successfulCampaigns => _t('حملات ناجحة', 'Successful Campaigns');
  String get transparency => _t('الشفافية', 'Transparency');
  String get transparencyHint => _t(
    'تابع تقدم الحملة بشفافية كاملة',
    'Track campaign progress with full transparency',
  );
  String get donorCount => _t('متبرع', 'Donors');
  String get campaignLifecycle => _t('دورة حياة الحملة', 'Campaign Lifecycle');
  String get statusDraft => _t('مسودة', 'Draft');
  String get statusSubmitted => _t('مقدمة', 'Submitted');
  String get statusUnderReview => _t('قيد المراجعة', 'Under Review');
  String get statusApproved => _t('معتمدة', 'Approved');
  String get statusPublished => _t('منشورة', 'Published');
  String get statusRejected => _t('مرفوضة', 'Rejected');
  String get statusSuspended => _t('موقوفة', 'Suspended');
  String get requiresApproval =>
      _t('تتطلب موافقة المنصة', 'Requires platform approval');
  String get requiresApprovalHint => _t(
    'لا يمكن نشر الحملات مباشرة — تمر بمراجعة المنصة أولاً.',
    'Campaigns cannot be published directly — they pass platform review first.',
  );
  String get beneficiariesTitle => _t('المستفيدون', 'Beneficiaries');
  String get caseCategory => _t('فئة الحالة', 'Case Category');
  String get caseMedical => _t('طبي', 'Medical');
  String get caseFood => _t('غذاء', 'Food');
  String get caseHousing => _t('سكن', 'Housing');
  String get caseEducation => _t('تعليم', 'Education');
  String get caseDebtRelief => _t('تسديد ديون', 'Debt Relief');
  String get caseOrphans => _t('أيتام', 'Orphans');
  String get caseEmergency => _t('طوارئ', 'Emergency');
  String get verificationStatus => _t('حالة التحقق', 'Verification Status');
  String get verificationPending => _t('قيد الانتظار', 'Pending');
  String get verificationUnderReview => _t('قيد المراجعة', 'Under Review');
  String get verificationVerified => _t('موثق', 'Verified');
  String get verificationRejected => _t('مرفوض', 'Rejected');
  String get sensitiveDataNotice => _t(
    'بيانات المستفيدين حساسة ولا تُعرض إلا للمصرح لهم.',
    'Beneficiary data is sensitive and only shown to authorized parties.',
  );
  String get reports => _t('التقارير', 'Reports');
  String get donationReports => _t('تقارير التبرعات', 'Donation Reports');
  String get campaignReports => _t('تقارير الحملات', 'Campaign Reports');
  String get charityReports => _t('تقارير الجمعيات', 'Charity Reports');
  String get monthlyReport => _t('تقرير شهري', 'Monthly Report');
  String get annualReport => _t('تقرير سنوي', 'Annual Report');
  String get securityTitle => _t('الأمان والحماية', 'Security');
  String get auditLogs => _t('سجل التدقيق', 'Audit Logs');
  String get activeSessions => _t('الجلسات النشطة', 'Active Sessions');
  String get currentDevice => _t('هذا الجهاز', 'This device');
  String get revokeSession => _t('إنهاء الجلسة', 'Revoke Session');
  String get fraudDetection => _t('كشف الاحتيال', 'Fraud Detection');
  String get duplicateDonation => _t('تبرع مكرر', 'Duplicate Donation');
  String get unusualAmount => _t('مبلغ غير معتاد', 'Unusual Amount');
  String get rapidTransactions => _t('عمليات متسارعة', 'Rapid Transactions');
  String get mismatchedIdentity => _t('هوية غير مطابقة', 'Mismatched Identity');
  String get chargebackRisk => _t('خطر استرداد', 'Chargeback Risk');
  String get rateLimited => _t('تم تقييد الطلب', 'Request rate limited');
  String get rateLimitedHint =>
      _t('حاول مرة أخرى بعد قليل.', 'Please try again shortly.');
  String get pushNotifications => _t('الإشعارات الفورية', 'Push Notifications');
  String get pushDonationConfirmation =>
      _t('تأكيد التبرع', 'Donation Confirmation');
  String get pushCampaignUpdate => _t('تحديث الحملة', 'Campaign Update');
  String get pushCampaignCompletion =>
      _t('اكتمال الحملة', 'Campaign Completion');
  String get pushRecurringDonation => _t('تبرع متكرر', 'Recurring Donation');
  String get pushSecurityAlert => _t('تنبيه أمني', 'Security Alert');
  String get pushSystemAnnouncement =>
      _t('إعلان النظام', 'System Announcement');
  String get observability => _t('المراقبة', 'Observability');
  String get crashReporting => _t('الإبلاغ عن الأعطال', 'Crash Reporting');
  String get analytics => _t('التحليلات', 'Analytics');
  String get apiLogging => _t('سجل API', 'API Logging');
  String get errorMonitoring => _t('مراقبة الأخطاء', 'Error Monitoring');
  String get environment => _t('البيئة', 'Environment');
  String get environmentDev => _t('تطوير', 'Development');
  String get environmentStaging => _t('تجريبي', 'Staging');
  String get environmentProd => _t('إنتاج', 'Production');
  String get charityDashboard => _t('لوحة الجمعية', 'Charity Dashboard');
  String get charityDashboardHint => _t(
    'إدارة الحملات والمستفيدين والتقارير',
    'Manage campaigns, beneficiaries and reports',
  );
  String get adminDashboard => _t('لوحة الإدارة', 'Admin Dashboard');
  String get adminDashboardHint => _t(
    'إدارة المستخدمين والموافقات والمراقبة',
    'Manage users, approvals and monitoring',
  );
  String get donationReceipts => _t('إيصالات التبرع', 'Donation Receipts');
  String get pdfExport => _t('تصدير PDF', 'Export PDF');
  String get excelExport => _t('تصدير Excel', 'Export Excel');
  String get generatedAt => _t('تاريخ الإنشاء', 'Generated At');
  String get reportTotal => _t('الإجمالي', 'Total');
}
