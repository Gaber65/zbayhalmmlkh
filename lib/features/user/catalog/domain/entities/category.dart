import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final int sequence;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.sequence = 10,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, sequence];
}
