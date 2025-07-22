import 'package:flutter/material.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/models/api/item_model.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:frontend/services/item_details_service.dart';

class DataTemplate extends StatefulWidget {
  const DataTemplate({super.key});

  @override
  State<DataTemplate> createState() => _DataTemplateState();
}

class _DataTemplateState extends State<DataTemplate> {
  final inventoryService = InventoryService();
  final itemDetailsService = ItemDetailsService();

  List<Inventory> _allInventories = [];
  List<Inventory> _displayInventories = [];
  bool _isLoading = true;

  int _startIndex = 0;
  final int _rowsPerPage = 5;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterInventories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInventories);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchData() {
    inventoryService.getInventories().then((value) {
      setState(() {
        _allInventories = value;
        _displayInventories = List.from(_allInventories);
        _isLoading = false;
      });
    });
  }

  void _filterInventories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        _displayInventories = _allInventories.where((inventory) {
          final itemCodeMatch =
              inventory.itemCode.toLowerCase().contains(query);
          final brandMatch = inventory.brand.toLowerCase().contains(query);
          return itemCodeMatch || brandMatch;
        }).toList();
      } else {
        _displayInventories = List.from(_allInventories);
      }
      _startIndex = 0; // Reset to first page after search
    });
  }

  void _resetToFullList() {
    setState(() {
      _searchController.clear();
      _displayInventories = List.from(_allInventories);
      _startIndex = 0;
    });
  }

  void nextPage() {
    setState(() {
      if (_startIndex + _rowsPerPage < _displayInventories.length) {
        _startIndex += _rowsPerPage;
      }
    });
  }

  void prevPage() {
    setState(() {
      if (_startIndex - _rowsPerPage >= 0) {
        _startIndex -= _rowsPerPage;
      }
    });
  }

  bool checkIdDuplicate(int id) {
    for (var i in _allInventories) {
      if (id == i.inventoryID) {
        return true;
      }
    }
    return false;
  }

    bool checkItemCodeDuplicate(String code) {
    for (var i in _allInventories) {
      if (code == i.itemCode) {
        return true;
      }
    }
    return false;
  }

  // leave invID 0 if ur in write mode
  void showAddDialogue(String mode, int invID) {
    final formKey = GlobalKey<FormState>();

    final itemCodeController = TextEditingController();
    final brandController = TextEditingController();
    final productDescController = TextEditingController();
    final lotSerialNumController = TextEditingController();
    final expiryDateController = TextEditingController();
    final stocksManilaController = TextEditingController();
    final stocksCebuController = TextEditingController();
    final purchaseOrderRefController = TextEditingController();
    final supplierPackingListController = TextEditingController();
    final drsiReferenceNumberController = TextEditingController();
    final addedByController = TextEditingController();

    bool isWriteMode = false;
    if(mode == "Write"){
      isWriteMode = true;
    }

    showDialog(context: context, 
    builder: (context) {
      return AlertDialog(
        title: Text(isWriteMode ? 'Add Inventory Data' : 'Edit Inventory Data'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [

                  TextFormField(
                    controller: itemCodeController,
                    decoration: InputDecoration(
                      labelText: "Item Code"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || checkItemCodeDuplicate(value)) {
                        return 'Enter a valid item code';
                      } else {
                        return null;
                      }
                    },
                  ),

                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: "Brand"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid brand';
                      } else {
                        return null;
                      }
                    },
                  ),

                  TextFormField(
                    controller: productDescController,
                    decoration: const InputDecoration(
                      labelText: "Product Description"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid Product Description';
                      } else {
                        return null;
                      }
                    },
                    enabled: isWriteMode,
                  ),

                  TextFormField(
                    controller: lotSerialNumController,
                    decoration: const InputDecoration(
                      labelText: "Lot/Serial num"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid brand';
                      } else {
                        return null;
                      }
                    },
                    enabled: isWriteMode,
                  ),

                  TextFormField(
                    controller: expiryDateController,
                    decoration: InputDecoration(
                      labelText: isWriteMode ? "Expiry Date" : "Date & Time added"
                    ),
                    validator: (value) {
                      if (DateTime.tryParse(value.toString()) == null) {
                        return isWriteMode ? 'Enter a valid expiry date' : 'Enter a valid date';
                      } else {
                        return null;
                      }
                    },
                  ),

                  TextFormField(
                    controller: stocksManilaController,
                    decoration: InputDecoration(
                      labelText: isWriteMode ? "Stocks Manila" : "Quantity on hand"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || int.parse(value) < 0) {
                        return isWriteMode ? 'Enter a valid stock number' : 'Enter a valid quantity';
                      } else {
                        return null;
                      }
                    },
                  ),

                  TextFormField(
                    controller: stocksCebuController,
                    decoration: const InputDecoration(
                      labelText: "Stocks Cebu"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || int.parse(value) < 0) {
                        return 'Enter a valid stock number';
                      } else {
                        return null;
                      }
                    },
                    enabled: isWriteMode,
                  ),

                  TextFormField(
                    controller: purchaseOrderRefController,
                    decoration: const InputDecoration(
                      labelText: "Purchase Order Reference"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid Reference';
                      } else {
                        return null;
                      }
                    },
                    enabled: isWriteMode,
                  ),

                  TextFormField(
                    controller: supplierPackingListController,
                    decoration: const InputDecoration(
                      labelText: "Supplier Packing List"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid Packing List';
                      } else {
                        return null;
                      }
                    },
                    enabled: isWriteMode,
                  ),

                  isWriteMode ? SizedBox(): TextFormField(
                    controller: addedByController,
                    decoration: const InputDecoration(
                      labelText: "Added by"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid String';
                      } else {
                        return null;
                      }
                    },
                  ),

                  TextFormField(
                    controller: drsiReferenceNumberController,
                    decoration: const InputDecoration(
                      labelText: "drsi Reference Number"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid Packing List';
                      } else {
                        return null;
                      }
                    },
                    enabled: isWriteMode,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Item newItem = Item(
                itemCode: itemCodeController.text,
                brand: brandController.text,
                productDescription: productDescController.text,
                lotSerialNumber: lotSerialNumController.text,
                expiryDate: DateTime.parse(expiryDateController.text),
                stocksManila: stocksManilaController.text,
                stocksCebu: stocksCebuController.text,
                purchaseOrderReferenceNumber: purchaseOrderRefController.text,
                supplierPackingList: supplierPackingListController.text,
                drsiReferenceNumber: drsiReferenceNumberController.text
              );

              Inventory updatedInventory = Inventory(
                inventoryID: invID,
                itemCode: itemCodeController.text,
                brand: brandController.text,
                quantityOnHand: int.parse(stocksManilaController.text),
                addedBy: addedByController.text,
                dateTimeAdded: expiryDateController.text
              );

              if(mode == "Write") {
                await itemDetailsService.createInventory(newItem);
              } else if(mode == "Edit") {
                await inventoryService.updateInventory(updatedInventory);
              }
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                builder: (BuildContext context) => super.widget));
              },
            child: const Text("Add")
          )
        ],
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final endIndex = (_startIndex + _rowsPerPage > _displayInventories.length)
        ? _displayInventories.length
        : _startIndex + _rowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Data',
          style: TextStyle(
          fontWeight: FontWeight.bold, // This makes the text bold
          ),
        ),
        backgroundColor: Color.fromRGBO(128, 198, 255, 1),
        actions: [
          IconButton(
            onPressed: _resetToFullList,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset List',
          ),
        ],
      ),
      body: Container( 
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/Images/withlogo.png'),
            fit: BoxFit.cover,
          )
        ),
        child:Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 500, right: 500),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromRGBO(250, 249, 246, 1),
                    labelText: 'Search by Item Code or Brand',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : DataTable(                         
                          columns: const [
                            DataColumn(label: Text("")),
                            DataColumn(label: Text("ID")),
                            DataColumn(label: Text("Item Code")),
                            DataColumn(label: Text("Brand")),
                            DataColumn(label: Text("On Hand")),
                            DataColumn(label: Text("Added By")),
                            DataColumn(label: Text("Date Added")),
                          ],
                          rows: _populateRows().isEmpty
                              ? []
                              : _populateRows().sublist(_startIndex, endIndex),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              if (!_isLoading) _buildPaginationControls(endIndex),
              ElevatedButton(onPressed: () {showAddDialogue("Write", 0);}, child: const Text("add data"))
            ],
          ),
        ),
      ),
      )
    );
  }

  List<DataRow> _populateRows() {
    if (_displayInventories.isEmpty) {
      return [
        const DataRow(cells: [
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('No results found')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
        ])
      ];
    }

     int counter = 0;

    return _displayInventories.map((e) {
      return DataRow(cells: [
        DataCell(Row(
          children: [IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await inventoryService.deleteInventory(e.inventoryID!.toInt());
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                  builder: (BuildContext context) => super.widget));
            },
            ),

            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showAddDialogue("Edit", e.inventoryID!.toInt());
              },
            )
            ]
        )),
        DataCell(Text(e.inventoryID.toString())),
        DataCell(Text(e.itemCode)),
        DataCell(Text(e.brand)),
        DataCell(Text(e.quantityOnHand.toString())),
        DataCell(Text(e.addedBy)),
        DataCell(Text(e.dateTimeAdded.toString().split(' ')[0])),
      ],
      color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        final color = counter.isEven ? Color.fromRGBO(200, 230, 255, 1)! : Color.fromRGBO(173, 217, 253, 1);
        counter++;
        return color; 
      }));
    }).toList();
  }

  Widget _buildPaginationControls(int endIndex) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _startIndex == 0 ? null : prevPage,
              tooltip: 'Previous Page',
            ),
            Text(
                '${_displayInventories.isEmpty ? 0 : _startIndex + 1} - $endIndex of ${_displayInventories.length}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  endIndex == _displayInventories.length ? null : nextPage,
              tooltip: 'Next Page',
            ),
          ],
        ),
      ),
    );
  }
}