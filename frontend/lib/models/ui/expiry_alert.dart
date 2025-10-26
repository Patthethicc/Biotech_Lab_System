// import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:frontend/models/api/item_loc.dart';
import 'package:frontend/models/api/inventory_payload.dart';

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
  final inventoryService = InventoryService();

  List<InventoryPayload> _allExpiryAlerts = [];
  List<InventoryPayload> _displayAlerts = [];
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
    inventoryService.getExpiringItems(7).then((value) {
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

    final allLocations = _allExpiryAlerts
        .expand((payload) => payload.locations.map((loc) => loc.locationName))
        .toSet()
        .where((locName) => locName != null)
        .cast<String>()
        .toList();

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
                          headingRowColor: WidgetStateProperty.all(Colors.blue[400]),
                          columns: [
                            const DataColumn(
                                label: Text("Item Code",
                                    style: TextStyle(color: Colors.white))),
                            const DataColumn(
                                label: Text("Brand",
                                    style: TextStyle(color: Colors.white))),
                            const DataColumn(
                                label: Text("Description",
                                    style: TextStyle(color: Colors.white))),
                            const DataColumn(
                                label: Text("Lot Number",
                                    style: TextStyle(color: Colors.white))),
                            ...allLocations.map((loc) => DataColumn(
                                label: Text("Stocks $loc",
                                    style: const TextStyle(color: Colors.white)))),
                            const DataColumn(
                                label: Text("Expiry Date",
                                    style: TextStyle(color: Colors.white))),
                            const DataColumn(
                                label: Text("Days Till Expiry",
                                    style: TextStyle(color: Colors.white))),
                          ],
                          rows: _displayAlerts.isEmpty
                            ? [
                                const DataRow(cells: [
                                  DataCell(Text('No results found')),
                                ])
                              ]
                            : _populateRows(allLocations)
                                .sublist(_startIndex, endIndex),
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

  List<DataRow> _populateRows(List<String> allLocations) {
    int counter = 0;

    return _displayAlerts.map((payload) {
      final inv = payload.inventory;

      final daysTillExpiry =
          DateTime.parse(inv.expiry).difference(DateTime.now()).inDays;

      final locationCells = allLocations.map((locName) {
        final location = payload.locations.firstWhere(
          (loc) => loc.locationName?.toLowerCase() == locName.toLowerCase(),
          orElse: () => ItemLoc(locationId: 0, locationName: locName, quantity: 0),
        );
        return DataCell(Text(location.quantity.toString()));
      }).toList();

      return DataRow(
        color: WidgetStateProperty.resolveWith<Color>((_) {
          final color = counter.isEven
              ? const Color.fromRGBO(241, 245, 255, 1)
              : const Color.fromRGBO(230, 240, 255, 1);
          counter++;
          return color;
        }),
        cells: [
          DataCell(Text(inv.itemCode)),
          DataCell(Text(inv.brandId.toString())), // TODO: convert to brandName given brandId
          DataCell(Text(inv.itemDescription)),
          DataCell(Text(inv.lotNum.toString())),
          ...locationCells,
          DataCell(Text(inv.expiry)),
          DataCell(
            Text(
              '$daysTillExpiry days',
              style: TextStyle(
                color: daysTillExpiry < 30 ? Colors.red : Colors.black,
                fontWeight:
                    daysTillExpiry < 30 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      );
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