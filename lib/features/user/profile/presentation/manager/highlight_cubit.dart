import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/entities/home_data.dart';
import '../../domain/repositories/highlight_repository.dart';
import 'highlight_state.dart';

@injectable
class HighlightCubit extends Cubit<HighlightState> {
  final HighlightRepository repository;

  HighlightCubit({required this.repository}) : super(HighlightInitial());

  // Keep a local copy for mutation without re-fetching
  List<HighlightEntity> _highlights = [];

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<void> fetchMyHighlights(int userId) async {
    emit(HighlightLoading());
    final result = await repository.getMyHighlights(userId);
    result.fold(
      (failure) => emit(HighlightError(failure.error.message)),
      (highlights) {
        _highlights = highlights;
        emit(HighlightLoaded(highlights: _highlights));
      },
    );
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<void> uploadHighlight({
    required String filePath,
    required String mediaType,
    String? name,
  }) async {
    emit(HighlightUploading());
    final result = await repository.createHighlight(
      filePath: filePath,
      mediaType: mediaType,
      name: name,
    );
    result.fold(
      (failure) => emit(HighlightError(failure.error.message)),
      (newHighlight) {
        _highlights = [..._highlights, newHighlight];
        emit(HighlightUploadSuccess(highlights: _highlights));
      },
    );
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteHighlight(int highlightId) async {
    final result = await repository.deleteHighlight(highlightId);
    result.fold(
      (failure) => emit(HighlightError(failure.error.message)),
      (_) {
        _highlights =
            _highlights.where((h) => h.id != highlightId).toList();
        emit(HighlightDeleteSuccess(highlights: _highlights));
      },
    );
  }
}
