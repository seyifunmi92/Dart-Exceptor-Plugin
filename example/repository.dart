import 'data.dart';
import 'main.dart';
import 'model.dart';

abstract class IRepository {
  Future<ITrace<List<User>>> getAllUsers();

  Future<ITrace<User>> getUserById({required int id});
}

class Repository extends IRepository {
  Repository({required this.dataSource});
  BaseDataSource dataSource;

  @override
  Future<ITrace<List<User>>> getAllUsers() {
    return dataSource.getAllUsers();
  }

  @override
  Future<ITrace<User>> getUserById({required int id}) {
    return dataSource.getUserById(
      id: id,
    );
  }
}
