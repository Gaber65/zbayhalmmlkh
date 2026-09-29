import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import 'package:dhabayih_lmamlaka/core/config/app_config.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends Equatable {
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'image_url', defaultValue: '')
  final String imageUrl;

  const CategoryModel({
    required this.id,
    this.name = '',
    this.imageUrl = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  Category toDomain() {
    String img = imageUrl;
    if (img.isNotEmpty && !img.startsWith('http') && !img.startsWith('data:')) {
      final base = AppConfig.baseUrl.endsWith('/')
          ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
          : AppConfig.baseUrl;
      final path = img.startsWith('/') ? img : '/$img';
      img = '$base$path';
    }
    return Category(
      id: id,
      name: name,
      imageUrl: img,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl];
}
