import 'package:flutter/material.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InventoryBarChart extends StatelessWidget {
  final String title;
  final List<Inventory> data;
  final bool isLoading;

  const InventoryBarChart({
    super.key,
    required this.title,
    required this.data,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
   final top10 = data.take(10).toList();

    return SizedBox(
      height: 400,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : top10.isEmpty
                        ? const Center(child: Text('No data'))
                        : SfCartesianChart(
                            tooltipBehavior: TooltipBehavior(enable: true),
                            primaryXAxis: CategoryAxis(
                              // title: AxisTitle(text: 'Stock Name'),
                              isInversed: true,
                              labelStyle: const TextStyle(fontSize: 10),
                              majorTickLines: const MajorTickLines(size: 0),
                              majorGridLines: const MajorGridLines(width: 0),
                            ),
                            primaryYAxis: NumericAxis(
                              // title: AxisTitle(text: 'Quantity on Hand'),
                              minimum: 0,
                              majorGridLines: const MajorGridLines(width: 0.5),
                            ),
                            series: <CartesianSeries>[
                              BarSeries<Inventory, String>(
                                dataSource: top10,
                                xValueMapper: (Inventory inv, _) => inv.brand,
                                yValueMapper: (Inventory inv, _) => inv.quantityOnHand,
                                name: 'Stock',
                                color: Colors.lightBlue,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(100.0), bottomRight: Radius.circular(100.0)),
                                dataLabelSettings: const DataLabelSettings(isVisible: true),
                              ),
                            ],
                          )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
