import '../models/donation.dart';

/// A formatted donation receipt.
class DonationReceipt {
  const DonationReceipt({
    required this.reference,
    required this.donorName,
    required this.campaignTitle,
    required this.charityName,
    required this.amount,
    required this.date,
    required this.donationType,
    required this.paymentMethod,
  });

  final String reference;
  final String donorName;
  final String campaignTitle;
  final String charityName;
  final double amount;
  final DateTime date;
  final DonationType donationType;
  final String paymentMethod;
}

/// Builds professional donation receipts.
///
/// Phase 3: the receipt is rendered in-app. The architecture prepares
/// for PDF generation, download, share and print — in Phase 3 these can
/// use mock/local generation.
abstract class ReceiptService {
  /// Builds a receipt for a donation.
  Future<DonationReceipt> buildReceipt(Donation donation);

  /// Generates a PDF representation of the receipt.
  ///
  /// Phase 3: returns a mock byte payload. A real PDF generator can
  /// replace this implementation later.
  Future<List<int>> generatePdf(DonationReceipt receipt);

  /// Downloads the receipt (mock — simulates saving a file).
  Future<bool> download(DonationReceipt receipt);

  /// Shares the receipt (mock — simulates a share sheet).
  Future<bool> share(DonationReceipt receipt);

  /// Prints the receipt (mock — simulates a print job).
  Future<bool> print(DonationReceipt receipt);
}

/// Mock receipt service used when `isMock == true`.
class MockReceiptService implements ReceiptService {
  const MockReceiptService();

  @override
  Future<DonationReceipt> buildReceipt(Donation donation) async {
    return DonationReceipt(
      reference: 'ATH-${donation.id.toUpperCase()}',
      donorName: 'محمد أحمد',
      campaignTitle: donation.campaignTitleAr,
      charityName: donation.charityNameAr,
      amount: donation.amount,
      date: donation.date,
      donationType: donation.type,
      paymentMethod: donation.paymentMethod,
    );
  }

  @override
  Future<List<int>> generatePdf(DonationReceipt receipt) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Mock PDF payload — a real generator would produce actual bytes.
    return List<int>.generate(64, (i) => i);
  }

  @override
  Future<bool> download(DonationReceipt receipt) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> share(DonationReceipt receipt) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> print(DonationReceipt receipt) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
