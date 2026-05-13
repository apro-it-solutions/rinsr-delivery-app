part of 'ratings_bloc.dart';

sealed class RatingsEvent extends Equatable {
  const RatingsEvent();

  @override
  List<Object> get props => [];
}

final class FetchRatingsEvent extends RatingsEvent {
  final String partnerId;

  const FetchRatingsEvent({required this.partnerId});

  @override
  List<Object> get props => [partnerId];
}
