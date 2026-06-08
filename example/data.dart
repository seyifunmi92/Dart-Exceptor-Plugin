import 'main.dart';
import 'local.dart';
import 'model.dart';
import 'api_mock.dart';
import 'exception.dart';
import 'package:dart_exceptor/dart_exceptor.dart';

abstract class DataSource {
  Future<ITrace<List<User>>> getAllUsers();
  //lets add more functions to explain the 'bind' concept
  Future<ITrace<User>> getUserById({required int id});
}

class BaseDataSource extends DataSource {
  BaseDataSource({required this.mock});
  MockAPiCall mock;

  @override
  Future<ITrace<List<User>>> getAllUsers() async {
    try {
      final res = await mock.callApi(code: 200, data: allUsers);
      return Ok(res.data!);
    } catch (e, st) {
      return Err(
        IException(code: 200, e: e.toString(), stackTrace: st.toString()),
      );
    }
  }

  @override
  Future<ITrace<User>> getUserById({required int id}) async {
    try {
      final res = await mock.callApi(code: 200, data: allUsers);
      final user = res.data?.firstWhere((e) => e.id == id);
      return Ok(user!);
    } catch (e) {
      return Err(IException(code: 500, e: e.toString()));
    }
  }
}
