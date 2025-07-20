import 'package:flutter/material.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/services/inventory_service.dart';

class DataTemplate extends StatefulWidget {
  const DataTemplate({super.key});

  @override
  State<DataTemplate> createState() => _DataTemplateState();
}

class _DataTemplateState extends State<DataTemplate> {
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
    final inventoryService = InventoryService();
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

  @override
  Widget build(BuildContext context) {
    final endIndex = (_startIndex + _rowsPerPage > _displayInventories.length)
        ? _displayInventories.length
        : _startIndex + _rowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Data'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: _resetToFullList,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset List',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
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
            ],
          ),
        ),
      ),
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
    return _displayInventories.map((e) {
      return DataRow(cells: [
        DataCell(Text(e.inventoryID.toString())),
        DataCell(Text(e.itemCode)),
        DataCell(Text(e.brand)),
        DataCell(Text(e.quantityOnHand.toString())),
        DataCell(Text(e.addedBy)),
        DataCell(Text(e.dateTimeAdded.toString().split(' ')[0])),
      ]);
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