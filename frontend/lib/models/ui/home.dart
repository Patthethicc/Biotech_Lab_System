import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/services/dashboard_service.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:frontend/services/transaction_entry_service.dart';
import 'package:frontend/models/api/inventory.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Inventory> top = [];
  List<Inventory> bottom = [];
  bool loadingTop = true, loadingBottom = true;

  int outOfStock = 0;
  String selectedPeriod = 'daily';
  int dynamicCount = 0;
  int totalQuantity = 0;
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
    final svc = DashboardStatsService();
    setState(() => isLoadingDynamicCount = true);
    try {
      final count = await svc.fetchTransactionCount(selectedPeriod);
      final entries = await TransactionEntryService().fetchTransactionEntries();

      setState(() {
        dynamicCount = count;
        totalQuantity = entries.fold(0, (sum, e) => sum + e.quantity);
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Biotech Home'),
        actions: [
          DropdownButton<String>(
            value: selectedPeriod,
            onChanged: (v) {
              if (v != null) {
                selectedPeriod = v;
                _loadAllStats();
              }
            },
            items: [
              'daily',
              'monthly',
              'yearly',
            ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          buildSummaryCards(),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildChart('📊 Top Stock Items', top, loadingTop),
              const SizedBox(width: 20),
              buildChart('🔻 Low Stock Items', bottom, loadingBottom),
              // buildRightColumn(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        summaryCard("Total Transactions", totalQuantity),
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

  BarChartData chartData(List<Inventory> list) {
    List<Inventory> top10List = list.take(10).toList();

    final maxQuantity = top10List.isNotEmpty
        ? top10List.map((i) => i.quantityOnHand).reduce(max).toDouble()
        : 0.0;
    final maxY = (maxQuantity > 0) ? maxQuantity + 5 : 10.0;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      minY: 0,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, meta) => _bottomTitles(val, meta, top10List),
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true),
      barGroups: List.generate(top10List.length, (i) {
        final inv = top10List[i];
        final y = (inv.quantityOnHand ?? 0).clamp(0, maxY).toDouble();
        return BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: y, color: Colors.lightBlue)],
        );
      }),
    );
  }

  Widget buildChart(String title, List<Inventory> data, bool isLoading) {
    return SizedBox(
      height: 500, // fixed stack height
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: headerStyle),
              const SizedBox(height: 8),
              SizedBox(
                width: 300,
                height: 400, // or whatever height fits your UI
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : data.isEmpty
                    ? const Center(child: Text('No data'))
                    : BarChart(chartData(data)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta, List<Inventory> list) {
    const style = TextStyle(color: Colors.black, fontSize: 10);
    final idx = value.toInt();
    final label = (idx >= 0 && idx < list.length) ? list[idx].brand : '';
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(label, style: style),
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
          buildDrawerItem(context, 'Data Recording', '/transaction_entry'),
          buildDrawerItem(context, 'Inventory', '/inventory'),
          buildDrawerItem(context, 'Stock Alerts', '/stock_alert'),
          buildDrawerItem(context, 'Stock Locator', '/stock_locator'),
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
