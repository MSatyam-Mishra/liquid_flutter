import 'dart:async';

import 'diagnostics.dart';
import 'drop.dart';

sealed class AsyncDropState<T> {
  const AsyncDropState();
}

final class AsyncIdle<T> extends AsyncDropState<T> {
  const AsyncIdle();
}

final class AsyncLoading<T> extends AsyncDropState<T> {
  const AsyncLoading();
}

final class AsyncData<T> extends AsyncDropState<T> {
  const AsyncData(this.value);

  final T value;
}

final class AsyncError<T> extends AsyncDropState<T> {
  const AsyncError(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}

class Flow<T> extends Drop<AsyncDropState<T>> {
  Flow({String? label}) : super(AsyncIdle<T>(), label: label);

  int _version = 0;
  StreamSubscription<T>? _subscription;

  Future<void> run(Future<T> Function() task) async {
    final int token = ++_version;
    value = AsyncLoading<T>();
    LiquidDiagnostics.emit(
      LiquidEvent(type: LiquidEventType.streamStarted, label: label),
    );

    try {
      final T result = await task();
      if (token != _version || isDisposed) {
        return;
      }
      value = AsyncData<T>(result);
      LiquidDiagnostics.emit(
        LiquidEvent(type: LiquidEventType.streamData, label: label),
      );
    } catch (error, stackTrace) {
      if (token != _version || isDisposed) {
        return;
      }
      value = AsyncError<T>(error, stackTrace);
      LiquidDiagnostics.emit(
        LiquidEvent(
          type: LiquidEventType.streamError,
          label: label,
          data: <String, Object?>{'error': error.toString()},
        ),
      );
    }
  }

  void bindStream(Stream<T> stream) {
    _version++;
    _subscription?.cancel();
    value = AsyncLoading<T>();
    _subscription = stream.listen(
      (T data) {
        if (isDisposed) {
          return;
        }
        value = AsyncData<T>(data);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (isDisposed) {
          return;
        }
        value = AsyncError<T>(error, stackTrace);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

@Deprecated('Use Flow<T> for async stream state.')
typedef StreamDrop<T> = Flow<T>;
