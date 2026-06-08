import 'package:dart_exceptor/src/trace/base/itrace.dart';

class Ok<T, E> extends Trace<T, E> {
  Ok(this._data);
  final T _data;

  @override
  V split<V>({required V Function(T value) data, required V Function(E e) e}) {
    return data(_data);s
  }

  @override
  T map({required T Function(T value) data}) {
    return data(_data);
  }

  @override
  E mapError({required E Function(E error) e}) {
    throw UnimplementedError();
  }

  @override
  Trace<B, E> bind<B>({required Trace<B, E> Function(T value) n}) {
    return n(_data);
  }
}
