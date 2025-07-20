import 'package:flutter/material.dart';
import 'package:frontend/models/api/stock_locator_model.dart';
import 'package:frontend/services/stock_locator_service.dart';

class StockLocatorPage extends StatefulWidget {
  const StockLocatorPage({super.key});

  @override
  State<StockLocatorPage> createState() => _StockLocatorPageState();
}

class _StockLocatorPageState extends State<StockLocatorPage> {
  bool _showTable = false;
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _productController = TextEditingController();

  StockLocator? _result;
  final StockLocatorService _service = StockLocatorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Locator'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () async {
                        String brand = _brandController.text.trim();
                        String product = _productController.text.trim();

                        if (brand.isEmpty || product.isEmpty) return;

                        final result = await _service.searchStockLocator(brand, product);
                        if (result != null) {
                          print('Stock found');
                          print('Product Name: ${result.itemCode}');
                        } else {
                          print('Error');
                        }
                        setState(() {
                          _showTable = false;
                          _result = result;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                    ),
                    child: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 275,
                  height: 50,
                  child: TextField(
                    controller: _brandController,
                    decoration: InputDecoration(
                      hintText: "Enter Brand",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 275,
                  height: 50,
                  child: TextField(
                    controller: _productController,
                    decoration: InputDecoration(
                      hintText: "Enter Product Description",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_showTable)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Quantity')),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('Lazcano Ref 1')),
                          DataCell(Text('${_result!.lazcanoRef1}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Lazcano Ref 2')),
                          DataCell(Text('${_result!.lazcanoRef2}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Gandia Cold Storage')),
                          DataCell(Text('${_result!.gandiaColdStorage}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Gandia Ref 1')),
                          DataCell(Text('${_result!.gandiaRef1}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Gandia Ref 2')),
                          DataCell(Text('${_result!.gandiaRef2}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Limbaga')),
                          DataCell(Text('${_result!.limbaga}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Cebu')),
                          DataCell(Text('${_result!.cebu}')),
                        ]),
                      ],
                    )
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

