/// Standardized REST API Response Envelope
class ApiResponse<T> {
  final int statusCode;
  final bool isSuccess;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final dynamic rawBody;

  ApiResponse({
    required this.statusCode,
    required this.isSuccess,
    required this.message,
    this.data,
    this.errors,
    this.rawBody,
  });

  factory ApiResponse.success({
    required T data,
    String message = 'Success',
    int statusCode = 200,
    dynamic rawBody,
  }) {
    return ApiResponse<T>(
      statusCode: statusCode,
      isSuccess: true,
      message: message,
      data: data,
      rawBody: rawBody,
    );
  }

  factory ApiResponse.error({
    required String message,
    int statusCode = 400,
    Map<String, dynamic>? errors,
    dynamic rawBody,
  }) {
    return ApiResponse<T>(
      statusCode: statusCode,
      isSuccess: false,
      message: message,
      errors: errors,
      rawBody: rawBody,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, isSuccess: $isSuccess, message: "$message", data: $data)';
  }
}
