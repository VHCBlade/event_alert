import 'package:event_bloc/event_bloc.dart';

/// The events related to alerts.
enum AlertEvent<T> {
  /// For things the user needs to know about, but aren't necessarily
  /// errors, such as a notification that a download has finished.
  alert<String>('Alert'),

  /// For errors that the user needs to know about immediately.
  error<String>('Error'),

  /// For warnings that you want the user to know about, but don't
  /// necessarily need to take action on.
  warning<String>('Warning'),

  /// Specific alert for being unable to access the internet
  noInternetAccess<void>('No Internet'),
  ;

  const AlertEvent(this.label);

  /// The label for the event.
  final String label;

  /// Gives the [BlocEventType] for this event.
  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
