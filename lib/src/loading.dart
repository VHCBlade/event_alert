import 'dart:async';

import 'package:event_alert/event_alert.dart';
import 'package:event_bloc/event_bloc_widgets.dart';

/// Enum that determines different states of loading
enum LoadingStatus {
  /// Currently Loading
  loading,

  /// Has successfully loaded
  loaded,

  /// Initial State
  initial,

  /// Loading has failed
  failed,
  ;
}

/// Adds convenience functions for easily determining the current status
extension LoadingStatusExtension on LoadingStatus {
  /// Is [LoadingStatus.loaded]
  bool get isLoaded => this == LoadingStatus.loaded;

  /// Is [LoadingStatus.loading]
  bool get isLoading => this == LoadingStatus.loading;

  /// Is [LoadingStatus.failed]
  bool get isError => this == LoadingStatus.failed;
}

/// Way to easily add a [LoadingStatus] to your [Bloc] as well as some
/// convenience functions for loading and saving.
mixin WithLoadingStatus on Bloc {
  /// The current [LoadingStatus]
  LoadingStatus loading = LoadingStatus.initial;

  /// An implementation of [blocCustomLoad] that uses [standardLoadHandling] to
  /// handle specific errors.
  Future<T?> standardLoad<T>(
    FutureOr<T> Function() load, {
    bool ignoreWhenLoading = true,
    Future<void> Function()? onUnexpectedError,
  }) {
    return _blocLoad(
      load,
      ignoreWhenLoading: ignoreWhenLoading,
      onError: standardLoadHandling,
      onUnexpectedError: onUnexpectedError,
    );
  }

  /// An implementation of [blocCustomLoad] that uses [standardSaveHandling] to
  /// handle specific errors.
  Future<T?> standardSave<T>(
    FutureOr<T> Function() load, {
    bool ignoreWhenLoading = true,
    Future<void> Function()? onUnexpectedError,
  }) {
    return _blocLoad(
      load,
      ignoreWhenLoading: ignoreWhenLoading,
      onError: standardSaveHandling,
      onUnexpectedError: onUnexpectedError,
    );
  }

  /// Exceptions that occur during [load] will be caught by [onError] if they
  /// have the type [S]. If [onError] is null or if the exception is not of type
  /// [S], [onUnexpectedError] will be called instead.
  Future<T?> blocCustomLoad<T, S extends Object>(
    FutureOr<T> Function() load, {
    bool ignoreWhenLoading = true,
    Future<void> Function(S)? onError,
    Future<void> Function()? onUnexpectedError,
  }) {
    return _blocLoad(
      load,
      ignoreWhenLoading: ignoreWhenLoading,
      onError: onError,
      onUnexpectedError: onUnexpectedError,
    );
  }

  late int _currentRequestNumber = 0;

  Future<void> _handleUnexpectedError(
    Future<void> Function()? onUnexpectedError, {
    required StackTrace trace,
    required Object exception,
  }) async {
    loading = LoadingStatus.failed;
    updateBloc();
    if (onUnexpectedError != null) {
      await onUnexpectedError();
    } else {
      eventChannel.fireError('An unexpected error has occurred');
    }
    eventChannel.fireEvent(
      ErrorEvent.unexpectedError.event,
      TrackedError(
        error: exception,
        stackTrace: trace,
        message: 'Encountered an unexpected error while loading!',
      ),
    );
  }

  /// Exceptions that occur during [load] will be caught by [onError] if they
  /// have the type [S]. If [onError] is null or if the exception is not of
  /// type [S], [onUnexpectedError] will be called instead.
  Future<T?> _blocLoad<T, S extends Object>(
    FutureOr<T> Function() load, {
    bool ignoreWhenLoading = true,
    Future<void> Function(S)? onError,
    Future<void> Function()? onUnexpectedError,
  }) async {
    if (ignoreWhenLoading && loading.isLoading) {
      return null;
    }

    loading = LoadingStatus.loading;

    try {
      updateBloc();
      final returnValue = await load();
      loading = LoadingStatus.loaded;
      updateBloc();
      return returnValue;
    } on S catch (exception, trace) {
      if (onError != null) {
        loading = LoadingStatus.failed;
        updateBloc();
        await onError(exception);
        eventChannel.fireEvent(
          ErrorEvent.debugError.event,
          TrackedError(
            error: exception,
            stackTrace: trace,
            message: 'Encountered an expected error while loading!',
          ),
        );
      } else {
        await _handleUnexpectedError(
          onUnexpectedError,
          trace: trace,
          exception: exception,
        );
      }
      return null;
    } on Object catch (exception, trace) {
      await _handleUnexpectedError(
        onUnexpectedError,
        trace: trace,
        exception: exception,
      );
      return null;
    }
  }

  /// Unlike [blocCustomLoad], calling this will cause previous calls to this
  /// function to exit without performing their [action].
  ///
  /// Also note that [load] and [action] are considered separate actions unlike
  /// in [blocCustomLoad], where the 2 are the same.
  ///
  /// Exceptions that occur during [load] will be caught by [onError] if they
  /// have the type [S]. If [onError] is null or if the exception is not of type
  /// [S], [onUnexpectedError] will be called instead.
  ///
  /// If this function is overwritten and an error occurs, neither [onError]
  /// or [onUnexpectedError] will be called.
  Future<T?> blocCustomForceLoad<T, S extends Object>(
    FutureOr<T> Function() load,
    FutureOr<void> Function(T) action, {
    Future<void> Function(S)? onError,
    Future<void> Function()? onUnexpectedError,
  }) {
    return _blocForceLoad(
      load,
      action,
      onError: onError,
      onUnexpectedError: onUnexpectedError,
    );
  }

  /// An implementation of [blocCustomForceLoad] that uses
  /// [standardLoadHandling] to handle specific errors.
  Future<T?> standardForceLoad<T>(
    FutureOr<T> Function() load,
    FutureOr<void> Function(T) action, {
    Future<void> Function()? onUnexpectedError,
  }) {
    return _blocForceLoad<T, LoadException>(
      load,
      action,
      onError: standardLoadHandling,
      onUnexpectedError: onUnexpectedError,
    );
  }

  /// An implementation of [blocCustomForceLoad] that uses
  /// [standardSaveHandling] to handle specific errors.
  Future<T?> standardForceSave<T>(
    FutureOr<T> Function() load,
    FutureOr<void> Function(T) action, {
    Future<void> Function()? onUnexpectedError,
  }) {
    return _blocForceLoad<T, SaveException>(
      load,
      action,
      onError: standardSaveHandling,
      onUnexpectedError: onUnexpectedError,
    );
  }

  /// Unlike [_blocLoad], calling this will cause previous calls to this
  /// function to exit without performing their [action].
  ///
  /// Also note that [load] and [action] are considered separate actions unlike
  /// in [_blocLoad], where the 2 are the same.
  ///
  /// Exceptions that occur during [load] will be caught by [onError] if they
  /// have the type [S]. If [onError] is null or if the exception is not of type
  /// [S], [onUnexpectedError] will be called instead.
  ///
  /// If this function is overwritten and an error occurs, neither [onError]
  /// or [onUnexpectedError] will be called.
  Future<T?> _blocForceLoad<T, S extends Object>(
    FutureOr<T> Function() load,
    FutureOr<void> Function(T) action, {
    Future<void> Function(S)? onError,
    Future<void> Function()? onUnexpectedError,
  }) async {
    final myRequestNumber = ++_currentRequestNumber;
    loading = LoadingStatus.loading;
    try {
      updateBloc();
      final returnValue = await load();
      if (myRequestNumber != _currentRequestNumber) {
        return null;
      }
      await action(returnValue);
      loading = LoadingStatus.loaded;
      updateBloc();
      return returnValue;
    } on S catch (exception, trace) {
      if (myRequestNumber != _currentRequestNumber) {
        return null;
      }
      if (onError != null) {
        loading = LoadingStatus.failed;
        updateBloc();
        await onError(exception);
      } else {
        await _handleUnexpectedError(
          onUnexpectedError,
          trace: trace,
          exception: exception,
        );
      }
      return null;
    } on Object catch (exception, trace) {
      if (myRequestNumber != _currentRequestNumber) {
        return null;
      }
      await _handleUnexpectedError(
        onUnexpectedError,
        trace: trace,
        exception: exception,
      );
      return null;
    }
  }

  /// Expects standard [SaveException]s to be thrown and handles them.
  Future<void> standardSaveHandling(SaveException exception) async {
    loading = LoadingStatus.loaded;
    updateBloc();
    eventChannel.fireError(exception.message);
  }

  /// Expects standard [LoadException]s to be thrown and handles them.
  Future<void> standardLoadHandling(LoadException exception) async {
    eventChannel.fireError(exception.message);
  }

  /// Expects standard [LoadException]s to be thrown and handles them without
  /// firing an error event.
  Future<void> quietLoadHandling(LoadException exception) async {}
}

/// Standard Save Exception thrown on loading
class SaveException implements Exception {
  /// [message] is the expected value to be shown to the user.
  const SaveException(this.message);

  /// The message
  final String message;
}

/// Standard Load Exception thrown on loading
class LoadException implements Exception {
  /// The message
  const LoadException(this.message);

  /// [message] is the expected value to be shown to the user.
  final String message;
}
