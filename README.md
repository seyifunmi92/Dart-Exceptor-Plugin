# DartExceptor

A lightweight, expressive, and idiomatic Dart result type built on modern Dart 3.
No dependencies. No Haskell baggage. Just clean error handling that reads like real code.

---

## Why DartExceptor?

The traditional approach to error handling in Dart looks like this:

```dart
try {
  final user = await repo.getUser();
  print(user.name);
} catch (e) {
  print('Something went wrong: $e');
}
```

This works — until it doesn't. As your app grows, try/catch blocks scatter across your
codebase, errors get swallowed silently, and there's no way to tell from a function
signature whether it can fail.

**DartExceptor** solves this by making failure a first-class citizen in your API:

```dart
final result = await repo.getUser();

result.split(
  data: (user) => print(user.name),
  e: (e) => print(e.message),
);
```

The function signature now tells the full story. The caller is forced to handle both
outcomes. No surprises, no silent failures.

---

## Motivation

[dartz](https://pub.dev/packages/dartz) is powerful, but it carries significant
Haskell-inspired complexity that most Flutter developers don't need. DartExceptor is built
specifically for Dart and Flutter developers who want:

- A result type that reads like Dart, not Haskell
- Zero runtime dependencies
- Full compatibility with clean architecture patterns
- A minimal, intentional API surface — nothing more, nothing less

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  dart_exceptor: ^0.0.1
```

Then run:

```bash
dart pub get
```

Import in your Dart file:

```dart
import 'package:dart_exceptor/dart_exceptor.dart';
```

---

## Core Concepts

### `Trace<T, E>`

`Trace<T, E>` is the base type. Every operation in DartExceptor returns a `Trace`.

- `T` — the success type
- `E` — the error type

`Trace` has exactly two implementations:

- `Ok<T, E>` — represents a successful result, holds a value of type `T`
- `Err<T, E>` — represents a failed result, holds an error of type `E`

You never instantiate `Trace` directly. You return `Ok` or `Err` from your functions
and program against `Trace` everywhere else.

---

## API Reference

### `Ok(value)` — Wrap a success

```dart
return Ok(user);
```

### `Err(error)` — Wrap a failure

```dart
return Err(AppException(code: 500, e: 'Server error'));
```

---

### `split` — Handle both outcomes (terminal)

`split` is your **exit point** from the `Trace` world. It consumes the result and
handles both sides. Both handlers are **required** — you cannot ignore either side.

```dart
result.split(
  data: (user) => print(user.name),  // runs if Ok
  e: (e) => print(e.message),        // runs if Err
);
```

`split` accepts a generic type `V` — both handlers must return the same type:

```dart
final name = result.split<String>(
  data: (user) => user.firstName,
  e: (e) => 'Unknown',
);
```

---

### `map` — Extract and transform the success value

`map` unwraps the success value from an `Ok` and applies a transformation.
If called on an `Err`, it throws — wrap in a try/catch when the result type
is uncertain.

```dart
try {
  final users = result.map(data: (users) => users);
  final activeUsers = users.where((u) => u.isActive).toList();
} catch (e) {
  // handle error
}
```

`map` returns `T` directly — not a wrapped `Trace`. Use it when you are confident
the result is `Ok` and you want to work with the raw value.

---

### `mapError` — Extract and transform the error value

`mapError` is the mirror of `map` — it unwraps the error from an `Err` and applies
a transformation. If called on an `Ok`, it throws.

```dart
try {
  final users = result.map(data: (u) => u);
  print(users.length);
} catch (e) {
  final error = result.mapError(e: (e) => e);
  print('Error ${error.code}: ${error.message}');
}
```

This is useful for crossing architectural boundaries — your data layer may produce
a `DatabaseException` while your domain layer expects an `AppException`.

---

### `bind` — Chain operations that return `Trace`

`bind` is the most powerful method in DartExceptor. It lets you chain operations that
themselves return a `Trace`, transforming the success type along the way.

`bind` accepts a generic type `B` — the output type of the next operation:

```dart
Trace<B, E> bind<B>({required Trace<B, E> Function(T value) n});
```

**In `Ok`** — the function runs, the result is returned:
```dart
// Ok runs n(_data) and returns its Trace result
```

**In `Err`** — the function is skipped, the error propagates forward automatically:
```dart
// Err skips n entirely and returns Err(_error) as Trace<B, E>
```

This means if **any step** in a chain returns `Err`, all subsequent `bind` calls
are skipped and the error flows through untouched.

#### Basic usage

```dart
final result = await logic.getAllUsers(); // Trace<List<User>, IException>

final user = result.bind<User>(
  n: (users) {
    try {
      return Ok(users.firstWhere((e) => e.id == id));
    } catch (e) {
      return Err(IException(code: 404, e: 'User not found'));
    }
  },
);
```

#### Chaining multiple binds

`bind` returns `Trace<B, E>`, so you can chain as many as you need —
each one transforming the type further:

```dart
final result = await logic.getAllUsers(); // Trace<List<User>, IException>

result
    .bind<User>(
      n: (users) {
        try {
          return Ok(users.firstWhere((e) => e.id == id));
        } catch (e) {
          return Err(IException(code: 404, e: 'User not found'));
        }
      },
    )                                     // Trace<User, IException>
    .bind<String>(
      n: (user) => Ok(user.firstName),
    )                                     // Trace<String, IException>
    .split(
      data: (name) => print(name),
      e: (e) => print(e.e),
    );
```

If `getAllUsers()` returns `Err`, both `bind` calls and `split` data handler
are skipped — only the `e` handler in `split` runs.

---

## Method Summary

| Method | Purpose | Returns |
|---|---|---|
| `split<V>` | Handle both outcomes, terminal | `V` |
| `map` | Extract and transform success value | `T` |
| `mapError` | Extract and transform error value | `E` |
| `bind<B>` | Chain operations, transform success type | `Trace<B, E>` |

---

## Real-World Example

A complete clean architecture implementation using DartExceptor:

### Define your error type

```dart
class AppException {
  final int code;
  final String e;
  final String? stackTrace;

  const AppException({
    required this.code,
    required this.e,
    this.stackTrace,
  });
}
```

### Data layer

```dart
abstract class DataSource {
  Future<Trace<List<User>, AppException>> getAllUsers();
  Future<Trace<User, AppException>> getUserById({required int id});
}

class RemoteDataSource extends DataSource {
  @override
  Future<Trace<List<User>, AppException>> getAllUsers() async {
    try {
      final response = await api.get('/users');
      return Ok(response.data.map(User.fromJson).toList());
    } catch (e, st) {
      return Err(AppException(
        code: 500,
        e: e.toString(),
        stackTrace: st.toString(),
      ));
    }
  }

  @override
  Future<Trace<User, AppException>> getUserById({required int id}) async {
    try {
      final response = await api.get('/users/$id');
      return Ok(User.fromJson(response.data));
    } catch (e, st) {
      return Err(AppException(code: 404, e: 'User not found'));
    }
  }
}
```

### Repository layer

```dart
abstract class IUserRepository {
  Future<Trace<List<User>, AppException>> getAllUsers();
  Future<Trace<User, AppException>> getUserById({required int id});
}

class UserRepository extends IUserRepository {
  UserRepository({required this.dataSource});
  final DataSource dataSource;

  @override
  Future<Trace<List<User>, AppException>> getAllUsers() => dataSource.getAllUsers();

  @override
  Future<Trace<User, AppException>> getUserById({required int id}) =>
      dataSource.getUserById(id: id);
}
```

### Use case layer

```dart
class UserUseCase {
  UserUseCase({required this.repository});
  final IUserRepository repository;

  Future<Trace<List<User>, AppException>> getAllUsers() => repository.getAllUsers();
  Future<Trace<User, AppException>> getUserById({required int id}) =>
      repository.getUserById(id: id);
}
```

### Presentation layer

```dart
// Split :handle both sides
void loadUsers() async {
  final result = await useCase.getAllUsers();

  result.split(
    data: (users) {
      print('Total users: ${users.length}');
      print('New customers: ${users.where((u) => u.isNewCustomer).length}');
    },
    e: (e) => print('Failed: ${e.e}'),
  );
}

// Map : extract and work with success value
void getSingleUser({required String name}) async {
  final result = await useCase.getAllUsers();
  try {
    final users = result.map(data: (u) => u);
    final user = users.firstWhere((u) => u.firstName == name);
    print('Found: ${user.firstName} ${user.lastName}');
  } catch (e) {
    final error = result.mapError(e: (e) => e);
    print('Error: ${error.e}');
  }
}

// Bind — chain and transform
void getUserById({required int id}) async {
  try {
    final result = await useCase.getAllUsers();

    result
        .bind<User>(
          n: (users) {
            try {
              return Ok(users.firstWhere((e) => e.id == id));
            } catch (e) {
              return Err(AppException(code: 404, e: 'User not found'));
            }
          },
        )
        .bind<String>(n: (user) => Ok(user.firstName))
        .split(
          data: (name) => print('User: $name'),
          e: (e) => print('Error: ${e.e}'),
        );
  } catch (e) {
    rethrow;
  }
}
```

---

## Monad Laws

DartExceptor satisfies the three monad laws:

**Left identity** — wrapping a value in `Ok` and binding is the same as applying
the function directly:
```dart
Ok(value).bind<B>(n: (v) => f(v)) == f(value)
```

**Right identity** — binding with `Ok` preserves the original trace:
```dart
trace.bind<T>(n: (v) => Ok(v)) == trace
```

**Associativity** — chaining `bind` calls is associative:
```dart
trace.bind<B>(n: f).bind<C>(n: g) == trace.bind<C>(n: (v) => f(v).bind<C>(n: g))
```

---

## Design Philosophy

**One file import.** Everything you need comes from a single import.

**No runtime dependencies.** DartExceptor has zero external dependencies. It will never
break because a transitive dependency changed.

**Dart 3 native.** Built specifically for Dart 3. No legacy workarounds,
no compatibility shims.

**Architecture agnostic.** Works with clean architecture, MVVM, BLoC, or any
pattern your team uses. DartExceptor does not impose structure — it just makes error
handling honest.

**Errors are values.** An `Err` is not an exception. It is a value that describes
what went wrong. It can be passed around, transformed, logged, and handled —
just like any other value.

**Type safety through the chain.** `bind<B>` carries type information across every
step — the compiler catches type mismatches before they reach production.

---


## Requirements

- Dart SDK `>=3.0.0 <4.0.0`

---

## Contributing

Contributions are welcome. Please open an issue before submitting a PR so we
can discuss the change first.

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Author

Built by [Oluwaseyi Fatunmole](https://github.com/seyifunmi92).
My portfolio : https://foluwaseyidev.netlify.app/
hashnode : https://hashnode.com/@foluwaseyi


If DartExceptor saves you from a production bug, consider giving it a ⭐ on GitHub.