import 'package:test/test.dart';
import 'package:localstore/localstore.dart';
import '../../bin/models/user.dart';
import '../../bin/models/category.dart';
import '../../bin/models/transaction.dart';
import '../../bin/models/spending_plan.dart';
import '../../bin/data/localstore.dart';

class UserLocalstoreService extends LocalstoreService<User> {
  @override
  String get collectionName => 'users';

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(User object) => object.toJson();
}

class TransactionLocalstoreService extends LocalstoreService<Transaction> {
  @override
  String get collectionName => 'transactions';

  @override
  Transaction fromJson(Map<String, dynamic> json) => Transaction.fromJson(json);

  @override
  Map<String, dynamic> toJson(Transaction object) => object.toJson();
}

class SpendingPlanLocalstoreService extends LocalstoreService<SpendingPlan> {
  @override
  String get collectionName => 'spending_plans';

  @override
  SpendingPlan fromJson(Map<String, dynamic> json) => SpendingPlan.fromJson(json);

  @override
  Map<String, dynamic> toJson(SpendingPlan object) => object.toJson();
}

class CategoryLocalstoreService extends LocalstoreService<Category> {
  @override
  String get collectionName => 'categories';

  @override
  Category fromJson(Map<String, dynamic> json) => Category.fromJson(json);

  @override
  Map<String, dynamic> toJson(Category object) => object.toJson();
}

void main() {
  final userLocalstoreService = UserLocalstoreService();
  final transactionLocalstoreService = TransactionLocalstoreService();
  final spendingPlanLocalstoreService = SpendingPlanLocalstoreService();
  final categoryLocalstoreService = CategoryLocalstoreService();

  setUp(() async {
    // Clear the database before each test
    await Localstore.instance.collection('users').delete();
    await Localstore.instance.collection('transactions').delete();
    await Localstore.instance.collection('spending_plans').delete();
    await Localstore.instance.collection('categories').delete();
  });

  group('User CRUD Operations', () {
    test('Save and Fetch User', () async {
      final user = User(id: '123', username: 'testuser', password: 'testpass');
      await userLocalstoreService.save(user.id, user);

      final fetchedUser = await userLocalstoreService.fetchById(user.id);
      expect(fetchedUser, isNotNull);
      expect(fetchedUser!.username, equals('testuser'));
      expect(fetchedUser.password, equals('testpass'));
    });

    test('Update User', () async {
      final user = User(id: '123', username: 'testuser', password: 'testpass');
      await userLocalstoreService.save(user.id, user);

      final updates = {'username': 'updateduser', 'password': 'updatedpass'};
      await userLocalstoreService.update(user.id, updates);

      final updatedUser = await userLocalstoreService.fetchById(user.id);
      expect(updatedUser, isNotNull);
      expect(updatedUser!.username, equals('updateduser'));
      expect(updatedUser.password, equals('updatedpass'));
    });

    test('Delete User', () async {
      final user = User(id: '123', username: 'testuser', password: 'testpass');
      await userLocalstoreService.save(user.id, user);

      await userLocalstoreService.delete(user.id);

      final fetchedUser = await userLocalstoreService.fetchById(user.id);
      expect(fetchedUser, isNull);
    });
  });

  group('Transaction CRUD Operations', () {
    test('Save and Fetch Transaction', () async {
      final transaction = Transaction(
        id: '123',
        userId: 'user1',
        name: 'Salary',
        type: 'income',
        category: 'salary',
        amount: 1000.0,
        date: DateTime.parse('2023-01-01'),
      );
      await transactionLocalstoreService.save(transaction.id, transaction);

      final fetchedTransaction = await transactionLocalstoreService.fetchById(transaction.id);
      expect(fetchedTransaction, isNotNull);
      expect(fetchedTransaction!.name, equals('Salary'));
      expect(fetchedTransaction.type, equals('income'));
      expect(fetchedTransaction.category, equals('salary'));
      expect(fetchedTransaction.amount, equals(1000.0));
      expect(fetchedTransaction.date, equals(DateTime.parse('2023-01-01')));
    });

    test('Update Transaction', () async {
      final transaction = Transaction(
        id: '123',
        userId: 'user1',
        name: 'Salary',
        type: 'income',
        category: 'salary',
        amount: 1000.0,
        date: DateTime.parse('2023-01-01'),
      );
      await transactionLocalstoreService.save(transaction.id, transaction);

      final updates = {'name': 'Updated Salary', 'amount': 2000.0};
      await transactionLocalstoreService.update(transaction.id, updates);

      final updatedTransaction = await transactionLocalstoreService.fetchById(transaction.id);
      expect(updatedTransaction, isNotNull);
      expect(updatedTransaction!.name, equals('Updated Salary'));
      expect(updatedTransaction.amount, equals(2000.0));
    });

    test('Delete Transaction', () async {
      final transaction = Transaction(
        id: '123',
        userId: 'user1',
        name: 'Salary',
        type: 'income',
        category: 'salary',
        amount: 1000.0,
        date: DateTime.parse('2023-01-01'),
      );
      await transactionLocalstoreService.save(transaction.id, transaction);

      await transactionLocalstoreService.delete(transaction.id);

      final fetchedTransaction = await transactionLocalstoreService.fetchById(transaction.id);
      expect(fetchedTransaction, isNull);
    });
  });

  group('Spending Plan CRUD Operations', () {
    test('Save and Fetch Spending Plan', () async {
      final spendingPlan = SpendingPlan(
        userId: 'user1',
        categories: {'saving': 20, 'needs': 50, 'wants': 30},
      );
      await spendingPlanLocalstoreService.save(spendingPlan.userId, spendingPlan);

      final fetchedSpendingPlan = await spendingPlanLocalstoreService.fetchById(spendingPlan.userId);
      expect(fetchedSpendingPlan, isNotNull);
      expect(fetchedSpendingPlan!.categories, equals({'saving': 20, 'needs': 50, 'wants': 30}));
    });

    test('Update Spending Plan', () async {
      final spendingPlan = SpendingPlan(
        userId: 'user1',
        categories: {'saving': 20, 'needs': 50, 'wants': 30},
      );
      await spendingPlanLocalstoreService.save(spendingPlan.userId, spendingPlan);

      final updates = {'categories': {'saving': 25, 'needs': 45, 'wants': 30}};
      await spendingPlanLocalstoreService.update(spendingPlan.userId, updates);

      final updatedSpendingPlan = await spendingPlanLocalstoreService.fetchById(spendingPlan.userId);
      expect(updatedSpendingPlan, isNotNull);
      expect(updatedSpendingPlan!.categories, equals({'saving': 25, 'needs': 45, 'wants': 30}));
    });

    test('Delete Spending Plan', () async {
      final spendingPlan = SpendingPlan(
        userId: 'user1',
        categories: {'saving': 20, 'needs': 50, 'wants': 30},
      );
      await spendingPlanLocalstoreService.save(spendingPlan.userId, spendingPlan);

      await spendingPlanLocalstoreService.delete(spendingPlan.userId);

      final fetchedSpendingPlan = await spendingPlanLocalstoreService.fetchById(spendingPlan.userId);
      expect(fetchedSpendingPlan, isNull);
    });
  });

  group('Category CRUD Operations', () {
    test('Save and Fetch Category', () async {
      final category = Category(id: '123', userId: 'user1', name: 'Food', icon: 'food_icon', color: '#FF0000');
      await categoryLocalstoreService.save(category.id, category);

      final fetchedCategory = await categoryLocalstoreService.fetchById(category.id);
      expect(fetchedCategory, isNotNull);
      expect(fetchedCategory!.name, equals('Food'));
      expect(fetchedCategory.icon, equals('food_icon'));
      expect(fetchedCategory.color, equals('#FF0000'));
    });

    test('Update Category', () async {
      final category = Category(id: '123', userId: 'user1', name: 'Food', icon: 'food_icon', color: '#FF0000');
      await categoryLocalstoreService.save(category.id, category);

      final updates = {'name': 'Updated Food', 'icon': 'updated_food_icon', 'color': '#00FF00'};
      await categoryLocalstoreService.update(category.id, updates);

      final updatedCategory = await categoryLocalstoreService.fetchById(category.id);
      expect(updatedCategory, isNotNull);
      expect(updatedCategory!.name, equals('Updated Food'));
      expect(updatedCategory.icon, equals('updated_food_icon'));
      expect(updatedCategory.color, equals('#00FF00'));
    });

    test('Delete Category', () async {
      final category = Category(id: '123', userId: 'user1', name: 'Food', icon: 'food_icon', color: '#FF0000');
      await categoryLocalstoreService.save(category.id, category);

      await categoryLocalstoreService.delete(category.id);

      final fetchedCategory = await categoryLocalstoreService.fetchById(category.id);
      expect(fetchedCategory, isNull);
    });
  });
}