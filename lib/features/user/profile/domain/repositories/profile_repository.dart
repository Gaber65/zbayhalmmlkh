import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, UserProfile>> updateProfile({
    String? name,
    String? phone,
    String? preferredLanguage,
    String? preferredTheme,
    bool? pushNotificationsEnabled,
  });
}
