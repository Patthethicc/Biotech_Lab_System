import 'package:flutter/material.dart';

class StockLocator extends StatefulWidget {
  const StockLocator({super.key});

  @override
  State<StockLocator> createState() => _StockLocatorState();
}

class _StockLocatorState extends State<StockLocator> {
  final TextEditingController _searchController = TextEditingController();

  List<List<String>> rows = [];
  bool isLoading = false;
  bool hasError = false;
  int currentPage = 0;
  final int rowsPerPage = 10;

  final List<String> headers = ['Item Name', 'Stock Location', 'Quantity'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> findStock() async {
    final searchTerm = _searchController.text.trim();

    if (searchTerm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter an item name.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // TODO: Replace this mock data with a call to your backend service
      // e.g. StockLocatorService.getStockLocations(searchTerm)
      await Future.delayed(Duration(seconds: 1)); // simulate loading

      rows = List.generate(5, (index) => [
        "$searchTerm ${index + 1}",
        "Warehouse Bin ${index * 2}",
        "${(index + 1) * 10}",
      ]);
    } catch (e) {
      print(e);
      hasError = true;
    } finally {
      setState(() {
        isLoading = false;
      });
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
    final hasData = rows.isNotEmpty;

    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, rows.length);
    final currentRows = rows.sublist(start, end);

    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Locator'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Enter item name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: findStock,
                  child: Text("Find Stock"),
                ),
              ],
            ),
            SizedBox(height: 30),

            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (hasError)
              Text("Error loading data.", style: TextStyle(color: Colors.red))
            else if (!hasData)
              Text("No data found.")
            else
              Expanded(
                child: Container(
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
                        columns: headers
                            .map((h) => DataColumn(
                                  label: SizedBox(
                                    width: 200,
                                    child: Text(
                                      h,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ))
                            .toList(),
                        rows: currentRows
                            .map((r) => DataRow(
                                  cells: r
                                      .map((cell) => DataCell(
                                            SizedBox(
                                              width: 200,
                                              child: Text(cell),
                                            ),
                                          ))
                                      .toList(),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),

            if (hasData)
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
