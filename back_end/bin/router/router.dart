import 'package:shelf_router/shelf_router.dart';
import '../service/user_service.dart';
import '../service/transactions_service.dart';
import '../service/category_service.dart';
import '../service/spending_plan_service.dart';
import '../service/general_service.dart';

final generalService = GeneralService();
final userService = UserService();
final transactionsService = TransactionsService();
final categoryService = CategoryService();
final spendingPlanService = SpendingPlanService();

final router = Router(notFoundHandler: generalService.notFoundHandler)
  // Root endpoint
  ..get('/', generalService.rootHandler)

  // User Routes
  ..post('/api/v1/users/signup', userService.signUpHandler)
  ..post('/api/v1/users/signin', userService.signInHandler)
  ..get('/api/v1/users/<userId>', userService.getUserByIdHandler)
  ..get('/api/v1/users/username/<username>', userService.getUserByUsernameHandler)
  ..put('/api/v1/users/<userId>', userService.updateUserHandler)
  ..delete('/api/v1/users/<userId>', userService.deleteUserHandler)

  // Transactions Routes
  ..get('/api/v1/transactions/<userId>', transactionsService.getAllTransactionsHandler)
  ..post('/api/v1/transactions', transactionsService.createTransactionHandler)
  ..put('/api/v1/transactions/<transactionId>', transactionsService.updateTransactionHandler)
  ..delete('/api/v1/transactions/<transactionId>', transactionsService.deleteTransactionHandler)
  ..get('/api/v1/transactions/<userId>/aggregate/<key>', transactionsService.getTransactionsAggregatedBy)

  // Spending Plan Routes
  ..get('/api/v1/spending-plans/<userId>', spendingPlanService.getSpendingPlansHandler)
  ..post('/api/v1/spending-plans/<userId>', spendingPlanService.updateSpendingPlanHandler)
  ..delete('/api/v1/spending-plans/<userId>/<category>', spendingPlanService.deleteCategoryHandler)

  // Category Routes
  ..get('/api/v1/categories/<userId>', categoryService.getCategoriesHandler)
  ..post('/api/v1/categories', categoryService.saveCategoryHandler)
  ..get('/api/v1/categories/details/<categoryId>', categoryService.getCategoriesDetailHandler)
  ..put('/api/v1/categories/<categoryId>', categoryService.updateCategoryHandler)
  ..delete('/api/v1/categories/<categoryId>', categoryService.deleteCategoryHandler);
