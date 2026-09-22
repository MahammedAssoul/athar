/// Centralized API error types.
///
/// Repositories throw these; the UI layer converts them into
/// user-friendly localized messages via [ApiError.localizedMessage].
enum ApiErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  server,
  validation,
  unknown,
}

/// A typed API error with a machine-readable code and optional details.
class ApiException implements Exception {
  const ApiException(this.type, {this.message, this.statusCode, this.details});

  final ApiErrorType type;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  bool get isUnauthorized => type == ApiErrorType.unauthorized;

  @override
  String toString() =>
      'ApiException(${type.name}, status: $statusCode, message: $message)';
}

/// Maps [ApiException]s to localized user messages.
///
/// The UI never inspects raw exceptions — it calls [localizedMessage]
/// which returns Arabic/English text depending on the app locale.
class ApiErrorMessages {
  ApiErrorMessages._();

  /// Arabic message for an error type.
  static String ar(ApiErrorType type) => switch (type) {
    ApiErrorType.network => 'لا يوجد اتصال بالإنترنت',
    ApiErrorType.timeout => 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى',
    ApiErrorType.unauthorized => 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى',
    ApiErrorType.forbidden => 'ليس لديك صلاحية للقيام بهذا الإجراء',
    ApiErrorType.notFound => 'العنصر المطلوب غير موجود',
    ApiErrorType.server => 'حدث خطأ، يرجى المحاولة مرة أخرى',
    ApiErrorType.validation => 'يرجى التحقق من البيانات المدخلة',
    ApiErrorType.unknown => 'حدث خطأ غير متوقع',
  };

  /// English message for an error type.
  static String en(ApiErrorType type) => switch (type) {
    ApiErrorType.network => 'No internet connection',
    ApiErrorType.timeout => 'Connection timed out, please try again',
    ApiErrorType.unauthorized => 'Session expired, please log in again',
    ApiErrorType.forbidden => 'You are not allowed to perform this action',
    ApiErrorType.notFound => 'The requested item was not found',
    ApiErrorType.server => 'Something went wrong, please try again',
    ApiErrorType.validation => 'Please check the entered data',
    ApiErrorType.unknown => 'An unexpected error occurred',
  };
}

/// Converts any thrown object into an [ApiException].
class ApiErrorMapper {
  ApiErrorMapper._();

  /// Maps an HTTP status code to an [ApiErrorType].
  static ApiErrorType typeFromStatus(int statusCode) {
    return switch (statusCode) {
      400 || 422 => ApiErrorType.validation,
      401 => ApiErrorType.unauthorized,
      403 => ApiErrorType.forbidden,
      404 => ApiErrorType.notFound,
      >= 500 => ApiErrorType.server,
      _ => ApiErrorType.unknown,
    };
  }

  /// Wraps an arbitrary error into an [ApiException].
  static ApiException from(Object error, {int? statusCode}) {
    if (error is ApiException) return error;
    if (error is FormatException) {
      return const ApiException(ApiErrorType.validation);
    }
    return ApiException(
      ApiErrorType.unknown,
      message: error.toString(),
      statusCode: statusCode,
    );
  }
}
