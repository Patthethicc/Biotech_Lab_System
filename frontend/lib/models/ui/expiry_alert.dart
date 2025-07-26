import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/models/api/item_model.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:frontend/services/item_details_service.dart';
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
  bool _lastEnabled = false;

  @override
  void didUpdateWidget(covariant _NeumorphicNavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _isHovered = false;
      _lastEnabled = widget.enabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled;
    _lastEnabled = isEnabled;

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
          depth: _isHovered && isEnabled ? -3 : 3,  // Depth reset when not hovered
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

class ExpiryAlert extends StatefulWidget {
  const ExpiryAlert({super.key});

  @override
  State<ExpiryAlert> createState() => _ExpiryAlertState();
}

class _ExpiryAlertState extends State<ExpiryAlert> {
  final itemDetailsService = ItemDetailsService();

  List<Item> _allExpiryAlerts = [];
  List<Item> _displayAlerts = [];
  bool _isLoading = true;
  bool _isHovered = false;

  int _startIndex = 0;
  final int _rowsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchData() {
    itemDetailsService.getExpiringItems(7).then((value) {
      setState(() {
        _allExpiryAlerts = value;
        _displayAlerts = List.from(_allExpiryAlerts);
        _isLoading = false;
      });
    });
  }

  void _resetToFullList() {
    setState(() {
      _displayAlerts = List.from(_allExpiryAlerts);
      _startIndex = 0;
    });
  }

  void nextPage() {
    setState(() {
      if (_startIndex + _rowsPerPage < _displayAlerts.length) {
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
    final endIndex = (_startIndex + _rowsPerPage > _displayAlerts.length)
        ? _displayAlerts.length
        : _startIndex + _rowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expiration Alerts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Set text color explicitly if background is transparent
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove drop shadow
        foregroundColor: Colors.black, // For icon and text colors
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
            image: AssetImage('Assets/Images/bg.png'),
            fit: BoxFit.cover,
          )
        ),
        child:Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: -5,
                      intensity: 0.7,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                      lightSource: LightSource.topLeft,
                      shadowDarkColorEmboss: const Color.fromARGB(197, 93, 126, 153),
                      // shadowLightColorEmboss: const Color.fromARGB(197, 228, 237, 244),
                      color: Colors.blue[400],
                    ),
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : DataTable(                         
                          columns: const [
                            DataColumn(label: Text("Item Code", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Brand", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Description", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("lot Serial Number", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Stocks Manila", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Stocks Cebu", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Expiration Date", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Days till expiration", style: TextStyle(color: Colors.white))),
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
      )
    );
  }

  List<DataRow> _populateRows() {
    if (_displayAlerts.isEmpty) {
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

    return _displayAlerts.map((e) {
      return DataRow(cells: [
        DataCell(Text(e.itemCode)),
        DataCell(Text(e.brand)),
        DataCell(Text(e.productDescription)),
        DataCell(Text(e.lotSerialNumber)),
        DataCell(Text(e.stocksManila)),
        DataCell(Text(e.stocksCebu)),
        DataCell(Text(e.expiryDate.toString())),
        DataCell(Text(e.expiryDate!.difference(DateTime.now()).inDays.toString(), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)),
      ],
      color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        final subtleBlueTint1 = Color.fromRGBO(241, 245, 255, 1); // Light blue
        final subtleBlueTint2 = Color.fromRGBO(230, 240, 255, 1); // Even lighter blue

        final color = counter.isEven ? subtleBlueTint1 : subtleBlueTint2;
        counter++;
        return color;
      }));
    }).toList();
  }

  Padding _buildPaginationControls(int endIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _NeumorphicNavButton(
            icon: Icons.chevron_left,
            enabled: _startIndex > 0,
            onPressed: prevPage,
            tooltip: 'Previous Page',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${_displayAlerts.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayAlerts.length}',
            ),
          ),
          _NeumorphicNavButton(
            icon: Icons.chevron_right,
            enabled: endIndex < _displayAlerts.length,
            onPressed: nextPage,
            tooltip: 'Next Page',
          ),
        ],
      ),
    );
  }
}