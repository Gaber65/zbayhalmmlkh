import 'package:equatable/equatable.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/entities/home_data.dart';

abstract class HighlightState extends Equatable {
  const HighlightState();

  @override
  List<Object?> get props => [];
}

class HighlightInitial extends HighlightState {}

class HighlightLoading extends HighlightState {}

class HighlightLoaded extends HighlightState {
  final List<HighlightEntity> highlights;

  const HighlightLoaded({required this.highlights});

  @override
  List<Object?> get props => [highlights];
}

class HighlightUploading extends HighlightState {}

class HighlightUploadSuccess extends HighlightState {
  final List<HighlightEntity> highlights;

  const HighlightUploadSuccess({required this.highlights});

  @override
  List<Object?> get props => [highlights];
}

class HighlightDeleteSuccess extends HighlightState {
  final List<HighlightEntity> highlights;

  const HighlightDeleteSuccess({required this.highlights});

  @override
  List<Object?> get props => [highlights];
}

class HighlightError extends HighlightState {
  final String message;

  const HighlightError(this.message);

  @override
  List<Object?> get props => [message];
}
