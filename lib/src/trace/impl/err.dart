import 'package:result_x/src/trace/base/itrace.dart';

class Err<T, E> extends Trace<T, E> {
  @override
  bind() {
    throw UnimplementedError();
  }

  @override
  map() {
    throw UnimplementedError();
  }

  @override
  split() {
    throw UnimplementedError();
  }
}
