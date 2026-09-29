import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/home_data.dart';
import '../repositories/home_repository.dart';

@lazySingleton
class GetHomeData implements UseCase<HomeData, NoParams> {
  final HomeRepository repository;

  GetHomeData(this.repository);

  @override
  Future<Either<Failure, HomeData>> call(NoParams params) async {
    return await repository.getHomeData();
  }
}
