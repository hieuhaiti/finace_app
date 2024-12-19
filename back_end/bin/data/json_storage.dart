import 'dart:convert';
import 'dart:io';

abstract class JsonStorage<T> {
  final String fileName;
  late final File _file;

  JsonStorage(this.fileName) {
    _file = File(fileName);
    if (!_file.existsSync()) {
      _file.createSync(recursive: true);
      _file.writeAsStringSync(jsonEncode({}));
    }
  }

  Future<void> save(String id, T object) async {
    final data = await _readFile();
    data[id] = toJson(object);
    await _writeFile(data);
  }

  Future<T?> fetchById(String id) async {
    final data = await _readFile();
    if (data.containsKey(id)) {
      return fromJson(data[id]);
    }
    return null;
  }

  Future<List<T>> fetchWhere(String key, String value) async {
    final data = await _readFile();
    return data.values
        .where((json) => json[key] == value)
        .map((json) => fromJson(json))
        .toList();
  }

  Future<void> delete(String id) async {
    final data = await _readFile();
    data.remove(id);
    await _writeFile(data);
  }

  Future<Map<String, dynamic>> _readFile() async {
    try {
      final content = await _file.readAsString();
      if (content.isEmpty) {
        return {};
      }
      final returnContent = jsonDecode(content) as Map<String, dynamic>;
      return returnContent;
    } catch (e) {
      print('Error reading file: $e');
      return {};
    }
  }

  Future<void> _writeFile(Map<String, dynamic> data) async {
    try {
      await _file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Error writing file: $e');
    }
  }

  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T object);
}