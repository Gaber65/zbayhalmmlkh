import 'package:equatable/equatable.dart';
import '../network/error_message_model.dart';

abstract class Failure extends Equatable {
  final ErrorMessageModel error;

  const Failure(this.error);

  @override
  List<Object> get props => [error];
}

class ServerFailure extends Failure {
  const ServerFailure(super.error);
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure(super.error);
}

class CacheFailure extends Failure {
  const CacheFailure(super.error);
}
