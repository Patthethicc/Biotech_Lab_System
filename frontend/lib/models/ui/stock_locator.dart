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
  String? _errorMessage;
  final StockLocatorService _service = StockLocatorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Locator'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('Assets/Images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Search Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      // Search Button
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            String brand = _brandController.text.trim();
                            String product = _productController.text.trim();

                            if (brand.isEmpty || product.isEmpty) {
                              setState(() {
                                _errorMessage = 'Please fill in both fields to search.';
                                _showTable = false;
                                _result = null;
                              });
                              return;
                            }

                            final result = await _service.searchStockLocator(brand, product);

                            setState(() {
                              if (result != null) {
                                _result = result;
                                _showTable = true;
                                _errorMessage = null;
                              } else {
                                _result = null;
                                _showTable = false;
                                _errorMessage = 'Product not found.';
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Brand Field
                      Container(
                        width: 275,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            hintText: "Enter Brand",
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Product Field
                      Container(
                        width: 275,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _productController,
                          decoration: const InputDecoration(
                            hintText: "Enter Product Description",
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(35, 8, 16, 8), // <-- Increased left padding
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            offset: Offset(0.5, 0.5),
                            blurRadius: 2.0,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),


                if (_showTable && _result != null)
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            // HEADER ROW
                            TableRow(
                              children: [
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF2F3F5),      
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 10.0),
                                    child: const Text(
                                      'Location',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF2F3F5),      
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 10.0),
                                    child: const Text(
                                      'Quantity',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // DATA ROWS
                            TableRow(
                              decoration: const BoxDecoration(color: Colors.white),
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Lazcano Ref 1'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${_result!.lazcanoRef1}'),
                                  ),
                                ),
                              ],
                            ),

                            TableRow(
                              decoration: const BoxDecoration(color: Colors.white),
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Lazcano Ref 2'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${_result!.lazcanoRef2}'),
                                  ),
                                ),
                              ],
                            ),

                            TableRow(
                              decoration: const BoxDecoration(color: Colors.white),
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Gandia (Cold Storage)'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${_result!.gandiaColdStorage}'),
                                  ),
                                ),
                              ],
                            ),

                            TableRow(
                              decoration: const BoxDecoration(color: Colors.white),
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Gandia (Ref 1)'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${_result!.gandiaRef1}'),
                                  ),
                                ),
                              ],
                            ),

                            TableRow(
                              decoration: const BoxDecoration(color: Colors.white),
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Gandia (Ref 2)'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${_result!.gandiaRef2}'),
                                  ),
                                ),
                              ],
                            ),

                            TableRow(
                              decoration: const BoxDecoration(color: Colors.white),
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Limbaga'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${_result!.limbaga}'),
                                  ),
                                ),
                              ],
                            ),

                            TableRow(
                              decoration: const BoxDecoration(color: Colors.white),
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Cebu'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${_result!.cebu}'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}