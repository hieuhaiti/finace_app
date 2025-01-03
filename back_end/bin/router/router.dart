import 'package:shelf_router/shelf_router.dart';
import '../service/user_service.dart';
import '../service/transactions_service.dart';
import '../service/category_service.dart';
import '../service/spending_plan_service.dart';
import '../service/general_service.dart';
import '../service/dash_board_service.dart';

final generalService = GeneralService();
final userService = UserService();
final transactionsService = TransactionsService();
final categoryService = CategoryService();
final spendingPlanService = SpendingPlanService();
final dashBoardService = DashBoardService();

final router = Router(notFoundHandler: generalService.notFoundHandler)
  // general routes
  // Root endpoint
  ..get('/', generalService.rootHandler)

  // User Routes
  ..post('/api/v1/users/signup', userService.signUpHandler)
  ..post('/api/v1/users/signin', userService.signInHandler)
  ..get('/api/v1/users/<userId>', userService.getUserByIdHandler)
  ..get(
      '/api/v1/users/username/<username>', userService.getUserByUsernameHandler)
  ..put('/api/v1/users/<userId>', userService.updateUserHandler)
  ..delete('/api/v1/users/<userId>', userService.deleteUserHandler)

  // Transactions Routes
  ..get('/api/v1/transactions/<userId>',
      transactionsService.getAllTransactionsHandlerByUserId)
  ..get('/api/v1/transaction/<transactionId>',
      transactionsService.getAllTransactionsHandlerByTransactionId)
  ..post('/api/v1/transaction', transactionsService.createTransactionHandler)
  ..put('/api/v1/transaction/<transactionId>',
      transactionsService.updateTransactionHandler)
  ..delete('/api/v1/transaction/<transactionId>',
      transactionsService.deleteTransactionHandler)
  ..get('/api/v1/transactions/<userId>/aggregate/<key>',
      transactionsService.getTransactionsAggregatedBy)
  ..get('/api/v1/transactions/<userId>/aggregate/<key>/<month>/<year>',
      transactionsService.getTransactionsAggregatedByMonthYear)

  // Spending Plan Routes
  ..get('/api/v1/spending-plans/<userId>',
      spendingPlanService.getSpendingPlansHandler)
  ..post('/api/v1/spending-plans/<userId>',
      spendingPlanService.updateSpendingPlanHandler)
  ..delete('/api/v1/spending-plans/<userId>/<spentPlan>',
      spendingPlanService.deleteCategoryHandler)

  // Category Routes
  ..get('/api/v1/categories/<userId>', categoryService.getCategoriesHandler)
  ..get('/api/v1/categories/details/<categoryId>',
      categoryService.getCategoriesDetailHandler)
  ..post('/api/v1/categories', categoryService.saveCategoryHandler)
  ..put(
      '/api/v1/categories/<categoryId>', categoryService.updateCategoryHandler)
  ..delete(
      '/api/v1/categories/<categoryId>', categoryService.deleteCategoryHandler)

// dashBoard
  ..get('/api/v1/dashBoard/<userId>/networth/current',
      dashBoardService.getNetWorthCurrentHandler)
  ..get('/api/v1/dashBoard/<userId>/networth/detail',
      dashBoardService.getNetWorthDetailHandler)
  ..get('/api/v1/dashBoard/<userId>/category/current/<numberOfCategory>',
      dashBoardService.getCategoryCurrentHandler)
  ..get('/api/v1/dashBoard/<userId>/category/detail',
      dashBoardService.getCategoryDetailHandler)
  ..get('/api/v1/dashBoard/<userId>/spending-plant/current',
      dashBoardService.getspendingPlantCurrentHandler)
  ..get('/api/v1/dashBoard/<userId>/spending-plant/detail/<spentPlan>',
      dashBoardService.getspendingPlantDetailHandler)
//spending plan
  ..get('/api/v1/spending-plans/<userId>/<spentPlan>/<type>',
      spendingPlanService.getSpendingPlansDetailHandler);
