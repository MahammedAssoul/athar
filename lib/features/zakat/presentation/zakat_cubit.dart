import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/zakat_asset.dart';
import '../../../data/services/zakat_calculator.dart';

/// Zakat calculator state.
class ZakatState {
  const ZakatState({this.assets = const [], this.result});

  final List<ZakatAsset> assets;
  final ZakatCalculation? result;

  ZakatState copyWith({List<ZakatAsset>? assets, ZakatCalculation? result}) {
    return ZakatState(
      assets: assets ?? this.assets,
      result: result ?? this.result,
    );
  }
}

/// Drives the Zakat calculator.
///
/// All calculation logic lives in [ZakatCalculator] — the widget layer
/// only collects inputs and displays the result.
class ZakatCubit extends Cubit<ZakatState> {
  ZakatCubit() : super(const ZakatState());

  void addAsset(ZakatAssetType type, double amount) {
    if (amount <= 0) return;
    final assets = [...state.assets, ZakatAsset(type: type, amount: amount)];
    _recalculate(assets);
  }

  void removeAsset(int index) {
    if (index < 0 || index >= state.assets.length) return;
    final assets = [...state.assets]..removeAt(index);
    _recalculate(assets);
  }

  void _recalculate(List<ZakatAsset> assets) {
    final result = AppDependencies.instance.zakatCalculator.calculate(assets);
    emit(ZakatState(assets: assets, result: result));
  }
}
