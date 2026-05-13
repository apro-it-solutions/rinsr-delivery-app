import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/ratings_entity.dart';
import '../../domain/usecases/get_ratings.dart';

part 'ratings_event.dart';
part 'ratings_state.dart';

class RatingsBloc extends Bloc<RatingsEvent, RatingsState> {
  final GetRatings getRatings;

  RatingsBloc({required this.getRatings}) : super(RatingsInitial()) {
    on<FetchRatingsEvent>(_fetchRatings);
  }

  FutureOr<void> _fetchRatings(
    FetchRatingsEvent event,
    Emitter<RatingsState> emit,
  ) async {
    emit(RatingsLoadingState());
    final result = await getRatings.call(
      GetRatingsParams(partnerId: event.partnerId),
    );
    result.fold(
      (failure) => emit(RatingsErrorState(message: failure.message)),
      (success) => emit(RatingsLoadedState(ratings: success)),
    );
  }
}
