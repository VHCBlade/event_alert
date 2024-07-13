import 'dart:async';

import 'package:event_alert/src/loading.dart';
import 'package:event_bloc/event_bloc.dart';

/// Specific states for [WithLoadableList]s
enum LoadableListState {
  /// Data was loaded
  withData,

  /// No Data was found
  isEmpty,

  /// Error occurred
  isError,
}

/// Indicates that this [WithLoadingStatus] represents a list
mixin WithLoadableList on WithLoadingStatus {
  /// Whether the list loaded is empty or not.
  bool get isEmpty;

  /// Needs to be called in constructor to add the reload event listeners
  void initializeLoadableListListeners() {
    eventChannel.addEventListener(reloadEvent, (event, value) => reload());
  }

  /// The current state of the list
  LoadableListState get listState => loading.isError
      ? LoadableListState.isError
      : isEmpty
          ? LoadableListState.isEmpty
          : LoadableListState.withData;

  /// The function that will be called when a reload occurs
  FutureOr<void> reload();

  /// The event that will automatically trigger a reload when it occurs
  BlocEventType<void> get reloadEvent;
}

/// Indicates that this [WithLoadingStatus] represents some data
mixin WithLoadableData on WithLoadingStatus {
  /// Needs to be called in constructor to add the reload event listeners
  void initializeLoadableDataListeners() {
    eventChannel.addEventListener(reloadEvent, (event, value) => reload());
  }

  /// The function that will be called when a reload occurs
  FutureOr<void> reload();

  /// The event that will automatically trigger a reload when it occurs
  BlocEventType<void> get reloadEvent;
}
