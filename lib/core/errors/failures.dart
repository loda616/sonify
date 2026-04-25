/// Base failure class for use case return types.
/// Use these instead of throwing exceptions from repositories.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class TtsFailure extends Failure {
  const TtsFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class GenerationFailure extends Failure {
  const GenerationFailure(super.message);
}
