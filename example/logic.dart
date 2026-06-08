import 'dart:math';
import 'data.dart';
import 'model.dart';
import 'usecase.dart';
import 'api_mock.dart';
import 'exception.dart';
import 'repository.dart';
import 'package:result_x/src/trace/impl/ok.dart';
import 'package:result_x/src/trace/impl/err.dart';

class UserLogic {
  final logic = Usecase(
    repository: Repository(dataSource: BaseDataSource(mock: MockAPiCall())),
  );

  void getAllUsers() async {
    final res = await logic.getAllUsers();
    //on split
    res.split(
      data: (users) {
        print(
          'Successful\n {totalUsers: ${users.length}\ndata : $users\nstatus : Successful}',
        );
        print(
          'Total count oof new customers : ${users.firstWhere((e) => e.isNewCustomer == true)}',
        );
      },
      e: (e) {
        print('An Error Occured while retrieving all users\nerror: ${e.e}');
      },
    );
  }

  void getSingleUser({required String name}) async {
    final res = await logic.getAllUsers();
    try {
      final users = res.map(data: (e) => e);
      final user = users.firstWhere((e) => e.firstName == name);

      print(
        'User data returned ${user.firstName}\n${user.lastName}\n${user.id}',
      );
    } catch (e) {
      final error = res.mapError(e: (e) => e);
      print('An error has occured : ${error.e}');
    }
  }

  void getUserById({required int id}) async {
    try {
      final result = await logic.getAllUsers();

      result
          .bind<User>(
            n: (users) {
              return Ok(users.firstWhere((e) => e.id == id));
            },
          )
          .bind<String>(
            n: (user) {
              print('Here is the user info ${user.lastName}');
              return Ok(user.lastName);
            },
          );
    } catch (e) {
      rethrow;
    }
  }
}
