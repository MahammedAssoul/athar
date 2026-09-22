/// Report period granularity.
enum ReportPeriod { daily, monthly, annual }

/// A single row of a report.
class ReportRow {
  const ReportRow({required this.label, required this.value, this.secondary});

  final String label;
  final double value;
  final String? secondary;

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
    'secondary': secondary,
  };

  factory ReportRow.fromJson(Map<String, dynamic> json) {
    return ReportRow(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      secondary: json['secondary'] as String?,
    );
  }
}

/// A report with rows and optional totals.
///
/// The backend can render the same data as PDF or Excel — the app
/// consumes the structured rows and formats them locally.
class Report {
  const Report({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.period,
    required this.generatedAt,
    this.rows = const [],
    this.total,
    this.format = 'json',
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final ReportPeriod period;
  final DateTime generatedAt;
  final List<ReportRow> rows;
  final double? total;

  /// Response format: `json`, `pdf`, `xlsx`, `csv`.
  final String format;

  Map<String, dynamic> toJson() => {
    'id': id,
    'titleAr': titleAr,
    'titleEn': titleEn,
    'period': period.name,
    'generatedAt': generatedAt.toIso8601String(),
    'rows': rows.map((r) => r.toJson()).toList(),
    'total': total,
    'format': format,
  };

  factory Report.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'] as List<dynamic>? ?? const [];
    return Report(
      id: json['id'] as String,
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      period: _periodFrom(json['period']),
      generatedAt: _dateFrom(json['generatedAt']),
      rows: rawRows
          .map((e) => ReportRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
      format: json['format'] as String? ?? 'json',
    );
  }

  static ReportPeriod _periodFrom(dynamic value) {
    if (value is String) {
      for (final period in ReportPeriod.values) {
        if (period.name == value) return period;
      }
    }
    return ReportPeriod.monthly;
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

/// A donation receipt (structured, printable).
class DonationReceipt {
  const DonationReceipt({
    required this.receiptNumber,
    required this.donationId,
    required this.donorName,
    required this.amount,
    required this.date,
    required this.campaignTitleAr,
    required this.campaignTitleEn,
    required this.charityNameAr,
    required this.charityNameEn,
    this.transactionReference,
    this.paymentMethod,
  });

  final String receiptNumber;
  final String donationId;
  final String donorName;
  final double amount;
  final DateTime date;
  final String campaignTitleAr;
  final String campaignTitleEn;
  final String charityNameAr;
  final String charityNameEn;
  final String? transactionReference;
  final String? paymentMethod;

  Map<String, dynamic> toJson() => {
    'receiptNumber': receiptNumber,
    'donationId': donationId,
    'donorName': donorName,
    'amount': amount,
    'date': date.toIso8601String(),
    'campaignTitleAr': campaignTitleAr,
    'campaignTitleEn': campaignTitleEn,
    'charityNameAr': charityNameAr,
    'charityNameEn': charityNameEn,
    'transactionReference': transactionReference,
    'paymentMethod': paymentMethod,
  };

  factory DonationReceipt.fromJson(Map<String, dynamic> json) {
    return DonationReceipt(
      receiptNumber: json['receiptNumber'] as String? ?? '',
      donationId: json['donationId'] as String? ?? '',
      donorName: json['donorName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: _dateFrom(json['date']),
      campaignTitleAr: json['campaignTitleAr'] as String? ?? '',
      campaignTitleEn: json['campaignTitleEn'] as String? ?? '',
      charityNameAr: json['charityNameAr'] as String? ?? '',
      charityNameEn: json['charityNameEn'] as String? ?? '',
      transactionReference: json['transactionReference'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
