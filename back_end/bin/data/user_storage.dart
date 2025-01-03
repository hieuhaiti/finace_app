import 'json_storage.dart';
import '../models/user.dart';

class UserStorage extends JsonStorage<User> {
  UserStorage(String fileName) : super(fileName);

  @override
  User fromJson(Map<String, dynamic> json) {
    return User.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(User object) {
    return object.toJson();
  }
}
