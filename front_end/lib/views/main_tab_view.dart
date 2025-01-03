import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/views/category/categoryPage.dart';
import 'package:front_end/views/dashboard/dashboardPage.dart';
import 'package:front_end/views/spending%20plan/spendingPlanPage.dart';
import 'package:front_end/views/transaction/transactionAdd.dart';
import 'package:front_end/views/user/userPage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MainTabView extends StatefulWidget {
  final String userId;
  const MainTabView({
    super.key,
    required this.userId,
  });

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectedIndex = 0;
  PageStorageBucket bucket = PageStorageBucket();
  late Widget currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = DashboardPage(
      userId: widget.userId,
    );
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
      switch (index) {
        case 0:
          currentPage = DashboardPage(userId: widget.userId);
          break;
        case 1:
          currentPage = SpendingplanPage(userId: widget.userId);
          break;
        case 2:
          currentPage = CategoryPage(userId: widget.userId);
          break;
        case 3:
          currentPage = UserPage(userId: widget.userId);
          break;
        default:
          currentPage = DashboardPage(userId: widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: TColor.gray,
      body: Stack(
        children: [
          PageStorage(bucket: bucket, child: currentPage),
          Column(
            children: [
              const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Stack(
                      children: [
                        Image.asset("assets/img/bottom_bar_bg.png"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                                onPressed: () => onTabTapped(0),
                                icon: Image.asset(
                                  "assets/img/home.png",
                                  height: 20,
                                  width: 20,
                                  color: selectedIndex == 0
                                      ? TColor.white
                                      : TColor.gray30,
                                )),
                            IconButton(
                                onPressed: () => onTabTapped(1),
                                icon: Image.asset(
                                  "assets/img/creditcards.png",
                                  height: 20,
                                  width: 20,
                                  color: selectedIndex == 1
                                      ? TColor.white
                                      : TColor.gray30,
                                )),
                            const SizedBox(width: 50, height: 50),
                            IconButton(
                                onPressed: () => onTabTapped(2),
                                icon: Image.asset(
                                  "assets/img/category.png",
                                  height: 20,
                                  width: 20,
                                  color: selectedIndex == 2
                                      ? TColor.white
                                      : TColor.gray30,
                                )),
                            IconButton(
                                onPressed: () => onTabTapped(3),
                                icon: Image.asset(
                                  "assets/img/settings.png",
                                  height: 20,
                                  width: 20,
                                  color: selectedIndex == 3
                                      ? TColor.white
                                      : TColor.gray30,
                                )),
                          ],
                        )
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        showMaterialModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: AddTransactionModal(
                                      userId: widget.userId),
                                ));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        child: Image.asset(
                          "assets/img/center_btn.png",
                          width: 55,
                          height: 55,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
