import 'package:flutter/material.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/services/stock_alert_service.dart';


class StockAlert extends StatefulWidget {
  const StockAlert({super.key});

  @override
  State<StockAlert> createState() => _StockAlertState();
}

class _StockAlertState extends State<StockAlert> {

  List<Inventory> _stockAlerts = [];

  @override

  void initState() {
  final stockAlertService = StockAlertService();

  stockAlertService.getStockAlerts().then((value) {
    print("Fetched data: $value");
    setState(() {
      _stockAlerts.addAll(value);
    });
  });
  super.initState();
}

  @override
  Widget build(BuildContext context) {

    print(_stockAlerts);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Alerts"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.only(top:15, bottom: 15, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Item Code: ${_stockAlerts[index].itemCode}",
                  style: TextStyle(
                    fontSize: 25
                  ),),
                  Text("Quantity on Hand: ${_stockAlerts[index].quantityOnHand.toString()}"),
                  Text("Inventory ID: ${_stockAlerts[index].inventoryID.toString()}")
                ],
              ),
            ),
          );
        },
        itemCount: _stockAlerts.length,
      ),
    );
  }
}