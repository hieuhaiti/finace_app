// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/primary_button.dart';
import 'package:front_end/common_widget/round_textfield.dart';
import 'package:front_end/common_widget/secondary_boutton.dart';
import 'package:front_end/views/login/SignUpPage.dart';

import '../../viewModel/UserViewModel.dart';

class SignInPage extends StatefulWidget {
  final String? username;
  final String? password;
  SignInPage({
    super.key,
    this.username,
    this.password,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late SignInViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SignInViewModel();
    // Pre-fill the text fields with the provided username and password
    if (widget.username != null) {
      _viewModel.usernameController.text = widget.username!;
    }
    if (widget.password != null) {
      _viewModel.passwordController.text = widget.password!;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.gray80,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/img/app_logo.png",
                width: size.width * 0.5,
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome Back!",
                style: TextStyle(color: TColor.white, fontSize: 20),
              ),
              const SizedBox(height: 30),
              RoundTextField(
                title: "Username",
                controller: _viewModel.usernameController,
              ),
              const SizedBox(height: 10),
              RoundTextField(
                title: "Password",
                controller: _viewModel.passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              PrimaryButton(
                title: "Sign in",
                onPressed: () => _viewModel.validateAndSubmit(context),
              ),
              const SizedBox(height: 40),
              Text(
                "Don't have an account?",
                style: TextStyle(color: TColor.white, fontSize: 11),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                title: "Sign up",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
