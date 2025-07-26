import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
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
                      : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item labels
                    SizedBox(
                      width: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: top10.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Text(
                              item.brand,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2A4C78),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // RIGHT: Chart
                    Expanded(
                      child: SfCartesianChart(
                        backgroundColor: Colors.transparent,
                        borderColor: Colors.transparent,
                        plotAreaBorderColor: Colors.transparent,
                        plotAreaBorderWidth: 0,
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          duration: 200,
                          tooltipPosition: TooltipPosition.pointer,
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
                        primaryXAxis: CategoryAxis(
                          isVisible: false,
                          isInversed: true,
                        ),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                          minimum: 0,
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: const AxisLine(width: 0),
                          majorTickLines: const MajorTickLines(size: 0),
                        ),
                        series: <CartesianSeries>[
                          BarSeries<Inventory, String>(
                            dataSource: List<Inventory>.generate(top10.length, (index) => top10[index]),
                            xValueMapper: (inv, index) => '${inv.brand} #$index',
                            yValueMapper: (inv, _) => inv.quantityOnHand,
                            dataLabelMapper: (inv, _) => inv.quantityOnHand.toString(),
                            name: 'Stock',
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(100.0),
                              bottomRight: Radius.circular(100.0),
                            ),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 148, 183, 240),
                                Color.fromARGB(255, 125, 164, 228),
                                Color.fromARGB(255, 101, 148, 224),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderWidth: 1.5,
                            borderColor: Color.fromARGB(97, 124, 171, 228),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.top,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
