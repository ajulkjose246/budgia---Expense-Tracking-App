import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2) // Make sure this typeId is unique
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int iconCode;

  CategoryModel({
    required this.name,
    required this.iconCode,
  });
}
