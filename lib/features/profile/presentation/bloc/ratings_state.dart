part of 'ratings_bloc.dart';

sealed class RatingsState extends Equatable {
  const RatingsState();

  @override
  List<Object> get props => [];
}

final class RatingsInitial extends RatingsState {}

final class RatingsLoadingState extends RatingsState {}

final class RatingsLoadedState extends RatingsState {
  final RatingsEntity ratings;

  const RatingsLoadedState({required this.ratings});

  @override
  List<Object> get props => [ratings];
}

final class RatingsErrorState extends RatingsState {
  final String message;

  const RatingsErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
