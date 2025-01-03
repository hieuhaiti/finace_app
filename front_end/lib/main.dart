import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/views/login/SignInPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  _FinanceAppState createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  late int currentMonth;
  late int currentYear;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: "Inter",
            colorScheme: ColorScheme.fromSeed(
              seedColor: TColor.primary,
              primary: TColor.primary,
              secondary: TColor.primary,
              surface: TColor.gray80,
              primaryContainer: TColor.gray60,
            ),
            useMaterial3: false),
        home: SignInPage());
  }
}
