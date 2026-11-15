sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value, {this.isFromCache = false});

  final T value;
  final bool isFromCache;
}

final class Failure<T> extends Result<T> {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;
}