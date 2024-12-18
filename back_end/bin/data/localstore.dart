import 'package:localstore/localstore.dart';

/// Base abstract class for Localstore CRUD operations
abstract class LocalstoreService<T> {
  final Localstore db = Localstore.instance;

  /// Collection name to identify data in Localstore
  String get collectionName;

  /// Converts JSON data to an object of type T
  T fromJson(Map<String, dynamic> json);

  /// Converts object to JSON
  Map<String, dynamic> toJson(T object);

  /// Saves or updates a document by its ID
  Future<void> save(String documentId, T object) async {
    try {
      final data = toJson(object);
      await db.collection(collectionName).doc(documentId).set(data);
    } catch (e) {
      throw Exception('Failed to save document: $e');
    }
  }

  /// Deletes a document by its ID
  Future<void> delete(String documentId) async {
    try {
      await db.collection(collectionName).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Updates specific fields in a document
  Future<void> update(String documentId, Map<String, dynamic> updates) async {
    try {
      final existingData = await db.collection(collectionName).doc(documentId).get();
      if (existingData != null) {
        final updatedData = {...existingData, ...updates};
        await db.collection(collectionName).doc(documentId).set(updatedData);
      } else {
        throw Exception("Document not found to update");
      }
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  /// Fetches all documents in a collection
  Future<List<T>> fetchAll() async {
    try {
      final items = await db.collection(collectionName).get();
      if (items != null) {
        return items.values.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch all documents: $e');
    }
  }

  /// Queries documents based on a field and value
  Future<List<T>> fetchWhere(String field, dynamic value) async {
    try {
      final items = await db.collection(collectionName).get();
      if (items != null) {
        return items.values
            .where((doc) => doc[field] == value)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch documents with condition: $e');
    }
  }

  /// Fetches a single document by its ID
  Future<T?> fetchById(String documentId) async {
    try {
      final data = await db.collection(collectionName).doc(documentId).get();
      if (data != null) {
        return fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch document by ID: $e');
    }
  }
}
