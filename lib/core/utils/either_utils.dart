import 'package:dartz/dartz.dart';
import 'package:give_track/core/errors/failures.dart';

/// Thrown when a [Left] is unwrapped as success in the UI / providers layer.
final class FailureException implements Exception {
  FailureException(this.failure);
  final Failure failure;

  @override
  String toString() => failure.message;
}

extension EitherFailureX<T> on Either<Failure, T> {
  /// Returns [Right] value or throws [FailureException] for [Left].
  T unpack() => fold((f) => throw FailureException(f), (r) => r);
}
