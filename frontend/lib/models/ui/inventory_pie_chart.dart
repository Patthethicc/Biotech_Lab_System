import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InventoryPieChart extends StatelessWidget {
  final String title;
  final List<Inventory> data;
  final bool isLoading;

  const InventoryPieChart({
    super.key,
    required this.title,
    required this.data,
    required this.isLoading,
  });

  List<Inventory> groupByBrand(List<Inventory> originalList) {
    final Map<String, int> brandQuantities = {};

    for (final item in originalList) {
      brandQuantities[item.brand] = (brandQuantities[item.brand] ?? 0) + item.quantityOnHand;
    }

    // Convert to list of Inventory-like objects with brand and quantityOnHand
    return brandQuantities.entries.map((entry) {
      return Inventory(
          inventoryID: 0,
          itemCode: '',
          brand: entry.key,
          productDescription: '',
          lotSerialNumber: '',
          cost: 0,
          expiryDate: '',
          stocksManila: 0,
          stocksCebu: 0,
          addedBy: '',
          dateTimeAdded: '',
        )..quantityOnHand = entry.value;
      }).toList();
  }


  @override
  Widget build(BuildContext context) {
    final groupedData = groupByBrand(data);
    final top10List = groupedData
      ..sort((a, b) => b.quantityOnHand.compareTo(a.quantityOnHand));
    final top10 = top10List.take(10).toList();

    return SizedBox(
      height: 400,
      width: 450,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: -4,
            color: const Color.fromARGB(255, 234, 239, 245),
            shadowDarkColor: const Color(0xFFB0CDEB),
            shadowLightColor: Colors.white,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A4C78),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 127, 169, 223),
                            ),
                          ),
                        ),
                      )
                    : top10.isEmpty
                        ? const Center(child: Text('No data'))
                        : SfCircularChart(
                            backgroundColor: Colors.transparent,
                            legend: Legend(
                              isVisible: true,
                              overflowMode: LegendItemOverflowMode.wrap,
                              position: LegendPosition.right,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2A4C78),
                              ),
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              format: 'point.x: point.y',
                              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                                final Inventory inv = data;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xFF7FA7E6)),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromARGB(64, 0, 0, 0),
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    '${inv.brand}: ${inv.quantityOnHand}',
                                    style: const TextStyle(
                                      color: Color(0xFF2A4C78),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            series: <CircularSeries>[
                              PieSeries<Inventory, String>(
                                dataSource: top10,
                                xValueMapper: (Inventory inv, _) => inv.brand,
                                yValueMapper: (Inventory inv, _) => inv.quantityOnHand,
                                dataLabelMapper: (Inventory inv, _) => inv.quantityOnHand.toString(),
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                  connectorLineSettings: ConnectorLineSettings(
                                    type: ConnectorType.line,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2A4C78),
                                  ),
                                ),
                                pointColorMapper: (_, index) {
                                  final colors = [
                                    Color(0xFF7DA5E8),
                                    Color(0xFF9BBBEF),
                                    Color(0xFFAAC7F2),
                                    Color(0xFFC7DDF6),
                                    Color(0xFFD8E9F9),
                                    Color(0xFF6F98DD),
                                    Color(0xFF507FCF),
                                    Color(0xFF4073C5),
                                    Color(0xFF3366BB),
                                    Color(0xFF264CAA),
                                  ];
                                  return colors[index % colors.length];
                                },
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

