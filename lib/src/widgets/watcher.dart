import 'dart:async';

import 'package:event_alert/event_alert_widgets.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';

/// Automatically handles alerts from the stream of [AlertBloc]
class AlertWatcher extends StatefulWidget {
  /// Automatically handles alerts from the stream of [AlertBloc]
  const AlertWatcher({
    required this.child,
    required this.alertDialogBuilder,
    super.key,
  });

  /// The child
  final Widget child;

  /// If specified, this will be used to create the alert dialog
  /// rather than the default.
  final Widget Function(BuildContext context, AlertInfo info)?
      alertDialogBuilder;

  @override
  State<AlertWatcher> createState() => _AlertWatcherState();
}

class _AlertWatcherState extends State<AlertWatcher> {
  late final StreamSubscription<void> subscription;

  @override
  void initState() {
    super.initState();
    subscription = context.readBloc<AlertBloc>().stream.listen(
          (event) => showDialog<void>(
            context: context,
            builder: (context) => widget.alertDialogBuilder != null
                ? widget.alertDialogBuilder!(context, event)
                : AlertInfoDialog(info: event),
          ),
        );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
