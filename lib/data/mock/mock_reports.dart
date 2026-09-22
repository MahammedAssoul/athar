import '../models/report.dart';

/// Demo reports. Fictional data for Phase 5 only.
class MockReports {
  MockReports._();

  static final List<Report> all = [
    Report(
      id: 'r1',
      titleAr: 'تقرير التبرعات الشهري',
      titleEn: 'Monthly donations report',
      period: ReportPeriod.monthly,
      generatedAt: DateTime(2026, 9, 1),
      rows: [
        ReportRow(label: 'سبتمبر 2026', value: 96000),
        ReportRow(label: 'أغسطس 2026', value: 112000),
        ReportRow(label: 'يوليو 2026', value: 98000),
      ],
      total: 306000,
    ),
    Report(
      id: 'r2',
      titleAr: 'تقرير الحملات السنوي',
      titleEn: 'Annual campaigns report',
      period: ReportPeriod.annual,
      generatedAt: DateTime(2026, 1, 1),
      rows: [
        ReportRow(label: '2026', value: 320),
        ReportRow(label: '2025', value: 245),
        ReportRow(label: '2024', value: 180),
      ],
      total: 745,
    ),
    Report(
      id: 'r3',
      titleAr: 'تقرير الجمعيات',
      titleEn: 'Charities report',
      period: ReportPeriod.monthly,
      generatedAt: DateTime(2026, 9, 1),
      rows: [
        ReportRow(label: 'جمعية الأمل الخيرية', value: 12, secondary: 'حملة'),
        ReportRow(label: 'مؤسسة الرحمة للتنمية', value: 8, secondary: 'حملة'),
        ReportRow(label: 'جمعية كفالة اليتيم', value: 6, secondary: 'حملة'),
      ],
      total: 45,
    ),
  ];
}
