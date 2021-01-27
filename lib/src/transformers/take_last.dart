import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _TakeLastStreamSink<T> implements ForwardingSink<T, T> {
  _TakeLastStreamSink(this.count);

  final int count;
  List<T> buffer = [];

  @override
  void add(EventSink<T> sink, T data) {
    if (count > 0) {
      buffer.add(data);

      if (buffer.length > count) {
        buffer.removeAt(0);
      }
    }
  }

  @override
  void addError(EventSink<T> sink, dynamic e, [st]) => sink.addError(e, st);

  @override
  void close(EventSink<T> sink) {
    buffer.forEach(sink.add);
    buffer = [];
    sink.close();
  }

  @override
  FutureOr onCancel(EventSink<T> sink) {}

  @override
  void onListen(EventSink<T> sink) {}

  @override
  void onPause(EventSink<T> sink) {}

  @override
  void onResume(EventSink<T> sink) {}
}

/// Emits only the final [count] values emitted by the source [Stream].
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3, 4, 5])
///       .transform(TakeLastStreamTransformer(3))
///       .listen(print); // prints 3, 4, 5
class TakeLastStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// Constructs a [StreamTransformer] which emits only the final [count]
  /// events from the source [Stream].
  TakeLastStreamTransformer(this.count) {
    if (count == null) throw ArgumentError.notNull('count');
    if (count < 0) throw ArgumentError.value(count, 'count');
  }

  /// The [count] of final items emitted when the stream completes.
  final int count;

  @override
  Stream<T> bind(Stream<T> stream) =>
      forwardStream(stream, _TakeLastStreamSink<T>(count));
}

/// Extends the [Stream] class with the ability receive only the final [count]
/// events from the source [Stream].
extension TakeLastExtension<T> on Stream<T> {
  /// Emits only the final [count] values emitted by the source [Stream].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3, 4, 5])
  ///       .transform(TakeLastStreamTransformer(3))
  ///       .listen(print); // prints 3, 4, 5
  Stream<T> takeLast(int count) =>
      transform(TakeLastStreamTransformer<T>(count));
}
