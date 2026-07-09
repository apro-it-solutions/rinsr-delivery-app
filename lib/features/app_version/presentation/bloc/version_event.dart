part of 'version_bloc.dart';

sealed class VersionEvent extends Equatable {
  const VersionEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on app launch and again on every resume from background.
final class CheckVersionRequested extends VersionEvent {
  const CheckVersionRequested();
}
