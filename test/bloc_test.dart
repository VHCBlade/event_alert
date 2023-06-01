import 'package:event_alert/event_alert.dart';
import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertBloc', alertBlocTest);
}

void alertBlocTest() {
  SerializableListTester<void>(
    testGroupName: 'AlertBloc',
    mainTestName: 'Stream',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) async {
      final bloc = AlertBloc(parentChannel: null);
      bloc.stream.listen(
        (event) => tester
          ..addTestValue('${event.event}')
          ..addTestValue(event.message),
      );

      bloc.eventChannel.fireNoInternet();
      bloc.eventChannel.fireError('Cool');
      bloc.eventChannel.fireNoInternet();
      bloc.eventChannel.fireWarning('Cool');
      bloc.eventChannel.fireError('Amazing');
      bloc.eventChannel.fireAlert('Cool');
      bloc.eventChannel.fireNoInternet();

      await Future<void>.delayed(const Duration(milliseconds: 50));
    },
    testMap: {'Events': () {}},
  ).runTests();
}
