import 'package:result_x/src/trace/base/itrace.dart';

class Err<T, E> extends Trace<T, E> {
  Err(this._error);
  final E _error;
  @override
  bind() {
    // TODO: implement bind
    throw UnimplementedError();
  }

  @override
  map() {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  V split<V>({required V Function(T value) data, required V Function(E e) e}) {
    return e(_error);
  }
}
