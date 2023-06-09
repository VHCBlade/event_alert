import 'package:event_alert/event_alert.dart';
import 'package:event_bloc/event_bloc.dart';

/// Adds methods for more easily throwing events.
extension AlertEventChannel on BlocEventChannel {
  /// Fires the [AlertEvent.noInternetAccess] event up the event channel
  void fireNoInternet() {
    fireEvent(AlertEvent.noInternetAccess.event, null);
  }

  /// Fires the [AlertEvent.alert] event up the event channel with [message]
  void fireAlert(String message) {
    fireEvent(AlertEvent.alert.event, message);
  }

  /// Fires the [AlertEvent.warning] event up the event channel with [message]
  void fireWarning(String message) {
    fireEvent(AlertEvent.warning.event, message);
  }

  /// Fires the [AlertEvent.info] event up the event channel with [message]
  void fireInfo(String message) {
    fireEvent(AlertEvent.info.event, message);
  }

  /// Fires the [AlertEvent.error] event up the event channel with [message]
  void fireError(String message) {
    fireEvent(AlertEvent.error.event, message);
  }
}
