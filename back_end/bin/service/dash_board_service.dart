import 'dart:collection';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import '../data/user_storage.dart';
import '../data/spending_plan_storage.dart';
import '../data/category_storage.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/spending_plan.dart';
import '../data/transaction_storage.dart';

class DashBoardService {
  final UserStorage userStorage = UserStorage('bin/data/json/users.json');
  final TransactionStorage transactionStorage =
      TransactionStorage('bin/data/json/transactions.json');
  final SpendingPlanStorage spendingPlanStorage =
      SpendingPlanStorage('bin/data/json/spending_plans.json');
  final CategoryStorage categoryStorage =
      CategoryStorage('bin/data/json/categories.json');
  final _headers = {'Content-Type': 'application/json'};

  // return income, outcome, remain current month
  Future<Response> getNetWorthCurrentHandler(
      Request request, String userId) async {
    try {
      User? user = await userStorage.fetchById(userId);
      if (user == null) {
        return Response.notFound('User not found');
      }
      List<Transaction> transactions =
          await transactionStorage.fetchWhere('userId', userId);
      DateTime now = DateTime.now();
      List<Transaction> currentMonthTransactions =
          transactions.where((transaction) {
        return transaction.date.year == 2024 && transaction.date.month == 12;
      }).toList();

      // Calculate income, outcome, and remaining balance
      double income = 0;
      double outcome = 0;
      for (var transaction in currentMonthTransactions) {
        if (transaction.type == 'Income') {
          income += transaction.amount;
        } else if (transaction.type == 'Outcome') {
          outcome += transaction.amount;
        }
      }

      double remain = income + outcome;

      // Return the result as JSON
      Map<String, double> result = {
        'Income': income,
        'Outcome': outcome,
        'Remain': remain,
      };

      return Response.ok(jsonEncode(result), headers: _headers);
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  // return income, outcome, remain group by month and year like: {year{month : {income, outcome, remain}, month : {income, outcome, remain}}, year{month : {income, outcome, remain}, month : {income, outcome, remain}}}
  Future<Response> getNetWorthDetailHandler(
      Request request, String userId) async {
    try {
      User? user = await userStorage.fetchById(userId);
      if (user == null) {
        return Response.notFound('User not found');
      }
      List<Transaction> transactions =
          await transactionStorage.fetchWhere('userId', userId);

      // Group transactions by year and month
      Map<String, Map<String, Map<String, double>>> netWorthDetail = {};

      for (var transaction in transactions) {
        String year = transaction.date.year.toString();
        String month = transaction.date.month.toString().padLeft(2, '0');

        netWorthDetail[year] ??= {};
        netWorthDetail[year]![month] ??= {'Income': 0, 'Outcome': 0};
        if (transaction.type == 'Income') {
          netWorthDetail[year]![month]!['Income'] =
              netWorthDetail[year]![month]!['Income']! + transaction.amount;
        } else if (transaction.type == 'Outcome') {
          netWorthDetail[year]![month]!['Outcome'] =
              netWorthDetail[year]![month]!['Outcome']! + transaction.amount;
        }
      }
      var sortedNetWorthDetail =
          SplayTreeMap<String, Map<String, Map<String, double>>>.from(
        netWorthDetail,
        (a, b) => b.compareTo(a),
      );

      sortedNetWorthDetail.forEach((year, months) {
        sortedNetWorthDetail[year] =
            SplayTreeMap<String, Map<String, double>>.from(
          months,
          (a, b) => b.compareTo(a),
        );
      });
      return Response.ok(jsonEncode(sortedNetWorthDetail), headers: _headers);
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  Future<Response> getCategoryCurrentHandler(
      Request request, String userId, String x) async {
    try {
      List<Transaction> transactions =
          await transactionStorage.fetchWhere('userId', userId);
      DateTime now = DateTime.now();
      List<Transaction> currentMonthTransactions =
          transactions.where((transaction) {
        return transaction.date.year == 2024 && transaction.date.month == 12;
      }).toList();

      // Group transactions by category and sum the amounts
      Map<String, double> categorySpending = {};
      for (var transaction in currentMonthTransactions) {
        if (transaction.type == 'Outcome') {
          categorySpending[transaction.category] =
              (categorySpending[transaction.category] ?? 0) +
                  transaction.amount;
        }
      }

      // Sort categories by amount in descending order
      var sortedCategories = categorySpending.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      sortedCategories;
      Map<String, Map<String, dynamic>> result = {};

      // Group transactions by category and calculate monthly averages
      Map<String, Map<String, List<double>>> categoryMonthlySpending = {};
      for (var transaction in transactions) {
        if (transaction.type == 'Outcome') {
          String category = transaction.category;
          String month =
              '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';

          categoryMonthlySpending[category] ??= {};
          categoryMonthlySpending[category]![month] ??= [];
          categoryMonthlySpending[category]![month]!.add(transaction.amount);
        }
      }

      Map<String, double> categoryAverageSpending = {};
      categoryMonthlySpending.forEach((category, monthlySpending) {
        double total = 0;
        int count = 0;
        monthlySpending.forEach((month, amounts) {
          total += amounts.reduce((a, b) => a + b);
          count += amounts.length;
        });
        categoryAverageSpending[category] = (total / count).toDouble();
      });

      if (x.toLowerCase() == 'all') {
        // Add all categories without "Other categories"
        for (var entry in sortedCategories) {
          var category = await categoryStorage.fetchById(entry.key);
          if (category != null) {
            result[entry.key] = {
              'amount': entry.value,
              'average': categoryAverageSpending[entry.key],
              'name': category.name,
              'icon': category.icon,
              'color': category.color,
            };
          }
        }
      } else {
        int numberOfCategory = int.parse(x);
        var topCategories = sortedCategories.take(numberOfCategory).toList();
        var remainingCategories =
            sortedCategories.skip(numberOfCategory).toList();

        double otherCategoriesAmount =
            remainingCategories.fold(0.0, (sum, entry) => sum + entry.value);

        // Alternative calculation for otherCategoriesAverage
        double otherCategoriesAverage = 0.0;
        if (remainingCategories.isNotEmpty) {
          double totalAverage = 0.0;
          int totalCount = 0;
          for (var entry in remainingCategories) {
            var average = categoryAverageSpending[entry.key] ?? 0.0;
            totalAverage += average;
            totalCount++;
          }
          otherCategoriesAverage = totalAverage / totalCount;
        }

        // Add top categories to the result
        for (var entry in topCategories) {
          var category = await categoryStorage.fetchById(entry.key);
          if (category != null) {
            result[entry.key] = {
              'amount': entry.value,
              'average': categoryAverageSpending[entry.key],
              'name': category.name,
              'icon': category.icon,
              'color': category.color,
            };
          }
        }

        // Add "Other categories" to the result
        if (remainingCategories.isNotEmpty) {
          result['otherCategories'] = {
            'amount': otherCategoriesAmount,
            'average': otherCategoriesAverage,
            'name': 'Other categories',
            'icon': '🗂',
            'color': '#FFA500',
          };
        }
      }

      return Response.ok(jsonEncode(result), headers: _headers);
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

// return top all spending category current month like {total: {each category},detail{year :{month :{categoryid:{ amount, name, icon, color}, category: { amount, name, icon, color}}}}}
  Future<Response> getCategoryDetailHandler(
      Request request, String userId) async {
    try {
      User? user = await userStorage.fetchById(userId);
      if (user == null) {
        return Response.notFound('User not found');
      }
      List<Transaction> transactions =
          await transactionStorage.fetchWhere('userId', userId);

      // Group transactions by year, month, and category
      Map<String, Map<String, Map<String, Map<String, dynamic>>>>
          categoryDetail = {};
      Map<String, Map<String, double>> totalSpendingByYear = {};

      for (var transaction in transactions) {
        String year = transaction.date.year.toString();
        String month = transaction.date.month.toString().padLeft(2, '0');

        categoryDetail[year] ??= {};
        categoryDetail[year]![month] ??= {};
        categoryDetail[year]![month]![transaction.category] ??= {
          'amount': 0,
          'name': '',
          'icon': '',
          'color': '',
        };
        categoryDetail[year]![month]![transaction.category]!['amount'] =
            categoryDetail[year]![month]![transaction.category]!['amount'] +
                transaction.amount;

        // Calculate total spending for each category by year
        totalSpendingByYear[year] ??= {};
        totalSpendingByYear[year]![transaction.category] =
            (totalSpendingByYear[year]![transaction.category] ?? 0) +
                transaction.amount;
      }

      // Fetch category details
      for (var year in categoryDetail.keys) {
        for (var month in categoryDetail[year]!.keys) {
          for (var categoryId in categoryDetail[year]![month]!.keys) {
            var category = await categoryStorage.fetchById(categoryId);
            if (category != null) {
              categoryDetail[year]![month]![categoryId]!['name'] =
                  category.name;
              categoryDetail[year]![month]![categoryId]!['icon'] =
                  category.icon;
              categoryDetail[year]![month]![categoryId]!['color'] =
                  category.color;
            }
          }
        }
      } // Sort the categoryDetail by year and month in descending order
      var sortedCategoryDetail = SplayTreeMap<String,
          Map<String, Map<String, Map<String, dynamic>>>>.from(
        categoryDetail,
        (a, b) => b.compareTo(a),
      );

      sortedCategoryDetail.forEach((year, months) {
        sortedCategoryDetail[year] =
            SplayTreeMap<String, Map<String, Map<String, dynamic>>>.from(
          months,
          (a, b) => b.compareTo(a),
        );

        // Sort categories by amount in descending order within each month
        sortedCategoryDetail[year]!.forEach((month, categories) {
          var sortedCategories =
              SplayTreeMap<String, Map<String, dynamic>>.from(
            categories,
            (a, b) =>
                categories[b]!['amount'].compareTo(categories[a]!['amount']),
          );
          sortedCategoryDetail[year]![month] = sortedCategories;
        });
      });

      // Fetch total category details by year
      Map<String, Map<String, Map<String, dynamic>>>
          totalCategoryDetailsByYear = {};
      for (var year in totalSpendingByYear.keys) {
        totalCategoryDetailsByYear[year] = {};
        for (var categoryId in totalSpendingByYear[year]!.keys) {
          var category = await categoryStorage.fetchById(categoryId);
          if (category != null) {
            totalCategoryDetailsByYear[year]![categoryId] = {
              'amount': totalSpendingByYear[year]![categoryId],
              'name': category.name,
              'icon': category.icon,
              'color': category.color,
            };
          }
        }
      }

      // Combine total and detail into the final result
      Map<String, dynamic> result = {
        'total': totalCategoryDetailsByYear,
        'detail': sortedCategoryDetail,
      };

      return Response.ok(jsonEncode(result), headers: _headers);
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  Future<Response> getspendingPlantCurrentHandler(
      Request request, String userId) async {
    try {
      // get income that month
      // get spending plan ratio
      // income for each spending plan
      // icomesaving = icome * ratio / 100
      // outcome = sum of transaction amount for each saving plan that month
      // return (e.g {saving: amount, detail{icomesaving, outcomesaving, remain}, needs: amount, detail{income, outcome, remain}, wants: amount, detail{income, outcome, remain}})
      User? user = await userStorage.fetchById(userId);
      if (user == null) {
        return Response.notFound('User not found');
      }
      List<Transaction> transactions =
          await transactionStorage.fetchWhere('userId', userId);
      DateTime now = DateTime.now();
      List<Transaction> currentMonthTransactions =
          transactions.where((transaction) {
        return transaction.date.year == 2024 && transaction.date.month == 12;
      }).toList();
      // Calculate total income for the current month
      double totalIncome = currentMonthTransactions
          .where((transaction) => transaction.type == 'Income')
          .fold(0.0, (sum, transaction) => sum + transaction.amount);

      // Fetch the user's spending plan
      SpendingPlan? spendingPlan = await spendingPlanStorage.fetchById(userId);
      if (spendingPlan == null) {
        return Response.notFound('Spending plan not found for userId: $userId');
      }
      // Calculate income, outcome, and remaining amount for each spending plan category
      Map<String, Map<String, dynamic>> result = {};
      spendingPlan.categories.forEach((category, details) {
        double ratio = details['ratio']!;
        double incomeForCategory = totalIncome * ratio / 100;

        double outcomeForCategory = currentMonthTransactions
            .where((transaction) =>
                transaction.type == 'Outcome' &&
                transaction.spendingPlan == category)
            .fold(0.0, (sum, transaction) => sum + transaction.amount);

        double remainingForCategory = incomeForCategory + outcomeForCategory;

        result[category] = {
          'amount': details['amount'],
          'ratio': ratio,
          'detail': {
            'Income': incomeForCategory,
            'Outcome': outcomeForCategory,
            'Remain': remainingForCategory,
          }
        };
      });
      return Response.ok(jsonEncode(result), headers: _headers);
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  Future<Response> getspendingPlantDetailHandler(
      Request request, String userId, String spendingPlan) async {
    try {
      User? user = await userStorage.fetchById(userId);
      if (user == null) {
        return Response.notFound('User not found');
      }

      List<Transaction> transactions =
          await transactionStorage.fetchWhere('userId', userId);

      SpendingPlan? userSpendingPlan =
          await spendingPlanStorage.fetchById(userId);
      if (userSpendingPlan == null) {
        return Response.notFound('Spending plan not found for userId: $userId');
      }

      // Lấy `spendingPlan` mặc định nếu là chuỗi rỗng
      if (spendingPlan.isEmpty) {
        spendingPlan = userSpendingPlan.categories.keys.first;
      }

      double ratio = userSpendingPlan.categories[spendingPlan]?['ratio'] ?? 0;

      // Nhóm giao dịch theo năm và tháng
      Map<String, Map<String, Map<String, double>>> result = {};

      for (var transaction in transactions) {
        String year = transaction.date.year.toString();
        String month = transaction.date.month.toString().padLeft(2, '0');

        result[year] ??= {};
        result[year]![month] ??= {'Income': 0, 'Outcome': 0, 'Remain': 0};

        if (transaction.type == 'Income') {
          double incomeForSpendingPlan = transaction.amount * ratio / 100;
          result[year]![month]!['Income'] =
              result[year]![month]!['Income']! + incomeForSpendingPlan;
        } else if (transaction.type == 'Outcome' &&
            transaction.spendingPlan == spendingPlan) {
          result[year]![month]!['Outcome'] =
              result[year]![month]!['Outcome']! + transaction.amount;
        }

        result[year]![month]!['Remain'] = result[year]![month]!['Income']! +
            result[year]![month]!['Outcome']!;
      }

      // Sắp xếp kết quả
      var sortedResult =
          SplayTreeMap<String, Map<String, Map<String, double>>>.from(
        result,
        (a, b) => b.compareTo(a),
      );

      sortedResult.forEach((year, months) {
        sortedResult[year] = SplayTreeMap<String, Map<String, double>>.from(
          months,
          (a, b) => b.compareTo(a),
        );
      });

      return Response.ok(jsonEncode(sortedResult), headers: _headers);
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }
}
