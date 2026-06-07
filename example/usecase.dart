import 'main.dart';
import 'model.dart';
import 'repository.dart';

class Usecase {
  Usecase({required this.repository});
  IRepository repository;
  @override
  Future<ITrace<List<User>>> getAllUsers() {
    return repository.getAllUsers();
  }
}
