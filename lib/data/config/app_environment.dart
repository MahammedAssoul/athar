import '../api/api_config.dart';
import '../services/observability_service.dart';

/// Environment configuration for development, staging and production.
///
/// SECURITY: this file contains NO secrets. Real credentials (API keys,
/// tokens, payment provider secrets) are injected at build/deploy time
/// via environment variables or a secure config service — never
/// committed to the repository.
class AppEnvironment {
  AppEnvironment._();

  /// The active environment. Override before app start (e.g. in tests).
  static ApiEnvironment current = ApiEnvironment.prod;

  /// Whether the app runs in a development build.
  static bool get isDev => current == ApiEnvironment.dev;

  /// Whether the app runs in a staging build.
  static bool get isStaging => current == ApiEnvironment.staging;

  /// Whether the app runs in a production build.
  static bool get isProd => current == ApiEnvironment.prod;

  /// Applies the environment to [ApiConfig].
  static void apply(ApiEnvironment environment) {
    current = environment;
    ApiConfig.baseUrlOverride = ApiEnvironmentConfig.of(environment).baseUrl;
  }
}

/// Logging configuration per environment.
class LoggingConfig {
  LoggingConfig._();

  /// Minimum log level that gets persisted/sent.
  static LogLevel minLevel(ApiEnvironment environment) {
    return switch (environment) {
      ApiEnvironment.dev => LogLevel.debug,
      ApiEnvironment.staging => LogLevel.info,
      ApiEnvironment.prod => LogLevel.warning,
    };
  }

  /// Whether structured logs are sent to the backend.
  static bool remoteLoggingEnabled(ApiEnvironment environment) {
    return environment != ApiEnvironment.dev;
  }
}

/// Analytics configuration per environment.
class AnalyticsConfig {
  AnalyticsConfig._();

  /// Whether analytics events are tracked.
  static bool trackingEnabled(ApiEnvironment environment) {
    return environment != ApiEnvironment.dev;
  }

  /// Whether events include device-level properties.
  static bool includeDeviceInfo(ApiEnvironment environment) {
    return environment == ApiEnvironment.prod;
  }
}

/// Notification configuration per environment.
class NotificationConfig {
  NotificationConfig._();

  /// Whether push notifications are enabled.
  static bool pushEnabled(ApiEnvironment environment) {
    return environment != ApiEnvironment.dev;
  }

  /// Whether SMS delivery is enabled (production only).
  static bool smsEnabled(ApiEnvironment environment) {
    return environment == ApiEnvironment.prod;
  }

  /// Whether email delivery is enabled.
  static bool emailEnabled(ApiEnvironment environment) {
    return environment != ApiEnvironment.dev;
  }
}

/// Security configuration.
class SecurityConfig {
  SecurityConfig._();

  /// OTP rate limit: max sends per phone per window.
  static const int otpMaxAttempts = 5;
  static const int otpWindowSeconds = 300;

  /// Donation fraud: duplicate window in seconds.
  static const int duplicateDonationWindowSeconds = 300;

  /// Unusual amount threshold (LYD).
  static const double unusualAmountThreshold = 5000;
}
