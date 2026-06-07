import 'package:result_x/src/trace/base/itrace.dart';

class Ok<T, E> extends Trace<T, E> {
  Ok(this._data);
  final T _data;
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
    return data(_data);
  }
}
