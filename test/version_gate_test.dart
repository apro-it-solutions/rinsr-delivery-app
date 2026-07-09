import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rinsr_delivery_partner/features/app_version/domain/entities/app_version_entity.dart';
import 'package:rinsr_delivery_partner/features/app_version/presentation/bloc/version_bloc.dart';
import 'package:rinsr_delivery_partner/features/app_version/presentation/pages/force_update_screen.dart';
import 'package:rinsr_delivery_partner/features/app_version/presentation/widgets/version_gate.dart';

class MockVersionBloc extends MockBloc<VersionEvent, VersionState>
    implements VersionBloc {}

void main() {
  late MockVersionBloc versionBloc;

  const childKey = Key('app-child');
  const child = MaterialApp(home: Scaffold(body: Text('App', key: childKey)));

  setUp(() => versionBloc = MockVersionBloc());

  Widget wrap() => MaterialApp(
    home: BlocProvider<VersionBloc>.value(
      value: versionBloc,
      child: const VersionGate(child: child),
    ),
  );

  testWidgets('VersionOk renders the child app', (tester) async {
    when(() => versionBloc.state).thenReturn(const VersionOk());
    await tester.pumpWidget(wrap());

    expect(find.byKey(childKey), findsOneWidget);
    expect(find.byType(ForceUpdateScreen), findsNothing);
  });

  testWidgets('VersionInitial renders the child app (fail-open default)', (
    tester,
  ) async {
    when(() => versionBloc.state).thenReturn(const VersionInitial());
    await tester.pumpWidget(wrap());

    expect(find.byKey(childKey), findsOneWidget);
    expect(find.byType(ForceUpdateScreen), findsNothing);
  });

  testWidgets('ForceUpdateRequired replaces the child with force screen', (
    tester,
  ) async {
    when(() => versionBloc.state).thenReturn(
      const ForceUpdateRequired(
        AppVersionEntity(minSupportedVersion: '9.9.9'),
      ),
    );
    await tester.pumpWidget(wrap());

    expect(find.byType(ForceUpdateScreen), findsOneWidget);
    expect(find.text('Update Required'), findsOneWidget);
    expect(find.text('Update Now'), findsOneWidget);
    expect(find.byKey(childKey), findsNothing);
  });
}
