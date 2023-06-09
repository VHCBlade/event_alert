import 'dart:async';

import 'package:event_alert/event_alert.dart';
import 'package:event_bloc/event_bloc.dart';

/// Data class for the alert stream.
class AlertInfo {
  /// Data class for the alert stream.
  AlertInfo(this.event, this.message);

  /// The event that caused the alert to happen.
  final AlertEvent<dynamic> event;

  /// The message to show to the user.
  final String message;
}

/// Needs to be added up the Widget tree and have the [stream] be listened to.
///
/// YOu can look at AlertWatcher for an automatic implementation of this.
class AlertBloc extends Bloc {
  /// Add this up the widget tree and listen to the [stream] to receive the
  /// alerts.
  ///
  /// Specifically doesn't listen [AlertEvent.warning]
  AlertBloc({required super.parentChannel}) {
    eventChannel
      ..addEventListener(
        AlertEvent.noInternetAccess.event,
        (event, value) => _stream.sink.add(
          AlertInfo(
              AlertEvent.noInternetAccess,
              'We were unable to access the internet. Try again later when you '
              'have a more stable internet connection.'),
        ),
      )
      ..addEventListener(
        AlertEvent.error.event,
        (event, value) => _stream.sink.add(AlertInfo(AlertEvent.error, value)),
      )
      ..addEventListener(
        AlertEvent.info.event,
        (event, value) => _stream.sink.add(AlertInfo(AlertEvent.info, value)),
      )
      ..addEventListener(
        AlertEvent.alert.event,
        (event, value) => _stream.sink.add(AlertInfo(AlertEvent.alert, value)),
      );
  }

  final _stream = StreamController<AlertInfo>.broadcast();

  /// The stream for the alerts that occur.
  Stream<AlertInfo> get stream => _stream.stream;
}
