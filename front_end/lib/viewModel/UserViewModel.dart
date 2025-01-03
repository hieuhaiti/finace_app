import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_end/views/login/SignInPage.dart';
import 'package:front_end/views/main_tab_view.dart';
import 'package:http/http.dart' as http;

// Abstract class UserViewModel
abstract class UserViewModel {
  String baseURL = "http://${dotenv.env['ip']}:${dotenv.env['port']}/api/v1";
  String path = "users";
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Validate inputs for username and password
  String? validateInputs() {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      return "Username cannot be empty.";
    }
    if (password.isEmpty) {
      return "Password cannot be empty.";
    }
    return null; // No errors
  }

  // Abstract method for validate and submit
  Future<void> validateAndSubmit(BuildContext context);

  // Method to show a snackbar message
  void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Get userId by username
  Future<String> getUserId(String username) async {
    final response = await http.get(
      Uri.parse('$baseURL/$path/username/$username'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Failed to load user');
    }
  }

  // Get userId by userID
  Future<String> getUsername(String userID) async {
    final response = await http.get(
      Uri.parse('$baseURL/$path/$userID'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['username'];
    } else {
      throw Exception('Failed to load user');
    }
  }

  // Dispose controllers
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}

// SignUpViewModel class
class SignUpViewModel extends UserViewModel {
  final TextEditingController reEnterPasswordController =
      TextEditingController();

  @override
  String? validateInputs() {
    final baseValidation = super.validateInputs();
    if (baseValidation != null) {
      return baseValidation;
    }

    final password = passwordController.text;
    final reEnterPassword = reEnterPasswordController.text;

    if (password != reEnterPassword) {
      return "Passwords do not match.";
    }
    return null; // No errors
  }

  @override
  Future<void> validateAndSubmit(BuildContext context) async {
    final errorMessage = validateInputs();
    if (errorMessage != null) {
      if (context.mounted) {
        showSnackBar(context, errorMessage, isError: true);
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseURL/$path/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text
        }),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          showSnackBar(context, "User registered successfully!");
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInPage(
              username: usernameController.text,
              password: passwordController.text,
            ),
          ),
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        if (context.mounted) {
          showSnackBar(context, "Error: ${errorResponse['error']}",
              isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, "An error occurred: $e", isError: true);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    reEnterPasswordController.dispose();
  }
}

// SignInViewModel class
class SignInViewModel extends UserViewModel {
  @override
  Future<void> validateAndSubmit(BuildContext context) async {
    final errorMessage = validateInputs();
    if (errorMessage != null) {
      if (context.mounted) {
        showSnackBar(context, errorMessage, isError: true);
      }
      return;
    }

    try {
      final url = Uri.parse('$baseURL/$path/signin');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text
        }),
      );

      if (response.statusCode == 200) {
        final userId = await getUserId(usernameController.text);
        if (context.mounted) {
          showSnackBar(
              context, "Login successful! Welcome ${usernameController.text}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainTabView(
                userId: userId,
              ),
            ),
          );
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        if (context.mounted) {
          showSnackBar(context, "Error: ${errorResponse['error']}",
              isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, "An error occurred: $e", isError: true);
      }
    }
  }
}

class UpdateUserViewModel extends UserViewModel {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController reEnterPasswordController =
      TextEditingController();
  final String userId;

  UpdateUserViewModel({required this.userId});

  @override
  String? validateInputs() {
    final password = newPasswordController.text;
    final reEnterPassword = reEnterPasswordController.text;
    if (password.isEmpty) {
      return "Passwords cannot be empty.";
    }
    if (reEnterPassword.isEmpty) {
      return "Re-enter password cannot be empty.";
    }
    if (password != reEnterPassword) {
      return "Passwords do not match.";
    }
    return null; // No errors
  }

  @override
  Future<void> validateAndSubmit(BuildContext context) async {
    final errorMessage = validateInputs();
    if (errorMessage != null) {
      if (context.mounted) {
        showSnackBar(context, errorMessage, isError: true);
      }
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseURL/$path/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          showSnackBar(context, "Password updated successfully!");
        }
        Navigator.pop(context);
      } else {
        final errorResponse = jsonDecode(response.body);
        if (context.mounted) {
          showSnackBar(context, "Error: ${errorResponse['error']}",
              isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, "An error occurred: $e", isError: true);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    newPasswordController.dispose();
    reEnterPasswordController.dispose();
  }
}
