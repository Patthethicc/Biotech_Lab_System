import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/models/ui/item_details.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/models/api/item_model.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<String> headers = [];
  List<List<String>> rows = [];
  bool isLoading = true;
  bool hasError = false;
  int currentPage = 0;
  final int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    loadInventoryData();
  }

  Future<void> loadInventoryData() async {
    setState(() => isLoading = true);
    try {
      final data = await InventoryService().fetchStockAlerts(999999);
      setState(() {
        headers = ['ID', 'Item Code', 'Qty', 'Last Updated'];
        rows = data.map((inv) => [
          inv.inventoryID.toString(),
          inv.itemCode,
          inv.quantityOnHand.toString(),
          inv.lastUpdated.toString(),
        ]).toList();
      });
    } catch (e) {
      print('Error loading inventory: $e');
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _goToPage(int delta) {
    setState(() {
      currentPage += delta;
      if (currentPage < 0) currentPage = 0;
      if (currentPage > rows.length ~/ rowsPerPage) {
        currentPage = rows.length ~/ rowsPerPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    final hasData = rows.isNotEmpty;

    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, rows.length);
    final currentRows = rows.sublist(start, end);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          Image.asset('Assets/Icons/bellicon.png', height: 60.0, width: 60.0),
        ],
        
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetails(
                item: Item(
                  itemCode: '',
                  brand: '',
                  productDescription: '',
                  lotSerialNumber: '',
                  expiryDate: null,
                  stocksManila: '',
                  stocksCebu: '',
                  purchaseOrderReferenceNumber: '',
                  supplierPackingList: '',
                  drsiReferenceNumber: '',
                ),
                headers: headers,
              ),
            ),
          ).then((changed) {
            if (changed == true) loadInventoryData();
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Search and Filter Bars
            Row(
              spacing: 10.0,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 50,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Search',
                        style: TextStyle(
                          color: Color.fromRGBO(225, 225, 225, 1),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 250,
                  height: 50,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '2025-05-25 : 2025-05-25',
                        style: TextStyle(
                          color: Color.fromRGBO(225, 225, 225, 1),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 250,
                  height: 50,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Filter By Qt. On Hold',
                        style: TextStyle(
                          color: Color.fromRGBO(225, 225, 225, 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (!hasData)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No inventory items available."),
              )
            else
              // Inventory Table
              Container(
                height: 600,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 240, 240, 240),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(200, 255, 255, 255),
                      offset: Offset(-6, 6),
                      blurRadius: 12,
                    ),
                    BoxShadow(
                      color: Color.fromARGB(50, 0, 0, 0),
                      offset: Offset(6, -6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.white),
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: Color.fromARGB(128, 128, 128, 128),
                          width: 2,
                        ),
                        verticalInside: BorderSide(
                          color: Color.fromARGB(128, 128, 128, 128),
                          width: 0.5,
                        ),
                      ),
                      columns: headers.map((h) {
                        double width = (h == 'Item')
                            ? 200
                            : (h == 'Description')
                                ? 250
                                : 100;
                        return DataColumn(
                          label: SizedBox(
                            width: width,
                            child: Text(h, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      }).toList(),
                      rows: currentRows.map((r) {
                        return DataRow(
                          onSelectChanged: (_) {
                            final item = Item(
                              itemCode: r[1],
                              brand: '',
                              productDescription: '',
                              lotSerialNumber: '',
                              expiryDate: null,
                              stocksManila: '',
                              stocksCebu: '',
                              purchaseOrderReferenceNumber: '',
                              supplierPackingList: '',
                              drsiReferenceNumber: '',
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemDetails(
                                  item: item,
                                  headers: headers,
                                ),
                              ),
                            ).then((changed) {
                              if (changed == true) loadInventoryData();
                            });
                          },
                          cells: [
                            for (int i = 0; i < headers.length; i++)
                              DataCell(
                                SizedBox(
                                  width: (headers[i] == 'ID')
                                      ? 200
                                      : (headers[i] == 'itemCode')
                                          ? 250
                                          : 120,
                                  child: Text(i < r.length && r[i].trim().isNotEmpty ? r[i] : '-'),
                                ),
                              )
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: currentPage > 0 ? () => _goToPage(-1) : null,
                    child: Text("Prev"),
                  ),
                  SizedBox(width: 20),
                  Text("Page ${currentPage + 1} of ${(rows.length / rowsPerPage).ceil()}"),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: end < rows.length ? () => _goToPage(1) : null,
                    child: Text("Next"),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
