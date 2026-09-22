import '../models/zakat_asset.dart';

/// Result of a Zakat calculation.
class ZakatCalculation {
  const ZakatCalculation({
    required this.totalAssets,
    required this.zakatDue,
    required this.rate,
  });

  /// Sum of all entered assets.
  final double totalAssets;

  /// Zakat due (2.5% of total assets).
  final double zakatDue;

  /// Zakat rate (0.025).
  final double rate;
}

/// Zakat calculation logic.
///
/// Isolated from the UI so the calculation can be reviewed, tested and
/// replaced independently. The calculator is informational only — users
/// should consult applicable religious guidance for their situation.
class ZakatCalculator {
  const ZakatCalculator();

  /// Zakat rate: 2.5% (1/40) of eligible assets.
  static const double zakatRate = 0.025;

  /// Calculates zakat due on the given assets.
  ///
  /// All asset types are treated as eligible. The result is purely
  /// informational and should be reviewed according to applicable
  /// religious guidance.
  ZakatCalculation calculate(List<ZakatAsset> assets) {
    final total = assets.fold<double>(
      0,
      (sum, asset) => sum + (asset.amount < 0 ? 0 : asset.amount),
    );
    return ZakatCalculation(
      totalAssets: total,
      zakatDue: total * zakatRate,
      rate: zakatRate,
    );
  }
}
