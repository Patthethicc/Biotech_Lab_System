import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int totalProducts = 100;
  int orders = 200;
  int totalStocks = 300;
  int outOfStock = 400;
  int totalCustomers = 500;
  int totalSuppliers = 500;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        spacing: 30,
        children: [Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 250,
              height: 70,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                child: ListTile(
                  leading: Text("img"),
                  title: Text(totalProducts.toString()),
                  subtitle: Text("Total Products"),
                ),
              ),
            ),

            SizedBox(
              width: 250,
              height: 70,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                child: ListTile(
                  leading: Text("img"),
                  title: Text(orders.toString()),
                  subtitle: Text("Orders"),
                ),
              ),
            ),

            SizedBox(
              width: 250,
              height: 70,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                child: ListTile(
                  leading: Text("img"),
                  title: Text(totalStocks.toString()),
                  subtitle: Text("Total Stocks"),
                ),
              ),
            ),

            SizedBox(
              width: 250,
              height: 70,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                child: ListTile(
                  leading: Text("img"),
                  title: Text(outOfStock.toString()),
                  subtitle: Text("Out of Stock"),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 30,
          children: [
            Column(
              spacing: 30,
              children: [
                Row(
                  spacing: 30,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 250,
                      child: Card(
                        elevation: 4,
                        child: Column(
                          children: [
                            Text("No. of users"),
                            ListTile(
                              leading: Text("img"),
                              title: Text(totalCustomers.toString()),
                              subtitle: Text("Total Customers"),
                            ),
                            ListTile(
                              leading: Text("img"),
                              title: Text(totalSuppliers.toString()),
                              subtitle: Text("Total Suppliers"),
                            ),
                          ],
                        ),
                      ),
                    ),
            
                    SizedBox(
                      width: 400,
                      height: 250,
                      child: Card( 
                        elevation: 4,
                        child: PieChart(
                            PieChartData(
                              centerSpaceRadius: 0,
                              sections: [
                                PieChartSectionData(
                                  value: 60,
                                  color: Colors.blueGrey,
                                  radius: 70
                                  ),
                                PieChartSectionData(
                                  value: 40, 
                                  color: Colors.grey,
                                  radius: 70
                                  )
                              ]
                            )
                           )
                      ),
                    )
                ],),
                Row(
                  spacing: 30,
                  children: [
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
                )
            
              ],
              ),

              Column(
                children: [
                  SizedBox(
                      width: 725,
                      height: 530,
                      child: Card(
                        elevation: 4,
                        child: BarChart(
                          BarChartData(
                            rotationQuarterTurns: 45,
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(toY: 10)
                                ]
                              ),

                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(toY: 9)
                                ]
                              ),

                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(toY: 8)
                                ]
                              ),

                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(toY: 7)
                                ]
                              ),

                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(toY: 6)
                                ]
                              ),

                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(toY: 5)
                                ]
                              ),

                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(toY: 4)
                                ]
                              ),
                            ]
                          )
                        ),
                      ),
                    )
                ],
              )
          ],
        ),
        ],
      ),
    );
  }
}

