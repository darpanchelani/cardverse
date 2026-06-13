class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.errors = const []});

  final String message;
  final int? statusCode;
  final List<dynamic> errors;

  @override
  String toString() => message;
}
