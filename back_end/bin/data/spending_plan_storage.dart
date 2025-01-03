import 'json_storage.dart';
import '../models/spending_plan.dart';

class SpendingPlanStorage extends JsonStorage<SpendingPlan> {
  SpendingPlanStorage(String fileName) : super(fileName);

  @override
  SpendingPlan fromJson(Map<String, dynamic> json) {
    return SpendingPlan.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(SpendingPlan object) {
    return object.toJson();
  }
}