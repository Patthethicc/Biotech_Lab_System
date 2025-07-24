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
  List<Inventory> rows = [];
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
    setState(() {
      isLoading = true;
      hasError = false; // Reset error state
    });
    try {
      final List<Inventory> data = await InventoryService().getInventories(); // Assuming getInventories() now returns List<Inventory>

      setState(() {
        // Headers should match the order and names of the data you want to display
        headers = ['ID', 'Item Code', 'Brand', 'Quantity', 'Added By', 'Last Updated'];
        rows = data; // Assign the list of Inventory objects directly
      });
    } catch (e) {
      print('Error loading inventory: $e'); // Log the error for debugging
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _goToPage(int delta) {
    setState(() {
      currentPage += delta;
      if (currentPage < 0) currentPage = 0;
      if (rows.isEmpty) {
        currentPage = 0;
      } else if (currentPage > (rows.length - 1) ~/ rowsPerPage) {
        currentPage = (rows.length - 1) ~/ rowsPerPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (hasError) return const Center(child: Text('Failed to load inventory. Please try again.'));

    final hasData = rows.isNotEmpty;

    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, rows.length);
    final List<Inventory> currentRows = rows.sublist(start, end); // currentRows is also List<Inventory>

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          // Image.asset('Assets/Icons/bellicon.png', height: 60.0, width: 60.0),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetails(
                item: Item( // Default/empty Item object for new entry
                  itemCode: '', brand: '', productDescription: '',
                  lotSerialNumber: '', expiryDate: null,
                  stocksManila: '', stocksCebu: '',
                  purchaseOrderReferenceNumber: '', supplierPackingList: '',
                  drsiReferenceNumber: '',
                ),
                headers: headers,
              ),
            ),
          ).then((changed) {
            if (changed == true) {
              loadInventoryData(); // Reload data if ItemDetails indicates a change
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // --- Search and Filter Bars (fixed `spacing` issue) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0), // Add some spacing below the search row
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Search',
                          style: TextStyle(color: Color.fromRGBO(225, 225, 225, 1)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Explicit spacing
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          '2025-05-25 : 2025-05-25',
                          style: TextStyle(color: Color.fromRGBO(225, 225, 225, 1)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Explicit spacing
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Filter By Qt. On Hold',
                          style: TextStyle(color: Color.fromRGBO(225, 225, 225, 1)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // --- End Search and Filter Bars ---

            if (!hasData)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No inventory items available."),
              )
            else
              Expanded(
                child: Container(
                  // Remove fixed height if Expanded is used, it will fill available space
                  // height: 600,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 240, 240, 240),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
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
                          // Adjust column widths as needed based on header content
                          double width = (h == 'Item Code') ? 150 : (h == 'Product Description') ? 250 : 120;
                          return DataColumn(
                            label: SizedBox(
                              width: width,
                              child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          );
                        }).toList(),
                        rows: currentRows.map((inv) { // **`inv` is now an Inventory object!**
                          return DataRow(
                            onSelectChanged: (_) {
                              // When selecting a row, you can now pass the full Inventory object
                              // or build an Item object with more complete data from `inv`.
                              final item = Item(
                                itemCode: inv.itemCode ?? '', // Use null-aware operator for safety
                                brand: inv.brand ?? '',
                                productDescription: '', // This needs to come from your Item model or a DTO
                                lotSerialNumber: '', // This needs to come from your Item model or a DTO
                                expiryDate: null, // This needs to come from your Item model or a DTO
                                stocksManila: '', // This needs to come from your Item model or a DTO
                                stocksCebu: '', // This needs to come from your Item model or a DTO
                                purchaseOrderReferenceNumber: '', // This needs to come from your Item model or a DTO
                                supplierPackingList: '', // This needs to come from your Item model or a DTO
                                drsiReferenceNumber: '', // This needs to come from your Item model or a DTO
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
                              DataCell(SizedBox(width: 120, child: Text(inv.inventoryID?.toString() ?? 'N/A'))),
                              DataCell(SizedBox(width: 150, child: Text(inv.itemCode ?? 'N/A'))),
                              DataCell(SizedBox(width: 120, child: Text(inv.brand ?? 'N/A'))),
                              DataCell(SizedBox(width: 120, child: Text(inv.quantityOnHand?.toString() ?? 'N/A'))),
                              DataCell(SizedBox(width: 120, child: Text(inv.addedBy ?? 'N/A'))), // Assuming 'addedBy' exists in Inventory model
                              DataCell(SizedBox(width: 120, child: Text(inv.dateTimeAdded?.toString().split('.')[0] ?? 'N/A'))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: currentPage > 0 ? () => _goToPage(-1) : null,
                    child: const Text("Prev"),
                  ),
                  const SizedBox(width: 20),
                  Text("Page ${currentPage + 1} of ${rows.isEmpty ? 1 : (rows.length / rowsPerPage).ceil()}"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: end < rows.length ? () => _goToPage(1) : null,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}