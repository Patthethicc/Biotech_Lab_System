import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

enum ReportFilter { daily, monthly, yearly }

class _DashboardState extends State<Dashboard> {
  ReportFilter _selectedFilter = ReportFilter.daily;

  // hardcoded sample data for each filter
  final _data = {
    ReportFilter.daily: {
      'products': 120,
      'orders': 80,
      'stocks': 350,
      'outOfStock': 10,
      'customers': 25,
      'suppliers': 5,
      'pie': [70.0, 30.0],
      'line': [0.0, 3.0, 7.0, 10.0],
      'bars': [5, 8, 6, 9, 7, 4, 3],
    },
    ReportFilter.monthly: {
      'products': 350,
      'orders': 220,
      'stocks': 500,
      'outOfStock': 25,
      'customers': 300,
      'suppliers': 120,
      'pie': [55.0, 45.0],
      'line': [2.0, 6.0, 14.0, 20.0],
      'bars': [10, 15, 12, 17, 14, 9, 11],
    },
    ReportFilter.yearly: {
      'products': 4200,
      'orders': 2400,
      'stocks': 6000,
      'outOfStock': 200,
      'customers': 1500,
      'suppliers': 800,
      'pie': [50.0, 50.0],
      'line': [30.0, 60.0, 120.0, 180.0],
      'bars': [50, 60, 55, 65, 62, 58, 52],
    },
  };

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> values = _data[_selectedFilter]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BioTech Home'),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: DropdownButton<ReportFilter>(
          //     value: _selectedFilter,
          //     onChanged: (value) {
          //       if (value != null) {
          //         setState(() => _selectedFilter = value);
          //       }
          //     },
          //     underline: Container(),
          //     dropdownColor: Colors.white,
          //     items: ReportFilter.values.map((filter) {
          //       final txt = filter.name[0].toUpperCase() + filter.name.substring(1);
          //       return DropdownMenuItem(
          //         value: filter,
          //         child: Text(txt),
          //       );
          //     }).toList(),
          //   ),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButton<ReportFilter>(
              value: _selectedFilter,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                }
              },
              underline: Container(),
              dropdownColor: Colors.white,
              items: ReportFilter.values.map((filter) {
                final txt = filter.name[0].toUpperCase() + filter.name.substring(1);
                return DropdownMenuItem(
                  value: filter,
                  child: Text(txt),
                );
              }).toList(),
            ),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildCard('Total Products', values['products']),
                _buildCard('Total Orders', values['orders']),
                _buildCard('Total Stocks', values['stocks']),
                _buildCard('Out of Stock', values['outOfStock']),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPieAndList(values),
                const SizedBox(width: 20),
                _buildLineChart(values),
                const SizedBox(width: 20),
                _buildBarChart(values),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCard(String title, int count) {
    return SizedBox(
      width: 250,
      height: 70,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: ListTile(
          leading: Text("img"),
          title: Text(count.toString()),
          subtitle: Text(title),
        ),
      ),
    );
  }

  Widget _buildPieAndList(Map<String, dynamic> values) {
    return SizedBox(
      width: 350,
      height: 300,
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(12), child: Text("User vs Supplier Ratio")),
            Expanded(
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 20,
                  sections: [
                    PieChartSectionData(
                      value: values['pie'][0],
                      color: Colors.blueGrey,
                      radius: 70,
                      title: '${values['pie'][0].toInt()}%',
                    ),
                    PieChartSectionData(
                      value: values['pie'][1],
                      color: Colors.grey,
                      radius: 70,
                      title: '${values['pie'][1].toInt()}%',
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Customers: ${values['customers']}'),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: Text('Suppliers: ${values['suppliers']}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(Map<String, dynamic> values) {
    return SizedBox(
      width: 500,
      height: 300,
      child: Card(
        elevation: 4,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                spots: List.generate(
                  values['line'].length,
                  (i) => FlSpot(i.toDouble(), values['line'][i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, dynamic> values) {
    return SizedBox(
      width: 350,
      height: 300,
      child: Card(
        elevation: 4,
        child: BarChart(
          BarChartData(
            barGroups: List.generate(values['bars'].length, (i) {
              return BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: values['bars'][i].toDouble()),
              ]);
            }),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
