import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:intl/intl.dart';


class _NeumorphicNavButton extends StatefulWidget {
  const _NeumorphicNavButton({
    Key? key,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.tooltip,
  }) : super(key: key);

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<_NeumorphicNavButton> createState() => _NeumorphicNavButtonState();
}

class _NeumorphicNavButtonState extends State<_NeumorphicNavButton> {
  bool _isHovered = false;

  @override
  void didUpdateWidget(covariant _NeumorphicNavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _isHovered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled;

    return MouseRegion(
      onEnter: (_) {
        if (isEnabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isEnabled) setState(() => _isHovered = false);
      },
      child: NeumorphicButton(
        onPressed: isEnabled ? widget.onPressed : null,
        style: NeumorphicStyle(
          depth: _isHovered && isEnabled ? -3 : 3,
          intensity: 0.8,
          surfaceIntensity: 0.5,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
          lightSource: LightSource.topLeft,
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(
          widget.icon,
          color: isEnabled ? Colors.lightBlue[400] : Colors.grey[700],
          size: 24,
        ),
      ),
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _searchController = TextEditingController();
  List<Inventory> _allInventories = [];
  List<Inventory> _displayInventories = [];
  Set<Inventory> _selectedInventories = {};
  Inventory? _selectedInventoryForEdit;

  bool _isLoading = true;
  bool _selectAll = false;
  bool _isHovered = false;

  int _startIndex = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [10, 25, 50, 100];
  final int _showAllValue = -1;

  @override
  void initState() {
    super.initState();
    _fetchInventories();
    _searchController.addListener(_filterInventories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInventories);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetchedInventories = await _inventoryService.getInventories();
      setState(() {
        _allInventories = fetchedInventories;
        _displayInventories = List.from(_allInventories);
        _isLoading = false;
        _clearSelection();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showDialog('Error', 'Failed to load purchase orders: $e');
      }
    }
  }

  void _filterInventories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        _displayInventories = _allInventories.where((inventory) {
          return inventory.itemCode!.toLowerCase().contains(query);
        }).toList();
      } else {
        _displayInventories = List.from(_allInventories);
      }
      _clearSelection();
      _startIndex = 0;
    });
  }
  
  void _clearSelection() {
      _selectedInventories.clear();
      _selectedInventoryForEdit = null;
      _selectAll = false;
  }

  void _resetToFullList() {
    setState(() {
      _searchController.clear();
      _displayInventories = List.from(_allInventories);
      _startIndex = 0;
      _clearSelection();
    });
  }

  void nextPage() {
    if (_rowsPerPage == _showAllValue) return;
    setState(() {
      if (_startIndex + _rowsPerPage < _displayInventories.length) {
        _startIndex += _rowsPerPage;
      }
    });
  }

  void prevPage() {
    if (_rowsPerPage == _showAllValue) return;
    setState(() {
      if (_startIndex - _rowsPerPage >= 0) {
        _startIndex -= _rowsPerPage;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectAll) {
        _clearSelection();
      } else {
        _selectedInventories = Set.from(_displayInventories);
        _selectAll = true;
        _selectedInventoryForEdit = _selectedInventories.isNotEmpty ? _selectedInventories.first : null;
      }
    });
  }

  void _toggleOrderSelection(Inventory inventory) {
    setState(() {
      if (_selectedInventories.contains(inventory)) {
        _selectedInventories.remove(inventory);
        if (_selectedInventoryForEdit == inventory) {
          _selectedInventoryForEdit = _selectedInventories.isNotEmpty ? _selectedInventories.first : null;
        }
      } else {
        _selectedInventories.add(inventory);
        _selectedInventoryForEdit = inventory;
      }
      _selectAll = _selectedInventories.length == _displayInventories.length && _displayInventories.isNotEmpty;
    });
  }

  void _changeRowsPerPage(int newRowsPerPage) {
    setState(() {
      _rowsPerPage = newRowsPerPage;
      _startIndex = 0;
       _selectAll = _selectedInventories.length == _displayInventories.length && _displayInventories.isNotEmpty;
    });
  }

  
  void _showEditDialog(Inventory inventory) {
    final _formKey = GlobalKey<FormState>();
    final inventoryIdController = TextEditingController(text: inventory.inventoryID.toString());
    final itemController = TextEditingController(text: inventory.itemCode);
    final brandController = TextEditingController(text: inventory.brand);
    final descriptionController = TextEditingController(text: inventory.productDescription);
    final lotSerialController = TextEditingController(text: inventory.lotSerialNumber);
    final costController = TextEditingController(text: inventory.cost.toString());
    final expirationDate = TextEditingController(text: inventory.expiryDate);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit PO: ${inventory.itemCode}'),
          content: Form(
            key: _formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
                return SingleChildScrollView(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(controller: itemController, readOnly: true, decoration: const InputDecoration(labelText: 'Item Code', filled: true)),
                        const SizedBox(height: 16),
                        TextFormField(controller: brandController, decoration: const InputDecoration(labelText: 'Brand', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Product Description', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: lotSerialController, decoration: const InputDecoration(labelText: 'Lot/Serial Number', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: costController, decoration: const InputDecoration(labelText: 'Cost', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(context: context, initialDate: DateTime.parse(expirationDate.text) ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                            if (picked != null) setStateDialog(() => expirationDate.text = picked.toString());
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: 'Expiry Date', prefixIcon: const Icon(Icons.calendar_today), border: const OutlineInputBorder(), errorText: expirationDate == null ? 'Required' : null),
                            child: Text(expirationDate != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(expirationDate.text)) : 'Select Expiry Date'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && expirationDate != null) {
                  final updatedInventory = Inventory(
                    itemCode: itemController.text,
                    brand: brandController.text,
                    productDescription: descriptionController.text,
                    lotSerialNumber: lotSerialController.text,
                    cost: double.parse(costController.text),
                    expiryDate: expirationDate.text,
                  );
                  try {
                    await _inventoryService.updateInventory(updatedInventory);
                    if (mounted) {
                      Navigator.pop(context);
                      _showDialog('Success', 'Inventory updated.');
                      _fetchInventories();
                    }
                  } catch (e) {
                    _showDialog('Error', 'Failed to update: $e');
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    final selectedCount = _selectedInventories.length;
    final singleId = _selectedInventories.isNotEmpty ? _selectedInventories.first.itemCode : "";
    final message = selectedCount > 1
        ? 'Are you sure you want to delete $selectedCount selected Inventories? This action cannot be undone.'
        : 'Are you sure you want to delete the Inventory with Code: $singleId? This action cannot be undone.';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSelectedInventories();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSelectedInventories() async {
    final inventoriesToDelete = List.from(_selectedInventories);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Deleting...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait while the inventories are being deleted.'),
            ],
          ),
        );
      },
    );

    try {
      int successCount = 0;
      List<String> errors = [];

      for (Inventory inventory in inventoriesToDelete) {
        try {
          await _inventoryService.deleteInventory(inventory.inventoryID!.toInt());
          successCount++;
        } catch (e) {
          errors.add('Error deleting ${inventory.itemCode}: $e');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      await _fetchInventories();

      if (!mounted) return;

      String message;
      if (errors.isEmpty) {
        message = 'Successfully deleted $successCount order(s)!';
      } else {
        message = 'Deleted $successCount order(s) successfully.\n\nErrors:\n${errors.join('\n')}';
      }

      _showDialog(errors.isEmpty ? 'Success' : 'Partial Success', message);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showDialog('Error', 'An error occurred during deletion: $e');
    }
  }
  
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final bool showAll = _rowsPerPage == _showAllValue;
    final int effectiveRowsPerPage = showAll ? _displayInventories.length : _rowsPerPage;
    final endIndex = showAll
        ? _displayInventories.length
        : (_startIndex + effectiveRowsPerPage > _displayInventories.length)
            ? _displayInventories.length
            : _startIndex + effectiveRowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Purchase Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _resetToFullList,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset List',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/Images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
             final screenWidth = constraints.maxWidth;
            double horizontalPadding = 16.0;
            
            if (screenWidth > 1400) {
              horizontalPadding = 32.0;
            } else if (screenWidth > 1000) {
              horizontalPadding = 24.0;
            } else if (screenWidth < 600) {
              horizontalPadding = 8.0;
            }

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 800;
                        final isMediumScreen = constraints.maxWidth < 1200;
                        return Padding(
                           padding: EdgeInsets.only(
                            bottom: 16.0, 
                            left: isSmallScreen ? 16 : (isMediumScreen ? 50 : 100),
                            right: isSmallScreen ? 16 : (isMediumScreen ? 50 : 100),
                           ),
                           child: isSmallScreen
                            ? Column(
                              children: [
                                 SizedBox(
                                  height: 40,
                                  child: Neumorphic(
                                    style: NeumorphicStyle(
                                      depth: -4,
                                      color: Colors.white,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.search, color: Color(0xFF01579B)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            decoration: const InputDecoration(
                                              hintText: 'Search by Inventory item Code...',
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        if (_searchController.text.isNotEmpty)
                                          GestureDetector(
                                            onTap: () {
                                              _searchController.clear();
                                            },
                                            child: const Icon(Icons.clear, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildResponsiveButton(
                                      _selectAll ? 'Deselect' : 'Select All',
                                      _selectAll ? Icons.deselect : Icons.select_all,
                                      _toggleSelectAll,
                                      isPressed: _selectAll,
                                      isSmall: true,
                                    ),
                                    _buildResponsiveButton(
                                      'Edit',
                                      Icons.edit,
                                      _selectedInventoryForEdit == null 
                                          ? null 
                                          : () => _showEditDialog(_selectedInventoryForEdit!),
                                      isEnabled: _selectedInventoryForEdit != null,
                                      isSmall: true,
                                    ),
                                     _buildResponsiveButton(
                                      'Delete',
                                      Icons.delete,
                                      _selectedInventories.isEmpty
                                          ? null
                                          : () => _showDeleteConfirmationDialog(),
                                      isEnabled: _selectedInventories.isNotEmpty,
                                      isDelete: true,
                                      isSmall: true,
                                    ),
                                  ],
                                )
                              ],
                           )
                           : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: SizedBox(
                                      height: 40,
                                      child: Neumorphic(
                                        style: NeumorphicStyle(
                                          depth: -4,
                                          color: Colors.white,
                                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.search, color: Color(0xFF01579B)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                decoration: InputDecoration(
                                                  hintText: isMediumScreen 
                                                      ? 'Search...' 
                                                      : 'Search by Inventory Item Code',
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                ),
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            if (_searchController.text.isNotEmpty)
                                              GestureDetector(
                                                onTap: () {
                                                  _searchController.clear();
                                                },
                                                child: const Icon(Icons.clear, color: Colors.grey),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                MouseRegion(
                                  child: NeumorphicButton(
                                    onPressed: _toggleSelectAll,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectAll ? -4 : 4,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectAll ? Colors.blue[100] : Colors.white,
                                    ),
                                    child: Text(
                                      _selectAll 
                                          ? (isMediumScreen ? 'Deselect' : 'Deselect All')
                                          : (isMediumScreen ? 'Select' : 'Select All'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectAll ? const Color(0xFF01579B) : const Color(0xFF01579B),
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                 MouseRegion(
                                  child: NeumorphicButton(
                                    onPressed: _selectedInventoryForEdit == null 
                                        ? null 
                                        : () {
                                            _showEditDialog(_selectedInventoryForEdit!);
                                          },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedInventoryForEdit != null ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedInventoryForEdit != null ? Colors.white : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Edit'
                                          : (_selectedInventories.length > 1 ? 'Edit First Selected' : 'Edit Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedInventoryForEdit != null ? const Color(0xFF01579B) : Colors.grey[600],
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                MouseRegion(
                                  child: NeumorphicButton(
                                    onPressed: _selectedInventories.isEmpty
                                        ? null
                                        : () {
                                            _showDeleteConfirmationDialog();
                                          },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedInventories.isNotEmpty ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedInventories.isNotEmpty ? const Color.fromARGB(255, 175, 54, 46) : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Delete'
                                          : (_selectedInventories.length > 1 ? 'Delete Selected (${_selectedInventories.length})' : 'Delete Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedInventories.isNotEmpty ? Colors.white : Colors.grey[600],
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                           ),
                        );
                      },
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              depth: -5,
                              intensity: 0.7,
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                              lightSource: LightSource.topLeft,
                              shadowDarkColorEmboss: const Color.fromARGB(197, 93, 126, 153),
                              color: Colors.blue[400],
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(50.0),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                      ),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                           dataTableTheme: DataTableThemeData(
                                            checkboxHorizontalMargin: 0.0,
                                            columnSpacing: constraints.maxWidth > 1200 ? 12.0 : 6.0,
                                            horizontalMargin: constraints.maxWidth > 800 ? 4.0 : 2.0,
                                          ),
                                          checkboxTheme: CheckboxThemeData(
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        child: DataTable(
                                          showCheckboxColumn: true,
                                          columnSpacing: constraints.maxWidth > 1200 ? 12.0 : 6.0,
                                          horizontalMargin: constraints.maxWidth > 800 ? 4.0 : 2.0,
                                          checkboxHorizontalMargin: 0.0,
                                          dataRowMaxHeight: 48.0,
                                          dataRowMinHeight: 40.0,
                                          headingRowHeight: constraints.maxWidth > 600 ? 52.0 : 44.0,
                                          columns: _buildDataColumns(constraints.maxWidth),
                                          rows: _displayInventories.isEmpty
                                              ? [
                                                  const DataRow(cells: [
                                                    DataCell(Text('')),
                                                    DataCell(Text('')),
                                                    DataCell(Text('')),
                                                    DataCell(Text('')),
                                                    DataCell(Text('')),
                                                    DataCell(Text('')),
                                                    DataCell(Text('No results found', style: TextStyle(color: Colors.white))),
                                                    DataCell(Text('')),
                                                    DataCell(Text('')),
                                                  ])
                                                ]
                                              : _buildDataRows(formatter, endIndex, constraints.maxWidth),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (!_isLoading)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 600;
                          return Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: isSmallScreen ? 8 : 16,
                            runSpacing: 8,
                            children: [
                              Text(
                                isSmallScreen ? 'Per page:' : 'Entries per page:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                              Container(
                                height: isSmallScreen ? 30 : 35,
                                child: NeumorphicButton(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8 : 12, 
                                    vertical: isSmallScreen ? 4 : 6,
                                  ),
                                  style: NeumorphicStyle(
                                    depth: 2,
                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _rowsPerPage,
                                      items: [
                                        ..._rowsPerPageOptions.map((int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(value.toString()),
                                          );
                                        }),
                                        DropdownMenuItem<int>(
                                          value: _showAllValue,
                                          child: Text(isSmallScreen ? 'All' : 'Show All'),
                                        ),
                                      ],
                                      onChanged: (int? newValue) {
                                        if (newValue != null) {
                                          _changeRowsPerPage(newValue);
                                        }
                                      },
                                      style: TextStyle(
                                        color: Color(0xFF01579B),
                                        fontWeight: FontWeight.w500,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                      dropdownColor: Colors.white,
                                      iconEnabledColor: const Color(0xFF01579B),
                                    ),
                                  ),
                                ),
                              ),
                              _buildPaginationControls(endIndex),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns(double screenWidth) {
    final headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.white);

    return <DataColumn>[
      DataColumn(label: Text('Inventory ID', style: headerStyle)), // inventoryID
      DataColumn(label: Text('Item Code', style: headerStyle)), // itemCode
      DataColumn(label: Text('Brand', style: headerStyle)), // brand
      DataColumn(label: Text('Description', style: headerStyle)), // productDescription
      DataColumn(label: Text('Lot Number', style: headerStyle)), // lotSerialNumber
      DataColumn(label: Text('Expiry Date', style: headerStyle)), // expiryDate
      DataColumn(label: Text('Stocks Manila', style: headerStyle,)), // stocksManila
      DataColumn(label: Text('Stocks Cebu', style: headerStyle)), // stocksCebu
      DataColumn(label: Text('Quantity on Hand', style: headerStyle)), // quantityOnHand
      DataColumn(label: Text('Added By', style: headerStyle)), // addedBy
      DataColumn(label: Text('Date & Time Added', style: headerStyle)) // dateTimeAdded
    ];
  }
    List<DataRow> _buildDataRows(DateFormat formatter, int endIndex, double screenWidth) {
    int counter = 0;
    final bool showAll = _rowsPerPage == _showAllValue;
    final recordsToShow = showAll ? _displayInventories : _displayInventories.sublist(_startIndex, endIndex);

    return recordsToShow.map<DataRow>((inventory) {
      final isSelected = _selectedInventories.contains(inventory);
      final rowColor = counter.isEven ? const Color.fromRGBO(241, 245, 255, 1) : const Color.fromRGBO(230, 240, 255, 1);
      counter++;

      return DataRow(
        selected: isSelected,
        onSelectChanged: (bool? selected) => _toggleOrderSelection(inventory),
        color: WidgetStateProperty.all(rowColor),
        cells: [
          DataCell(Text(inventory.inventoryID.toString())),
          DataCell(Text(inventory.itemCode.toString())),
          DataCell(Text(inventory.brand)),
          DataCell(Text(inventory.productDescription)),
          DataCell(Text(inventory.lotSerialNumber)),
          DataCell(Text(inventory.expiryDate)),
          DataCell(Text(inventory.stocksManila.toString())),
          DataCell(Text(inventory.stocksCebu.toString())),
          DataCell(Text(inventory.quantityOnHand.toString())),
          DataCell(Text(inventory.addedBy.toString())),
          DataCell(Text(inventory.dateTimeAdded.toString())),
        ],
      );
    }).toList();
  }

  Widget _buildPaginationControls(int endIndex) {
     final bool showAll = _rowsPerPage == _showAllValue;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NeumorphicNavButton(
          icon: Icons.chevron_left,
          enabled: !showAll && _startIndex > 0,
          onPressed: prevPage,
          tooltip: 'Previous Page',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            showAll 
                ? 'Showing all ${_displayInventories.length} orders'
                : '${_displayInventories.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayInventories.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        _NeumorphicNavButton(
          icon: Icons.chevron_right,
          enabled: !showAll && endIndex < _displayInventories.length,
          onPressed: nextPage,
          tooltip: 'Next Page',
        ),
      ],
    );
  }

   Widget _buildResponsiveButton(
    String label,
    IconData icon,
    VoidCallback? onPressed, {
    bool isEnabled = true,
    bool isPressed = false,
    bool isHovered = false,
    bool isDelete = false,
    bool isSmall = false,
  }) {
    return MouseRegion(
      child: NeumorphicButton(
        onPressed: isEnabled ? onPressed : null,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 6 : 8,
        ),
        style: NeumorphicStyle(
          depth: isEnabled ? (isPressed ? -2 : 2) : 1,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(isSmall ? 20 : 25),
          ),
          lightSource: LightSource.topLeft,
          color: isDelete && isEnabled
              ? const Color.fromARGB(255, 175, 54, 46)
              : isPressed && isEnabled
                  ? Colors.blue[100]
                  : isEnabled
                      ? Colors.white
                      : Colors.grey[300],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmall ? 16 : 18,
              color: isDelete && isEnabled
                  ? Colors.white
                  : isEnabled
                      ? const Color(0xFF01579B)
                      : Colors.grey[600],
            ),
            if (label.isNotEmpty) ...[
              SizedBox(width: isSmall ? 4 : 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDelete && isEnabled
                      ? Colors.white
                      : isEnabled
                          ? const Color(0xFF01579B)
                          : Colors.grey[600],
                  fontSize: isSmall ? 12 : 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}