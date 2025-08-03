import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/ui/latest_transaction_table.dart';
import 'package:frontend/services/dashboard_service.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:frontend/services/transaction_entry_service.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/models/api/transaction_entry.dart';
import 'login.dart';
import 'inventory_pie_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Inventory> top = [];
  List<Inventory> bottom = [];
  List<TransactionEntry> transactions = [];
  bool loadingTop = true, loadingBottom = true, loadingTable = true;

  int outOfStock = 0;
  String selectedPeriod = 'daily';
  int dynamicCount = 0;
  int totalQuantity = 0;
  int totalTransactions = 0;
  bool loading = true;
  bool isLoadingDynamicCount = true;

  TextStyle headerStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF01579B), // Dark blue
  );

  TextStyle smallTitleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF01579B), // Consistent dark blue for labels
  );

  @override
  void initState() {
    super.initState();
    _loadAllStats();
    _loadInventories();
  }

  Future<void> _loadAllStats() async {
    setState(() {
      isLoadingDynamicCount = true;
      loadingTable = true;
    });

    try {
      final entries = await TransactionEntryService().fetchTransactionEntries();
      final filtered = _filterTransactionsByPeriod(entries, selectedPeriod);

      setState(() {
        transactions = filtered;
        totalTransactions = filtered.length;
        totalQuantity = filtered.fold(0, (sum, e) => sum + e.quantity);
        dynamicCount = filtered.length; // This now reflects period correctly
        loadingTable = false;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
      setState(() {
        loadingTable = false;
      });
    } finally {
      setState(() => isLoadingDynamicCount = false);
    }
  }



  Future<void> _loadInventories() async {
    setState(() {
      loadingTop = true;
      loadingBottom = true;
    });
    try {
      final t = await InventoryService().getTopStock();
      final b = await InventoryService().getBottomStock();
      setState(() {
        top = t;
        bottom = b;
      });
    } catch (e) {
      print('Stock load error: $e');
    } finally {
      setState(() {
        loadingTop = false;
        loadingBottom = false;
      });
    }
  }

  List<TransactionEntry> _filterTransactionsByPeriod(List<TransactionEntry> entries, String period) {
    final now = DateTime.now();

    return entries.where((entry) {
      final date = entry.transactionDate;
      switch (period) {
        case 'daily':
          return date.year == now.year && date.month == now.month && date.day == now.day;
        case 'weekly':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && date.isBefore(endOfWeek.add(const Duration(days: 1)));
        case 'monthly':
          return date.year == now.year && date.month == now.month;
        default:
          return false;
      }
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Biotech Home', style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          DropdownButton<String>(
            value: selectedPeriod,
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  selectedPeriod = v;
                });
                _loadAllStats();
                _loadInventories();
              }
            },
            items: [
              'daily',
              'weekly',
              'monthly',
            ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/Images/bg.png'),
            fit: BoxFit.cover,
          )
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            buildSummaryCards(),
            const SizedBox(height: 20),
            LatestTransactionsTable(
              transactions: transactions,
              isLoading: loadingTable,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InventoryPieChart(
                  key: ValueKey('high-$selectedPeriod'),
                  title: 'Highest Stocks',
                  data: top,
                  isLoading: loadingTop,
                ),
                const SizedBox(width: 20),
                InventoryPieChart(
                  key: ValueKey('low-$selectedPeriod'),
                  title: 'Lowest Stocks',
                  data: bottom,
                  isLoading: loadingBottom,
                ),
                // buildRightColumn(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        summaryCard("Total Transactions", totalTransactions),
        summaryCard(
          _cardLabel(),
          dynamicCount,
          isLoading: isLoadingDynamicCount,
        ),
        summaryCard("Total Quantity", totalQuantity),
        summaryCard("Out of Stock", outOfStock),
      ],
    );
  }

  String _cardLabel() {
    switch (selectedPeriod) {
      case 'daily':
        return "Today's Transactions";
      case 'monthly':
        return "This Month's Transactions";
      case 'yearly':
        return "This Year's Transactions";
      default:
        return "Transactions";
    }
  }

  Widget summaryCard(String title, int value, {bool isLoading = false}) {
    return SizedBox(
      width: 250,
      height: 70,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: -3,
          color: const Color(0xFFE0E5EC),
          intensity: 5.0,
          shadowLightColorEmboss: const Color.fromARGB(255, 238, 243, 247),
          shadowDarkColorEmboss: const Color.fromARGB(255, 213, 224, 235),
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(100)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Neumorphic(
            style: NeumorphicStyle(
              depth: 3,
              color: Colors.white,
              intensity: 5.0,
              shadowLightColor: const Color.fromARGB(255, 240, 246, 250),
              shadowDarkColor: const Color.fromARGB(255, 199, 212, 224),
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(100),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics,
                    size: 24,
                    color: Color(0xFF01579B),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                value.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta, List<String> labels) {
    String label = '';
    int idx = value.toInt();
    if (idx >= 0 && idx < labels.length) {
      label = labels[idx];
    }
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }


  Widget buildRightColumn() {
    return SizedBox(
      width: 725,
      height: 530,
      child: Card(
        elevation: 4,
        child: BarChart(
          BarChartData(
            barGroups: List.generate(7, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [BarChartRodData(toY: 10 - i.toDouble())],
              );
            }),
          ),
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 0, 71, 129)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Biotech App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Menu',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          buildDrawerItem(context, 'Dashboard', '/dashboard'),
          buildDrawerItem(context, 'View Profile', '/view_profile'),
          buildDrawerItem(context, 'Transaction Entry', '/transaction_entry'),
          buildDrawerItem(context, 'Inventory', '/inventory'),
          buildDrawerItem(context, 'Brands', '/brand'),
          buildDrawerItem(context, 'Stock Alerts', '/stock_alert'),
          buildDrawerItem(context, 'Stock Locator', '/stock_locator'),
          buildDrawerItem(context, 'Expiration Alert', '/expiry_alert'),
          buildDrawerItem(context, 'Purchase Order', '/purchase_order'),
          ListTile(
            title: const Text('Log out', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildDrawerItem(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
