import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/services/impact_service.dart';

/// Impact dashboard state.
class ImpactState {
  const ImpactState({this.loading = true, this.error = false, this.metrics});

  final bool loading;
  final bool error;
  final ImpactMetrics? metrics;

  ImpactState copyWith({bool? loading, bool? error, ImpactMetrics? metrics}) {
    return ImpactState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      metrics: metrics ?? this.metrics,
    );
  }
}

/// Loads impact metrics from donation data.
class ImpactCubit extends Cubit<ImpactState> {
  ImpactCubit() : super(const ImpactState());

  Future<void> load() async {
    emit(const ImpactState(loading: true));
    try {
      final deps = AppDependencies.instance;
      final donations = await deps.donationRepository.getDonations();
      final metrics = await deps.impactService.compute(donations);
      emit(ImpactState(loading: false, metrics: metrics));
    } catch (_) {
      emit(const ImpactState(loading: false, error: true));
    }
  }
}
