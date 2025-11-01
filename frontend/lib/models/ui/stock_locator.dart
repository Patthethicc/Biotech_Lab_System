import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/brand_model.dart';
import 'package:frontend/models/api/stock_locator_model.dart';
import 'package:frontend/services/brand_service.dart';
import 'package:frontend/services/stock_locator_service.dart';

class _NeumorphicNavButton extends StatefulWidget {
  const _NeumorphicNavButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.tooltip,
  });

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
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: NeumorphicButton(
        onPressed: widget.enabled ? widget.onPressed : null,
        tooltip: widget.tooltip,
        style: NeumorphicStyle(
          depth: _isHovered && widget.enabled ? -3 : 3,
          intensity: 0.8,
          surfaceIntensity: 0.5,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
          lightSource: LightSource.topLeft,
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(
          widget.icon,
          color: widget.enabled ? Colors.lightBlue[400] : Colors.grey[700],
          size: 24,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isDelete = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isDelete;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return NeumorphicButton(
      onPressed: isEnabled ? onPressed : null,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 6 : 8,
      ),
      style: NeumorphicStyle(
        depth: isEnabled ? 3 : 0,
        intensity: 0.8,
        surfaceIntensity: 0.5,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
        lightSource: LightSource.topLeft,
        color: isDelete && isEnabled
            ? Colors.red[400]
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
    );
  }
}

class StockLocatorPage extends StatefulWidget {
  const StockLocatorPage({super.key});

  @override
  State<StockLocatorPage> createState() => _StockLocatorPageState();
}

class _StockLocatorPageState extends State<StockLocatorPage> {
  final StockLocatorService _service = StockLocatorService();
  final BrandService _brandService = BrandService();
  final TextEditingController _searchController = TextEditingController();

  List<StockLocator> _allRecords = [];
  List<StockLocator> _displayRecords = [];
  List<BrandModel> _brands = [];
  StockLocator? _selectedEntry;
  BrandModel? _selectedBrandFilter;

  bool _isLoading = true;
  String? _errorMessage;

  int _startIndex = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [10, 25, 50, 100];
  final int _showAllValue = -1;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadInitialData();
    _searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRecords);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndLoadInitialData() async {
    await _loadBrands();

    await _fetchRecords(); 
  }

  Future<void> _fetchRecords() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _selectedEntry = null;
      });
    }
    try {
      final records = await _service.searchStockLocators(
        brand: _selectedBrandFilter?.brandName,
        query: _searchController.text,
      );
      if (mounted) {
        setState(() {
          _allRecords = records;
          _displayRecords = List.from(_allRecords);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Error fetching stock data: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _loadBrands() async {
    try {
      final brands = await _brandService.getBrands();
      if (mounted) {
        setState(() {
          _brands = brands;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() => _errorMessage = 'Failed to load brands: $e');
      }
    }
  }


  void _filterRecords() {
    
    _fetchRecords().then((_) {
      _startIndex = 0;
      _selectedEntry = null;
    });
  }

  void _onEntrySelection(StockLocator entry) {
    setState(() {
      _selectedEntry = (_selectedEntry == entry) ? null : entry;
    });
  }

  void _changeRowsPerPage(int newRowsPerPage) {
    setState(() {
      _rowsPerPage = newRowsPerPage;
      _startIndex = 0;
    });
  }

  void nextPage() {
    if (_rowsPerPage == _showAllValue) return;
    setState(() {
      if (_startIndex + _rowsPerPage < _displayRecords.length) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Locator', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [IconButton(onPressed: _fetchRecords, icon: const Icon(Icons.refresh), tooltip: 'Refresh Data')],
      ),
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('Assets/Images/bg.png'), fit: BoxFit.cover)),
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildActionAndSearchBar(constraints),
                  const SizedBox(height: 16),
                  _buildDataTableContainer(constraints),
                  const SizedBox(height: 16),
                  if (!_isLoading) _buildPaginationControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionAndSearchBar(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 800;
    final selected = _selectedEntry;
  
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 0 : (constraints.maxWidth > 1200 ? 100 : 50)),
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.inventory_2,
            label: 'View & Edit Stock',
            isEnabled: selected != null,
            onPressed: () => _showEditStockDialog(selected!),
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.filter_list,
            label: _selectedBrandFilter?.brandName ?? 'All Brands',
            onPressed: _showBrandFilterDialog,
          ),
          const Spacer(),
          SizedBox(
            height: 40,
            width: isSmallScreen ? 180 : 300,
            child: Neumorphic(
              style: NeumorphicStyle(depth: -4, color: Colors.white, boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30))),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF01579B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none, isDense: true),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(onTap: () => _searchController.clear(), child: const Icon(Icons.clear, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTableContainer(BoxConstraints constraints) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -5,
        intensity: 0.7,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        lightSource: LightSource.topLeft,
        color: Colors.blue[400],
      ),
      child: _isLoading
          ? const Center(child: Padding(padding: EdgeInsets.all(50.0), child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))))
          : SizedBox(
              width: double.infinity,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor: WidgetStateProperty.all(Colors.blue[400]),
                  headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 60,
                  columns: const [
                    DataColumn(label: Expanded(child: Text('Item Code', overflow: TextOverflow.ellipsis))),
                    DataColumn(label: Expanded(child: Text('Brand', overflow: TextOverflow.ellipsis))),
                    DataColumn(label: Expanded(child: Text('Product Description', overflow: TextOverflow.ellipsis))),
                    DataColumn(label: Expanded(child: Text('Total Stock', overflow: TextOverflow.ellipsis)), numeric: true),
                  ],
                  rows: _buildDataRows(constraints.maxWidth),
                ),
              ),
            )
    );
  }

  List<DataRow> _buildDataRows(double screenWidth) {
    final bool showAll = _rowsPerPage == _showAllValue;
    final int effectiveRowsPerPage = showAll ? _displayRecords.length : _rowsPerPage;
    final endIndex = showAll ? _displayRecords.length : (_startIndex + effectiveRowsPerPage > _displayRecords.length ? _displayRecords.length : _startIndex + effectiveRowsPerPage);
    
    if (_displayRecords.isEmpty) {
      return [const DataRow(cells: [DataCell(Text('')), DataCell(Text('No results found', style: TextStyle(color: Colors.white))), DataCell(Text('')), DataCell(Text(''))])];
    }

    final recordsToShow = _displayRecords.sublist(_startIndex, endIndex);
    return recordsToShow.map<DataRow>((record) {
      final isSelected = _selectedEntry == record;
      final rowColor = _displayRecords.indexOf(record).isEven ? const Color.fromRGBO(241, 245, 255, 1) : const Color.fromRGBO(230, 240, 255, 1);
      
      return DataRow(
        selected: isSelected,
        onSelectChanged: (_) => _onEntrySelection(record),
        color: WidgetStateProperty.all(rowColor),
        cells: [
          DataCell(Expanded(child: Text(record.itemCode, overflow: TextOverflow.ellipsis))),
          DataCell(Expanded(child: Text(record.brand, overflow: TextOverflow.ellipsis))),
          DataCell(Expanded(child: Text(record.productDescription, overflow: TextOverflow.ellipsis, maxLines: 2))),
          DataCell(Expanded(child: Text(record.totalStock.toString()))),
        ],
      );
    }).toList();
  }

  Widget _buildPaginationControls() {
    final bool showAll = _rowsPerPage == _showAllValue;
    final int effectiveRowsPerPage = showAll ? _displayRecords.length : _rowsPerPage;
    final endIndex = showAll ? _displayRecords.length : (_startIndex + effectiveRowsPerPage > _displayRecords.length ? _displayRecords.length : _startIndex + effectiveRowsPerPage);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: isSmallScreen ? 8 : 16,
      runSpacing: 8,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(isSmallScreen ? 'Per page:' : 'Entries per page:'),
          const SizedBox(width: 8),
          Neumorphic(
            style: NeumorphicStyle(depth: 2, boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)), color: Colors.white),
            child: DropdownButtonHideUnderline(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<int>(
                  value: _rowsPerPage,
                  items: [
                    ..._rowsPerPageOptions.map((v) => DropdownMenuItem<int>(value: v, child: Text(v.toString()))),
                    DropdownMenuItem<int>(value: _showAllValue, child: Text(isSmallScreen ? 'All' : 'Show All')),
                  ],
                  onChanged: (v) { if (v != null) _changeRowsPerPage(v); },
                  style: const TextStyle(color: Color(0xFF01579B), fontWeight: FontWeight.w500),
                  dropdownColor: Colors.white,
                  iconEnabledColor: const Color(0xFF01579B),
                ),
              ),
            ),
          ),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _NeumorphicNavButton(icon: Icons.chevron_left, enabled: !showAll && _startIndex > 0, onPressed: prevPage, tooltip: 'Previous Page'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              showAll ? 'Showing all ${_displayRecords.length} entries' : '${_displayRecords.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayRecords.length}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          _NeumorphicNavButton(icon: Icons.chevron_right, enabled: !showAll && endIndex < _displayRecords.length, onPressed: nextPage, tooltip: 'Next Page'),
        ]),
      ],
    );
  }

  void _showBrandFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Brand'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _brands.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text('All Brands', style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      setState(() => _selectedBrandFilter = null);
                      _filterRecords();
                      Navigator.of(context).pop();
                    },
                  );
                }
                final brand = _brands[index - 1];
                return ListTile(
                  title: Text(brand.brandName),
                  onTap: () {
                    setState(() => _selectedBrandFilter = brand);
                    _filterRecords();
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            )
          ],
        );
      },
    );
  }

  void _showEditStockDialog(StockLocator stock) {
    showDialog(
      context: context,
      builder: (context) => _EditStockDialog(
        stockLocator: stock,
        onUpdate: (updatedStock) async { 
          final updatedRecord = await _service.updateStockLocator(updatedStock); 
          if (updatedRecord != null) {
            await _fetchRecords();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock updated successfully!'), backgroundColor: Colors.green));
            }
          } else {
             if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update stock.'), backgroundColor: Colors.red));
            }
          }
        },
      ),
    );
  }
}

class _EditStockDialog extends StatefulWidget {
  const _EditStockDialog({required this.stockLocator, required this.onUpdate});

  final StockLocator stockLocator;
  final Future<void> Function(StockLocator) onUpdate;

  @override
  State<_EditStockDialog> createState() => _EditStockDialogState();
}

class _EditStockDialogState extends State<_EditStockDialog> {
  late final Map<String, TextEditingController> _controllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'lazcanoRef1': TextEditingController(text: widget.stockLocator.lazcanoRef1.toString()),
      'lazcanoRef2': TextEditingController(text: widget.stockLocator.lazcanoRef2.toString()),
      'gandiaColdStorage': TextEditingController(text: widget.stockLocator.gandiaColdStorage.toString()),
      'gandiaRef1': TextEditingController(text: widget.stockLocator.gandiaRef1.toString()),
      'gandiaRef2': TextEditingController(text: widget.stockLocator.gandiaRef2.toString()),
      'limbaga': TextEditingController(text: widget.stockLocator.limbaga.toString()),
      'cebu': TextEditingController(text: widget.stockLocator.cebu.toString()),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _handleSave() async {
    setState(() => _isSaving = true);
    final updatedStock = widget.stockLocator.copyWith(newValues: {
      'lazcanoRef1': int.tryParse(_controllers['lazcanoRef1']!.text) ?? widget.stockLocator.lazcanoRef1,
      'lazcanoRef2': int.tryParse(_controllers['lazcanoRef2']!.text) ?? widget.stockLocator.lazcanoRef2,
      'gandiaColdStorage': int.tryParse(_controllers['gandiaColdStorage']!.text) ?? widget.stockLocator.gandiaColdStorage,
      'gandiaRef1': int.tryParse(_controllers['gandiaRef1']!.text) ?? widget.stockLocator.gandiaRef1,
      'gandiaRef2': int.tryParse(_controllers['gandiaRef2']!.text) ?? widget.stockLocator.gandiaRef2,
      'limbaga': int.tryParse(_controllers['limbaga']!.text) ?? widget.stockLocator.limbaga,
      'cebu': int.tryParse(_controllers['cebu']!.text) ?? widget.stockLocator.cebu,
    });
    
    await widget.onUpdate(updatedStock);

    if(mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Stock for ${widget.stockLocator.itemCode}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.stockLocator.productDescription, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            _buildStockField('Lazcano Ref 1', _controllers['lazcanoRef1']!),
            _buildStockField('Lazcano Ref 2', _controllers['lazcanoRef2']!),
            _buildStockField('Gandia (Cold Storage)', _controllers['gandiaColdStorage']!),
            _buildStockField('Gandia (Ref 1)', _controllers['gandiaRef1']!),
            _buildStockField('Gandia (Ref 2)', _controllers['gandiaRef2']!),
            _buildStockField('Limbaga', _controllers['limbaga']!),
            _buildStockField('Cebu', _controllers['cebu']!),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildStockField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}