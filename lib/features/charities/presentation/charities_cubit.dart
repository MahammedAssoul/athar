import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/charity.dart';

/// Charities list state.
class CharitiesState {
  const CharitiesState({
    this.loading = true,
    this.error = false,
    this.charities = const [],
  });

  final bool loading;
  final bool error;
  final List<Charity> charities;

  CharitiesState copyWith({
    bool? loading,
    bool? error,
    List<Charity>? charities,
  }) {
    return CharitiesState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      charities: charities ?? this.charities,
    );
  }
}

/// Loads charities from the repository.
class CharitiesCubit extends Cubit<CharitiesState> {
  CharitiesCubit() : super(const CharitiesState());

  Future<void> load() async {
    emit(const CharitiesState(loading: true));
    try {
      final charities = await AppDependencies.instance.charityRepository
          .getCharities();
      emit(CharitiesState(loading: false, charities: charities));
    } catch (_) {
      emit(const CharitiesState(loading: false, error: true));
    }
  }
}
