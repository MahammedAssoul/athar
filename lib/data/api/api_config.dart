/// Central API configuration.
///
/// All backend URLs, versions, timeouts and headers are defined here —
/// never hardcoded in repositories or widgets.
class ApiConfig {
  ApiConfig._();

  /// Base URL of the Athar backend.
  ///
  /// Override per environment (dev / staging / prod) via
  /// [ApiEnvironment] or by setting [baseUrlOverride] before app start.
  static const String baseUrl = 'https://api.athar.ly';

  /// API version prefix appended to the base URL.
  static const String apiVersion = 'v1';

  /// Full API root: `https://api.athar.ly/v1`.
  static String get apiRoot => '$baseUrl/$apiVersion';

  /// Request timeout for all HTTP calls.
  static const Duration timeout = Duration(seconds: 15);

  /// Default JSON headers sent with every request.
  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Optional override used by tests or local development.
  static String? baseUrlOverride;

  /// Resolves the effective base URL (override wins).
  static String get effectiveBaseUrl => baseUrlOverride ?? baseUrl;
}

/// Supported backend environments.
enum ApiEnvironment { dev, staging, prod }

/// Environment-specific configuration.
class ApiEnvironmentConfig {
  const ApiEnvironmentConfig({required this.baseUrl});

  final String baseUrl;

  static const ApiEnvironmentConfig dev = ApiEnvironmentConfig(
    baseUrl: 'https://dev-api.athar.ly',
  );
  static const ApiEnvironmentConfig staging = ApiEnvironmentConfig(
    baseUrl: 'https://staging-api.athar.ly',
  );
  static const ApiEnvironmentConfig prod = ApiEnvironmentConfig(
    baseUrl: 'https://api.athar.ly',
  );

  /// Returns the config for the given environment.
  static ApiEnvironmentConfig of(ApiEnvironment environment) {
    return switch (environment) {
      ApiEnvironment.dev => dev,
      ApiEnvironment.staging => staging,
      ApiEnvironment.prod => prod,
    };
  }
}
