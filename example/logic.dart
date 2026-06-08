import 'data.dart';
import 'usecase.dart';
import 'api_mock.dart';
import 'repository.dart';

class UserLogic {
  final logic = Usecase(
    repository: Repository(dataSource: BaseDataSource(mock: MockAPiCall())),
  );

  void getAllUsers() async {
    final res = await logic.getAllUsers();
    //on split
    res.split(
      data: (users) {
        print('Successful\n {totalUsers: ${users.length}\ndata : $users\nstatus : Successful}');
        print('Total count oof new customers : ${users.firstWhere((e) => e.isNewCustomer == true)}');
        //do something

      


      },
      e: (e) {
        print('An Error Occured while retrieving all users\nerror: ${e.e}');
      },
    );
  }
}
