import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage>{
  int totalProducts = 100;
  int orders = 200;
  int totalStocks = 300;
  int outOfStock = 400;
  int totalCustomers = 500;
  int totalSuppliers = 500;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

   @override
  void initState() {
    super.initState();
    
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState?.openDrawer();
      });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar( title: const Text('Biotech Home')),
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
                elevation: 4,
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
      drawer: Drawer(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[

            //top of the drawer
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 71, 129),
              ),
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
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Dashboard',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            ListTile(
              title: const Text('View Profile',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/view_profile');
              },
            ),
            ListTile(
              title: const Text('Data Recording',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/transaction_entry');
              },
            ),
            ListTile(
              title: const Text('Inventory',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inventory');
              },
            ),
            ListTile(
              title: const Text('Stock Alerts',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/stock_alert');
              },
            ),
            ListTile(
              title: const Text('Stock Alerts',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/stock_locator');
              },
            ),
            ListTile(
              title: const Text('Purchase Order',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/purchase_order');
              },
            ),
            ListTile(
              title: const Text('Log out',
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                  fontSize: 14,
                )),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()), 
                  (route) => false, // goes back to login, and removes this route from the route stack
                );
              },
            )
          ],
        )
      )
    );
  }
}
