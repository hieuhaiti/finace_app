import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/viewModel/CategoryViewModel.dart';
import 'package:front_end/models/category.dart' as custom_category;
import 'package:intl/intl.dart';

class ManageTransactionModal extends StatefulWidget {
  final String userId;
  const ManageTransactionModal({
    super.key,
    required this.userId,
  });

  @override
  State<ManageTransactionModal> createState() => _ManageTransactionModalState();
}

class _ManageTransactionModalState extends State<ManageTransactionModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();
  String transactionType = "";
  String selectedCategoryId = "1735552016922";
  bool isSelectingCategory = false;
  final TextEditingController _transactionNameController =
      TextEditingController();
  final TextEditingController _transactionAmountController =
      TextEditingController();
  List<custom_category.Category>? categories;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
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

  @override
  void dispose() {
    _tabController.dispose();
    _transactionNameController.dispose();
    _transactionAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return FractionallySizedBox(
        heightFactor: 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.5),
          child: Container(
            decoration: BoxDecoration(
              color: TColor.gray80,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    if (_error != null) {
      return FractionallySizedBox(
        heightFactor: 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.5),
          child: Container(
            decoration: BoxDecoration(
              color: TColor.gray80,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                "Error: $_error",
                style: TextStyle(color: TColor.primaryText),
              ),
            ),
          ),
        ),
      );
    }

    if (categories == null || categories!.isEmpty) {
      return FractionallySizedBox(
        heightFactor: 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.5),
          child: Container(
            decoration: BoxDecoration(
              color: TColor.gray80,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                "No data available.",
                style: TextStyle(color: TColor.primaryText),
              ),
            ),
          ),
        ),
      );
    }

    return FractionallySizedBox(
      heightFactor: 0.5,
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
                    width: 50, // Đặt lại width phù hợp cho thanh kéo
                    decoration: BoxDecoration(
                      color: TColor.gray20,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // TabBar
                Container(
                  decoration: BoxDecoration(
                    color: TColor.gray30,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: TabBar(
                      controller: _tabController,
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
                // Hiển thị ngày và các nút
                GestureDetector(
                  onTap: () => _selectDate(context),
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
                      ),
                      TextField(
                        controller: _transactionAmountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút Change
                      ElevatedButton(
                        onPressed: () {
                          // Xử lý logic Change
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          "Change",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      // Nút Delete
                      ElevatedButton(
                        onPressed: () {
                          // Xử lý logic Delete
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
