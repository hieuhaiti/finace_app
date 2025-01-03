import 'json_storage.dart';
import '../models/category.dart';

class CategoryStorage extends JsonStorage<Category> {
  CategoryStorage(String fileName) : super(fileName);

  @override
  Category fromJson(Map<String, dynamic> json) {
    return Category.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Category object) {
    return object.toJson();
  }
}