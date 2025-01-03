import 'json_storage.dart';
import '../models/transaction.dart';

class TransactionStorage extends JsonStorage<Transaction> {
  TransactionStorage(String fileName) : super(fileName);

  @override
  Transaction fromJson(Map<String, dynamic> json) {
    return Transaction.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Transaction object) {
    return object.toJson();
  }
}
