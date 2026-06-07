abstract class Trace<T, E> {
  const Trace();

  V split<V>({required V Function(T value) data, required V Function(E e) e});

  map();

  bind();
}
