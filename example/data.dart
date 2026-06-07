import 'main.dart';
import 'local.dart';
import 'model.dart';
import 'api_mock.dart';
import 'exception.dart';
import 'package:result_x/src/trace/impl/ok.dart';
import 'package:result_x/src/trace/impl/err.dart';

abstract class DataSource {
  Future<ITrace<List<User>>> getAllUsers();
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
      return Err(IException(code: 200, e: e.toString(), stackTrace: st.toString()));
    }
  }
}
