// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/primary_button.dart';
import 'package:front_end/common_widget/round_textfield.dart';
import 'package:front_end/viewModel/UserViewModel.dart';

class UserPage extends StatefulWidget {
  final String userId;

  const UserPage({
    super.key,
    required this.userId,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late UpdateUserViewModel _viewModel;
  late Future<String> userName;
  @override
  void initState() {
    super.initState();
    _viewModel = UpdateUserViewModel(userId: widget.userId);
    userName = _viewModel.getUsername(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TColor.gray80,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 20),
            Text("Settings",
                style: TextStyle(color: TColor.white, fontSize: 20)),
            const SizedBox(height: 20),
            Image.asset("assets/img/u1.png", width: 100, height: 100),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: userName,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: TColor.white, fontSize: 20),
                  );
                } else {
                  return Text(
                    snapshot.data ?? '',
                    style: TextStyle(color: TColor.white, fontSize: 20),
                  );
                }
              },
            ),
            const SizedBox(height: 25),
            RoundTextField(
              title: "Password",
              controller: _viewModel.newPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            RoundTextField(
              title: "re-enter Password",
              controller: _viewModel.reEnterPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 35),
            PrimaryButton(
              title: "Comfirm",
              onPressed: () {
                _viewModel.validateAndSubmit(context);
              },
            ),
          ]),
        ));
  }
}
