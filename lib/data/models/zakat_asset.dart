/// Asset categories supported by the Zakat calculator.
enum ZakatAssetType { cash, gold, silver, investments, other }

extension ZakatAssetTypeX on ZakatAssetType {
  String get key => name;
}

/// A single asset entry in the Zakat calculator.
class ZakatAsset {
  const ZakatAsset({required this.type, required this.amount});

  final ZakatAssetType type;
  final double amount;
}
