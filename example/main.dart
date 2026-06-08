import 'package:dart_exceptor/dart_exceptor.dart';

// Define your error type
class AppException {
  final int code;
  final String message;
  const AppException({required this.code, required this.message});
}

//  typedef so you don't repeat the error type everywhere
typedef Result<T> = Trace<T, AppException>;

Result<int> divide(int a, int b) {
  if (b == 0) {
    return Err(AppException(code: 400, message: 'Cannot divide by zero'));
  }
  return Ok(a ~/ b);
}

Result<String> toLabel(int value) {
  if (value < 0) {
    return Err(AppException(code: 422, message: 'Negative values not allowed'));
  }
  return Ok('Result is $value');
}

void main() {
  // 1. split()  branch on Ok vs Err (the primary way to consume a Result)
  final divided = divide(10, 2);
  divided.split(
    data: (value) => print('split   -> ok: $value'),
    e: (err) => print('split   -> err: ${err.message}'),
  );

  // 2. split() on an Err
  final bad = divide(10, 0);
  bad.split(
    data: (value) => print('should not reach here'),
    e: (err) => print('split   -> err: ${err.message}'),
  );

  // 3. bind()  chain operations that also return a Result (flatMap)
  divide(20, 4)
      .bind<String>(n: (value) => toLabel(value))
      .split(
        data: (label) => print('bind    -> $label'),
        e: (err) => print('bind    -> err: ${err.message}'),
      );

  // 4. bind() propagates Err without calling the next step
  divide(10, 0)
      .bind<String>(n: (value) => toLabel(value))
      .split(
        data: (label) => print('should not reach here'),
        e: (err) => print(
          'bind    -> err propagated: ${err.message}',
        ),
      );

  // 5. map()  transform the Ok value (throws if called on Err)
  final mapped = divide(9, 3).map(data: (v) => v * 100);
  print('map     -> $mapped');

  // 6. mapError() transform the Err value (throws if called on Ok)
  final mappedErr = divide(5, 0).mapError(
    e: (err) =>
        AppException(code: err.code, message: err.message.toUpperCase()),
  );
  print('mapErr  -> ${mappedErr.message}');
}
