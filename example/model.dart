class User {
  final String firstName, lastName;
  final int age;
  final bool isNewCustomer;
  final DateTime dob;

  const User({required this.firstName, required this.lastName, required this.age, required this.isNewCustomer, required this.dob});
}

class ApiResponse<T> {
  T? data;
  int code;

  ApiResponse({this.data, required this.code});
}
