import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../entities/home_data.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeData>> getHomeData();
}
