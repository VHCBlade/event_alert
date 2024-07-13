import 'package:event_alert/event_alert_widgets.dart';
import 'package:flutter/material.dart';

/// The dialog shown by [AlertWatcher]
class AlertInfoDialog extends StatelessWidget {
  /// [info] represents the event that triggered this dialog to be shown.
  const AlertInfoDialog({required this.info, super.key});

  /// The event that triggered this dialog to be shown.
  final AlertInfo info;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(info.event.label),
      content: Text(info.message),
      scrollable: true,
      actions: [
        ElevatedButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
