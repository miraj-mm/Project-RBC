/// Base exception for feature-related errors.
abstract class FeatureException implements Exception {
  final String message;
  const FeatureException(this.message);

  @override
  String toString() => 'FeatureException: $message';
}

/// Exception thrown when there's an issue with data fetching.
class DataFetchException extends FeatureException {
  const DataFetchException(String message) : super('Failed to fetch data: $message');
}

/// Exception thrown when data parsing fails.
class DataParseException extends FeatureException {
  const DataParseException(String message) : super('Failed to parse data: $message');
}

/// Exception thrown when a service is not initialized.
class ServiceNotInitializedException extends FeatureException {
  const ServiceNotInitializedException(String serviceName)
      : super('$serviceName is not initialized. Please ensure it is properly set up.');
}