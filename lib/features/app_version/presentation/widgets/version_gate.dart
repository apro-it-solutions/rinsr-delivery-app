import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/version_bloc.dart';
import '../pages/force_update_screen.dart';

/// Wraps the app's route child. When the [VersionBloc] reports
/// [ForceUpdateRequired], the [ForceUpdateScreen] replaces the child entirely;
/// otherwise the child renders normally. Placed in `MaterialApp.builder` as a
/// sibling to any connectivity/overlay gate.
class VersionGate extends StatelessWidget {
  final Widget child;

  const VersionGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VersionBloc, VersionState>(
      builder: (context, state) {
        if (state is ForceUpdateRequired) {
          return ForceUpdateScreen(versionInfo: state.versionInfo);
        }
        return child;
      },
    );
  }
}
