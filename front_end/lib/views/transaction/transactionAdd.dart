import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/viewModel/CategoryViewModel.dart';
import 'package:front_end/models/category.dart' as custom_category;
import 'package:front_end/viewModel/SpendingPlanViewModel.dart';
import 'package:front_end/viewModel/TransactionViewModel.dart';
import 'package:intl/intl.dart';
import 'package:front_end/models/transaction.dart';

class AddTransactionModal extends StatefulWidget {
  final String userId;
  const AddTransactionModal({
    super.key,
    required this.userId,
  });

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  final TextEditingController _transactionNameController =
      TextEditingController();
  final TextEditingController _transactionAmountController =
      TextEditingController();
  late TabController _tabTypeController;
  TabController? _tabPlanController;

  List<custom_category.Category>? categories;
  Map<String, double> spendingPlan = {};
  bool isSelectingCategory = false;
  DateTime selectedDate = DateTime.now();
  String transactionType = "Outcome";
  String? spendingPlanSelected;
  String selectedCategoryId = "1735552016922";
  late Transaction transaction;

  @override
  void initState() {
    super.initState();
    _tabTypeController = TabController(length: 2, vsync: this);
    _fetchCategoriesData();
    _fetchSpendingPlanData();
  }

  Future<void> _fetchSpendingPlanData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data =
          await SpendingPlanViewModel().fetchSpendingPlan(widget.userId);

      setState(() {
        spendingPlan = data.categories.map(
          (key, value) => MapEntry(key, value.amount),
        );

        spendingPlanSelected = spendingPlan.keys.first;
        _tabPlanController = TabController(
          length: spendingPlan.keys.length,
          vsync: this,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCategoriesData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await CategoryViewModel().fetchCategories(widget.userId);

      setState(() {
        categories = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      confirmText: 'Confirm',
      cancelText: 'Cancel',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TColor.secondary, // Header background color
              onPrimary: TColor.primaryText, // Header text color
              surface: TColor.gray70, // Dialog background color
              onSurface: TColor.primaryText, // Text color
            ),
            dialogBackgroundColor:
                TColor.gray70, // Background color for the dialog
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: TColor.secondary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: TColor.secondary,
                onPrimary: TColor.primaryText,
                surface: TColor.gray60,
                onSurface: TColor.primaryText,
              ),
              dialogBackgroundColor: TColor.gray60,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      } else {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            0,
            0,
          );
        });
      }
    }
  }

  Future<void> _sendData(Transaction transaction) async {
    await TransactionViewModel().addTransaction(transaction);
  }

  @override
  void dispose() {
    _tabTypeController.dispose();
    _tabPlanController?.dispose();
    _transactionNameController.dispose();
    _transactionAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return FractionallySizedBox(
          heightFactor: 0.6,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: Container(
                  decoration: BoxDecoration(
                    color: TColor.gray80,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Thanh kéo trên cùng
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 20),
                              height: 5,
                              width: 50,
                              decoration: BoxDecoration(
                                color: TColor.gray20,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      )))));
    }

    if (_error != null) {
      return FractionallySizedBox(
          heightFactor: 0.65,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: Container(
                  decoration: BoxDecoration(
                    color: TColor.gray80,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Thanh kéo trên cùng
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 20),
                              height: 5,
                              width: 50,
                              decoration: BoxDecoration(
                                color: TColor.gray20,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Error: _error",
                              style: TextStyle(color: TColor.primaryText),
                            ),
                          ),
                        ],
                      )))));
    }

    if (categories == null || categories!.isEmpty || spendingPlan.isEmpty) {
      return FractionallySizedBox(
          heightFactor: 0.65,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: Container(
                  decoration: BoxDecoration(
                    color: TColor.gray80,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Thanh kéo trên cùng
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 20),
                              height: 5,
                              width: 50,
                              decoration: BoxDecoration(
                                color: TColor.gray20,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "No data available.",
                              style: TextStyle(color: TColor.primaryText),
                            ),
                          ),
                        ],
                      )))));
    }
    return FractionallySizedBox(
      heightFactor: 0.65,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.5),
        child: Container(
          decoration: BoxDecoration(
            color: TColor.gray80,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thanh kéo trên cùng
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: TColor.gray20,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // TabBar type
                Container(
                  decoration: BoxDecoration(
                    color: TColor.gray30,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: TabBar(
                      controller: _tabTypeController,
                      indicator: BoxDecoration(
                        color: TColor.blue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      labelColor: TColor.primaryText,
                      unselectedLabelColor: TColor.gray10,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      onTap: (index) {
                        setState(() {
                          transactionType = index == 0 ? "Outcome" : "Income";
                        });
                      },
                      tabs: const [
                        Tab(text: "Outcome"),
                        Tab(text: "Income"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // TabBar spending plan
                if (transactionType == "Outcome")
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: TColor.gray30,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: TabBar(
                            controller: _tabPlanController,
                            indicator: BoxDecoration(
                              color: TColor.blue,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            labelColor: TColor.primaryText,
                            unselectedLabelColor: TColor.gray10,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            onTap: (index) {
                              setState(() {
                                spendingPlanSelected =
                                    spendingPlan.keys.elementAt(index);
                              });
                            },
                            tabs: spendingPlan.keys.map((key) {
                              return Tab(text: key);
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Card
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height / 9,
                          width: MediaQuery.of(context).size.width / 2,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double cardWidth = constraints.maxWidth;
                              final double cardHeight = constraints.maxHeight;
                              final double? amount =
                                  spendingPlan[spendingPlanSelected];

                              return Container(
                                width: cardWidth,
                                height: cardHeight,
                                decoration: BoxDecoration(
                                  color: (amount ?? 0) >= 0
                                      ? TColor.greenWithOpacity
                                      : TColor.redWithOpacity,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 3.0, left: 18.0),
                                        child: Text(
                                          spendingPlanSelected != null
                                              ? spendingPlanSelected!
                                              : "No data",
                                          style: TextStyle(
                                            color: TColor.secondaryText,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: Text(
                                        amount != null
                                            ? amount.toStringAsFixed(2)
                                            : "No data",
                                        style: TextStyle(
                                          color: TColor.primaryText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
                // Hiển thị ngày và các nút
                GestureDetector(
                  onTap: () => _selectDateTime(context),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _transactionNameController,
                        onSubmitted: (value) {
                          setState(() {});
                        },
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "Transaction name",
                          hintStyle: TextStyle(
                            color: TColor.gray40,
                          ),
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _transactionAmountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() {});
                        },
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "\$0.00",
                          hintStyle: TextStyle(
                            color: TColor.gray40,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                // Category Selection
                const SizedBox(height: 10),
                if (isSelectingCategory)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: categories!.map((category) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryId = category.id;
                              isSelectingCategory = false;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: hexToColor(category.color).withAlpha(100),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  category.icon,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    color: TColor.primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (!isSelectingCategory)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelectingCategory = !isSelectingCategory;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: categories != null
                              ? hexToColor(
                                  categories!
                                      .firstWhere((category) =>
                                          category.id == selectedCategoryId)
                                      .color,
                                ).withAlpha(100)
                              : TColor.gray30,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              categories!
                                  .firstWhere((category) =>
                                      category.id == selectedCategoryId)
                                  .icon,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              categories!
                                  .firstWhere((category) =>
                                      category.id == selectedCategoryId)
                                  .name,
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Nút Add
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_transactionNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a transaction name."),
                          ),
                        );
                        return;
                      }
                      if (_transactionAmountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a transaction amount."),
                          ),
                        );
                        return;
                      }

                      _sendData(Transaction(
                        userId: widget.userId,
                        name: _transactionNameController.text,
                        type: transactionType,
                        spendingPlan: transactionType == "Outcome"
                            ? spendingPlanSelected
                            : null,
                        category: selectedCategoryId,
                        amount: transactionType == "Outcome"
                            ? -double.parse(_transactionAmountController.text)
                            : double.parse(_transactionAmountController.text),
                        date: selectedDate,
                      ));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      "Add",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 7) buffer.write('ff'); // Thêm alpha nếu thiếu
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
