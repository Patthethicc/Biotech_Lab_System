import 'package:flutter/material.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/services/stock_alert_service.dart';
import 'package:intl/intl.dart';


class StockAlert extends StatefulWidget {
  const StockAlert({super.key});

  @override
  State<StockAlert> createState() => _StockAlertState();
}

class _StockAlertState extends State<StockAlert> {
  late Future<List<Inventory>> _stockAlerts;

  @override
  void initState() {
    super.initState();
    _stockAlerts = StockAlertService.getStockAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Alerts"),
      ),
      body: FutureBuilder<List<Inventory>>(
        future: _stockAlerts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No stock alerts."));
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemCode,
                        style: const TextStyle(fontSize: 25),
                      ),
                      Text("inv ID: ${item.inventoryID}"),
                      Text("Quantity on Hand: ${item.quantityOnHand}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
