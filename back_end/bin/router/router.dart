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
  ..get('/', generalService.rootHandler) // Function: Root endpoint, Return: Response

  // User Routes
  ..post('/api/v1/users/signup', userService.signUpHandler) // Function: Sign up a new user, Return: Response
  ..post('/api/v1/users/signin', userService.signInHandler) // Function: Sign in an existing user, Return: Response
  ..get('/api/v1/users/<userId>', userService.getUserByIdHandler) // Function: Get user by ID, Return: Response
  ..get('/api/v1/users/username/<username>', userService.getUserByUsernameHandler) // Function: Get user by username, Return: Response
  ..put('/api/v1/users/<userId>', userService.updateUserHandler) // Function: Update user information, Return: Response
  ..delete('/api/v1/users/<userId>', userService.deleteUserHandler) // Function: Delete user, Return: Response

  // Transactions Routes
  ..get('/api/v1/transactions/<userId>', transactionsService.getAllTransactionsHandler) // Function: Get all transactions for a user, Return: Response
  ..post('/api/v1/transactions', transactionsService.createTransactionHandler) // Function: Create a new transaction, Return: Response
  ..put('/api/v1/transactions/<transactionId>', transactionsService.updateTransactionHandler) // Function: Update a transaction, Return: Response
  ..delete('/api/v1/transactions/<transactionId>', transactionsService.deleteTransactionHandler) // Function: Delete a transaction, Return: Response
  ..get('/api/v1/transactions/<userId>/aggregate/<key>', transactionsService.getTransactionsAggregatedBy) // Function: Aggregate transactions by a given key, Return: Response

  // Spending Plan Routes
  ..get('/api/v1/spending-plans/<userId>', spendingPlanService.getSpendingPlansHandler) // Function: Get spending plans for a user, Return: Response
  ..post('/api/v1/spending-plans/<userId>', spendingPlanService.updateSpendingPlanHandler) // Function: Update spending plan for a user, Return: Response
  ..delete('/api/v1/spending-plans/<userId>/<category>', spendingPlanService.deleteCategoryHandler) // Function: Delete a category in spending plan, Return: Response

  // Category Routes
  ..get('/api/v1/categories/<userId>', categoryService.getCategoriesHandler) // Function: Get all categories for a user, Return: Response
  ..post('/api/v1/categories', categoryService.saveCategoryHandler) // Function: Save a new category, Return: Response
  ..get('/api/v1/categories/details/<categoryId>', categoryService.getCategoriesDetailHandler) // Function: Get category details by ID, Return: Response
  ..put('/api/v1/categories/<categoryId>', categoryService.updateCategoryHandler) // Function: Update a category, Return: Response
  ..delete('/api/v1/categories/<categoryId>', categoryService.deleteCategoryHandler); // Function: Delete a category, Return: Response