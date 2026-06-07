import 'data.dart';
import 'main.dart';
import 'model.dart';

abstract class IRepository {
  Future<ITrace<List<User>>> getAllUsers();
}

class Repository extends IRepository {
  Repository({required this.dataSource});
  BaseDataSource dataSource;

  @override
  Future<ITrace<List<User>>> getAllUsers() {
    return dataSource.getAllUsers();
  }
}
