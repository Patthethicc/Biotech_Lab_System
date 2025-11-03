import 'package:flutter/material.dart';
import 'package:frontend/models/api/stock_locator_model.dart';
import 'package:frontend/models/api/brand_model.dart';
import 'package:frontend/services/stock_locator_service.dart';
import 'package:frontend/services/brand_service.dart';

class StockLocatorPage extends StatefulWidget {
  const StockLocatorPage({super.key});

  @override
  State<StockLocatorPage> createState() => _StockLocatorPageState();
}

class _StockLocatorPageState extends State<StockLocatorPage> {
  bool _isLoading = false;
  bool _showTable = false;
  bool _brandsLoading = true;
  
  final TextEditingController _productController = TextEditingController();
  
  List<BrandModel> _brands = [];
  BrandModel? _selectedBrand;
  StockLocator? _result;
  String? _errorMessage;
  
  final StockLocatorService _service = StockLocatorService();
  final BrandService _brandService = BrandService();

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await _brandService.getBrands();
      setState(() {
        _brands = brands;
        _brandsLoading = false;
      });
    } catch (e) {
      setState(() {
        _brandsLoading = false;
        _errorMessage = 'Failed to load brands: $e';
      });
    }
  }

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
                            if (_selectedBrand == null || _productController.text.trim().isEmpty) {
                              setState(() {
                                _errorMessage = 'Please select a brand and enter product description to search.';
                                _showTable = false;
                                _result = null;
                              });
                              return;
                            }

                            setState(() {
                              _isLoading = true;  
                              _showTable = false;
                            });

                            final result = await _service.searchStockLocator(
                              _selectedBrand!.brandName, 
                              _productController.text.trim()
                            );

                            setState(() {
                              _isLoading = false;
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

                      // Brand Dropdown
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _brandsLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<BrandModel>(
                                    value: _selectedBrand,
                                    hint: const Text(
                                      'Select Brand',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: _brands.map((BrandModel brand) {
                                      return DropdownMenuItem<BrandModel>(
                                        value: brand,
                                        child: Text(
                                          brand.brandName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (BrandModel? newValue) {
                                      setState(() {
                                        _selectedBrand = newValue;
                                        // Clear previous results when brand changes
                                        _showTable = false;
                                        _result = null;
                                        _errorMessage = null;
                                      });
                                    },
                                  ),
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
                          onChanged: (value) {
                            // Clear previous results when product description changes
                            if (_showTable) {
                              setState(() {
                                _showTable = false;
                                _result = null;
                                _errorMessage = null;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Loading spinner
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!_isLoading && _errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(35, 8, 16, 8),
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
                          columnWidths: const {
                            0: FlexColumnWidth(2), // Location column
                            1: FlexColumnWidth(1), // Quantity column
                            2: FixedColumnWidth(60), // Edit button column
                          },
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
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF2F3F5),      
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 10.0),
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // DATA ROWS
                            _buildStockRow('Lazcano Ref 1', _result!.lazcanoRef1, 'lazcanoRef1'),
                            _buildStockRow('Lazcano Ref 2', _result!.lazcanoRef2, 'lazcanoRef2'),
                            _buildStockRow('Gandia (Cold Storage)', _result!.gandiaColdStorage, 'gandiaColdStorage'),
                            _buildStockRow('Gandia (Ref 1)', _result!.gandiaRef1, 'gandiaRef1'),
                            _buildStockRow('Gandia (Ref 2)', _result!.gandiaRef2, 'gandiaRef2'),
                            _buildStockRow('Limbaga', _result!.limbaga, 'limbaga'),
                            _buildStockRow('Cebu', _result!.cebu, 'cebu'),
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

  // builds one row of stock data
  TableRow _buildStockRow(String locationName, int quantity, String fieldName) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(locationName),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('$quantity'),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showEditQuantityDialog(locationName, quantity, fieldName),
                tooltip: 'Edit $locationName quantity',
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: const EdgeInsets.all(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditQuantityDialog(String locationName, int currentQuantity, String fieldName) {
    final TextEditingController quantityController = TextEditingController(
      text: currentQuantity.toString(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $locationName Stock'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: $locationName',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Quantity: $currentQuantity',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'New Quantity',
                    hintText: 'Enter new quantity',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _validateAndUpdateQuantity(locationName, quantityController.text, fieldName);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _validateAndUpdateQuantity(String locationName, String newQuantityText, String fieldName) {
    final int? newQuantity = int.tryParse(newQuantityText.trim());
    
    if (newQuantity == null) {
      _showErrorDialog('Invalid quantity. Please enter a valid number.');
      return;
    }

    if (newQuantity < 0) {
      _showErrorDialog('Quantity cannot be negative.');
      return;
    }

    Navigator.of(context).pop(); // Close the edit dialog
    _updateStockQuantity(locationName, newQuantity, fieldName);
  }

  Future<void> _updateStockQuantity(String locationName, int newQuantity, String fieldName) async {
    if (_result == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Updating...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait while the stock is being updated.'),
            ],
          ),
        );
      },
    );

    try {
      // Create updated stock locator object
      StockLocator updatedStock = StockLocator(
        itemCode: _result!.itemCode,
        brand: _result!.brand,
        productDescription: _result!.productDescription,
        lazcanoRef1: fieldName == 'lazcanoRef1' ? newQuantity : _result!.lazcanoRef1,
        lazcanoRef2: fieldName == 'lazcanoRef2' ? newQuantity : _result!.lazcanoRef2,
        gandiaColdStorage: fieldName == 'gandiaColdStorage' ? newQuantity : _result!.gandiaColdStorage,
        gandiaRef1: fieldName == 'gandiaRef1' ? newQuantity : _result!.gandiaRef1,
        gandiaRef2: fieldName == 'gandiaRef2' ? newQuantity : _result!.gandiaRef2,
        limbaga: fieldName == 'limbaga' ? newQuantity : _result!.limbaga,
        cebu: fieldName == 'cebu' ? newQuantity : _result!.cebu,
      );

      final success = await _service.updateStockLocator(updatedStock);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        // Update local state
        setState(() {
          _result = updatedStock;
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content: Text('$locationName stock has been successfully updated to $newQuantity!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        _showErrorDialog('Failed to update stock. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('An error occurred while updating stock: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}