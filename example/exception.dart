class IException {
  final int code;
  final String? stackTrace;
  final String e;
  const IException({required this.code, this.stackTrace, required this.e});
}
