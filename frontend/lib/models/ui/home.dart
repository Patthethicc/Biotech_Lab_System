import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/services/dashboard_service.dart';
import 'package:frontend/services/transaction_entry_service.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  int outOfStock = 0;
  String selectedPeriod = 'daily';
  int dynamicCount = 0;
  int totalQuantity = 0;
  bool loading = true;
  bool isLoadingDynamicCount = true;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
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
            items: ['daily', 'monthly', 'yearly']
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          )
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
              buildLeftColumn(),
              const SizedBox(width: 20),
              buildRightColumn(),
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
        summaryCard(_cardLabel(), dynamicCount, isLoading: isLoadingDynamicCount),
        summaryCard("Total Quantity", totalQuantity),
        summaryCard("Out of Stock", outOfStock),
      ],
    );
  }

  String _cardLabel() {
    switch (selectedPeriod) {
      case 'daily': return "Today's Transactions";
      case 'monthly': return "This Month's Transactions";
      case 'yearly': return "This Year's Transactions";
      default: return "Transactions";
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
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(100),
        ),
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
                const Icon(Icons.analytics, size: 24, color: Color(0xFF01579B)),
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              value.toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
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





  Widget buildLeftColumn() {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 250,
          child: Card(
            elevation: 4,
            child: Column(
              children: [
                const Text("No. of users"),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("sample total"),
                  subtitle: const Text("Total Customers"),
                ),
                ListTile(
                  leading: const Icon(Icons.factory),
                  title: Text("sample total"),
                  subtitle: const Text("Total Suppliers"),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 725,
          height: 250,
          child: Card(
            elevation: 4,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 0),
                      FlSpot(3, 2),
                      FlSpot(6, 10)
                    ]
                  )
                ]
              )
            ),
          ),
        )
      ],
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
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
