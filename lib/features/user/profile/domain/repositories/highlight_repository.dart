import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/entities/home_data.dart';

abstract class HighlightRepository {
  /// Fetch current user's highlights (`GET /api/v1/highlights/{userId}`)
  Future<Either<Failure, List<HighlightEntity>>> getMyHighlights(int userId);

  /// Upload a new highlight (`POST /api/v1/highlights` — multipart)
  Future<Either<Failure, HighlightEntity>> createHighlight({
    required String filePath,
    required String mediaType, // 'image' or 'video'
    String? name,
  });

  /// Delete a highlight by ID (`DELETE /api/v1/highlights/{id}`)
  Future<Either<Failure, void>> deleteHighlight(int highlightId);
}
