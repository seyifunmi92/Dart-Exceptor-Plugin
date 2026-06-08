import 'main.dart';
import 'model.dart';
import 'repository.dart';

class Usecase {
  Usecase({required this.repository});
  IRepository repository;

  Future<ITrace<List<User>>> getAllUsers() {
    return repository.getAllUsers();
  }

  Future<ITrace<User>> getUserById({required int id}) {
    return repository.getUserById(id: id);
  }
}
