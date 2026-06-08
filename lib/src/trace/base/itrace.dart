abstract class Trace<T, E> {
  const Trace();

  V split<V>({required V Function(T value) data, required V Function(E e) e});

  T map({required T Function(T value) data});

  E mapError({required E Function(E error) e});

 Trace<T,E>  bind({required Trace<T,E> Function(T value) n});
}
