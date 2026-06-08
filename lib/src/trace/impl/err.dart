import 'package:dart_exceptor/src/trace/base/itrace.dart';

class Err<T, E> extends Trace<T, E> {
  Err(this._error);
  final E _error;

  @override
  V split<V>({required V Function(T value) data, required V Function(E e) e}) {
    return e(_error);
  }

  @override
  T map({required T Function(T value) data}) {
    throw UnimplementedError();
  }

  @override
  E mapError({required E Function(E error) e}) {
    return e(_error);
  }

  @override
  Trace<B, E> bind<B>({required Trace<B, E> Function(T value) n}) {
    return Err(_error);
  }
}
