import 'package:flutter/material.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/services/stock_alert_service.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'; 

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

class StockAlert extends StatefulWidget {
  const StockAlert({super.key});

  @override
  State<StockAlert> createState() => _StockAlertState();
}

class _StockAlertState extends State<StockAlert> {
  List<Inventory> _allStockAlerts = [];
  List<Inventory> _displayStockAlerts = [];
  bool _isLoading = true;

  int _startIndex = 0;
  int _rowsPerPage = 5; 
  final List<int> _rowsPerPageOptions = [5, 10, 25, 50]; 
  final int _showAllValue = -1; 

  @override
  void initState() {
    super.initState();
    _fetchStockAlerts();
  }

  void _fetchStockAlerts() {
    final stockAlertService = StockAlertService();
    stockAlertService.getStockAlerts().then((value) {
      setState(() {
        _allStockAlerts = value;
        _displayStockAlerts = List.from(_allStockAlerts);
        _isLoading = false;
      });
    });
  }

  void nextPage() {
    if (_rowsPerPage == _showAllValue) return; 
    setState(() {
      if (_startIndex + _rowsPerPage < _displayStockAlerts.length) {
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

  void _changeRowsPerPage(int? newRowsPerPage) {
    if (newRowsPerPage == null) return;
    setState(() {
      _rowsPerPage = newRowsPerPage;
      _startIndex = 0; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showAll = _rowsPerPage == _showAllValue;
    final int effectiveRowsPerPage = showAll ? _displayStockAlerts.length : _rowsPerPage;
    final endIndex = (effectiveRowsPerPage > _displayStockAlerts.length - _startIndex)
        ? _displayStockAlerts.length
        : _startIndex + effectiveRowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stock Alerts",
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
            onPressed: _fetchStockAlerts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Alerts',
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
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_displayStockAlerts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "No stock alerts to display.",
                            style: TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), 
                          itemBuilder: (context, index) {
                            final alert = _displayStockAlerts[_startIndex + index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Neumorphic(
                                style: NeumorphicStyle(
                                  depth: 5,
                                  intensity: 0.7,
                                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                                  lightSource: LightSource.topLeft,
                                  color: Colors.white, 
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Item Code: ${alert.itemCode}",
                                        style: const TextStyle(
                                          fontSize: 20, 
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF01579B), 
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Quantity on Hand: ${alert.quantityOnHand}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Inventory ID: ${alert.inventoryID}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: endIndex - _startIndex,
                        ),
                      const SizedBox(height: 16),
                      if (!_isLoading && _displayStockAlerts.isNotEmpty)
                        _buildPaginationControls(endIndex),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int endIndex) {
    final bool showAll = _rowsPerPage == _showAllValue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          NeumorphicText(
            'Entries per page:',
            style: NeumorphicStyle(
              depth: 0, 
              intensity: 0.7,
              lightSource: LightSource.topLeft,
              color: Colors.black87,
            ),
            textStyle: NeumorphicTextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container( 
            constraints: const BoxConstraints(maxWidth: 80), 
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: 2,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<int>( 
                  value: _rowsPerPage,
                  decoration: const InputDecoration( 
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  items: [
                    ..._rowsPerPageOptions.map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.toString()),
                    )),
                    DropdownMenuItem(
                      value: _showAllValue,
                      child: const Text('All'),
                    ),
                  ],
                  onChanged: _changeRowsPerPage,
                  dropdownColor: Colors.white,
                  alignment: Alignment.center,
                  style: TextStyle(
                    color: Color(0xFF01579B),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFF01579B)),
                  iconEnabledColor: const Color(0xFF01579B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          _NeumorphicNavButton(
            icon: Icons.chevron_left,
            enabled: !showAll && _startIndex > 0,
            onPressed: prevPage,
            tooltip: 'Previous Page',
          ),
          const SizedBox(width: 8),

          NeumorphicText(
            '${_displayStockAlerts.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayStockAlerts.length}',
            style: NeumorphicStyle(
              depth: 1,
              intensity: 0.7,
              lightSource: LightSource.topLeft,
              color: Colors.black87,
            ),
            textStyle: NeumorphicTextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 20),

          _NeumorphicNavButton(
            icon: Icons.chevron_right,
            enabled: !showAll && endIndex < _displayStockAlerts.length, 
            onPressed: nextPage,
            tooltip: 'Next Page',
          ),
        ],
      ),
    );
  }
}