import 'package:flutter/material.dart';
import 'package:front_end/views/login/SignInPage.dart';
import '../../viewModel/UserViewModel.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/primary_button.dart';
import 'package:front_end/common_widget/round_textfield.dart';
import 'package:front_end/common_widget/secondary_boutton.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late SignUpViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SignUpViewModel();
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
                "Create Your Account",
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
              const SizedBox(height: 10),
              RoundTextField(
                title: "Re-enter Password",
                controller: _viewModel.reEnterPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              PrimaryButton(
                title: "Sign up",
                onPressed: () => _viewModel.validateAndSubmit(context),
              ),
              const SizedBox(height: 40),
              Text(
                "Already have an account?",
                style: TextStyle(color: TColor.white, fontSize: 11),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                title: "Sign in",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignInPage(),
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
