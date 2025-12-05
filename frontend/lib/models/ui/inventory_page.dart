// import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/existing_user.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/models/api/purchase_order.dart';
import 'package:frontend/models/api/item_loc.dart';
import 'package:frontend/models/api/inventory_payload.dart';
import 'package:frontend/services/brand_service.dart';
import 'package:frontend/services/existing_user_service.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:frontend/services/location_service.dart';
import 'package:frontend/services/purchase_order_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/api/location.dart';
import 'package:flutter/gestures.dart';

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
  final PurchaseOrderService _poService = PurchaseOrderService();
  final BrandService _brandService = BrandService();
  final LocationService _locationService = LocationService();
  final ExistingUserService _userService = ExistingUserService();
  final ScrollController _scrollController = ScrollController();
  List<InventoryPayload> _allInventories = [];
  List<InventoryPayload> _displayInventories = [];
  Set<InventoryPayload> _selectedInventories = {};
  InventoryPayload? _selectedInventoryForEdit;
  List<PurchaseOrder> _availablePOs = [];
  List<Map<String, dynamic>> _allBrands = [];
  List<Location> _availableLocations = [];
  List<ExistingUser> _allUsers = [];

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
    _fetchAvailablePOs();
    _fetchBrands();
    _fetchLocations();
    _fetchUsers();
    _searchController.addListener(_filterInventories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInventories);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchBrands() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final brands = await _brandService.getBrands();

      final brandList = brands.map((b) => {'id': b.brandId, 'name': b.brandName}).toList();

      if(!mounted) return;
      setState(() {
        _allBrands = brandList;
      });
    } catch (e) {
      if(mounted){
        _showDialog('Error', 'Failed to load brands: $e');
      }
    } finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        _showDialog('Error', 'Failed to load inventories: $e');
      }
    }
  }

  void _filterInventories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        _displayInventories = _allInventories.where((payload) {
          return payload.inventory.itemCode.toLowerCase().contains(query);
        }).toList();
      } else {
        _displayInventories = List.from(_allInventories);
      }
      _clearSelection();
      _startIndex = 0;
    });
  }

  Future<void> _fetchAvailablePOs() async {
    try {
      final pos = await _poService.fetchFilteredPurchaseOrders();
      setState(() {
        _availablePOs = pos;
      });
    } catch (e) {
      debugPrint('Error fetching POs: $e');
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final locs = await _locationService.getLocations();
      setState(() {
        _availableLocations = locs;
      });
    } catch (e) {
      debugPrint('Error fetching POs: $e');
    }
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.fetchUsers();

      final userList = users.toList();

      if(!mounted) return;
      setState(() {
        _allUsers = userList;
      });
    } catch (e) {
      if(mounted){
        _showDialog('Error', 'Failed to load users: $e');
      }
    } finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  void _toggleOrderSelection(InventoryPayload payload) {
    setState(() {
      if (_selectedInventories.contains(payload)) {
        _selectedInventories.remove(payload);
        if (_selectedInventoryForEdit == payload) {
          _selectedInventoryForEdit = _selectedInventories.isNotEmpty ? _selectedInventories.first : null;
        }
      } else {
        _selectedInventories.add(payload);
        _selectedInventoryForEdit = payload;
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

  String getBrandNameById(int? brandId) {
    if (brandId == null) return '';
    
    try {
      final brand = _allBrands.firstWhere((brand) => brand['id'] == brandId);
      return brand['name'];
    } catch (e) {
      return 'Unknown Brand (ID: $brandId)';
    }
  }

  String getLocationNameById(int? locId) {
    if (locId == null) return '';
    
    try {
      final location = _availableLocations.firstWhere((loc) => loc.locationId == locId);
      return location.locationName;
    } catch (e) {
      return 'Unknown Location (ID: $locId)';
    }
  }

  String getUserNameById(int? userId) {
    if (userId == null) return '';
    
    try {
      final user = _allUsers.firstWhere((user) => user.userId == userId);
      return user.firstName + user.lastName;
    } catch (e) {
      return 'Unknown User (ID: $userId)';
    }
  }

  Future<PurchaseOrder?> selectPODialog(List<PurchaseOrder> purchaseOrders) {
    return showDialog<PurchaseOrder>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Purchase Order'),
          content: SizedBox(
            width: 600,
            height: 400,
            child: ListView.builder(
              itemCount: purchaseOrders.length,
              itemBuilder: (context, index) {
                final po = purchaseOrders[index];
                final brandName = getBrandNameById(po.brandId);
                bool isHovered = false;

                return StatefulBuilder(
                  builder: (context, setState) {
                    return MouseRegion(
                      onEnter: (_) => setState(() => isHovered = true),
                      onExit: (_) => setState(() => isHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: isHovered
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: isHovered
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.4)
                                : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          title: Text('$brandName (${po.itemCode}) - ${po.productDescription}'),
                          subtitle: Text(
                            'PO Ref: ${po.poPireference} | Pack Size: ${po.packSize}',
                          ),
                          onTap: () => Navigator.pop(context, po),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          hoverColor: Colors.transparent,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<List<ItemLoc>?> addLocationDialog(
    List<Location> availableLocations,
    List<ItemLoc> existingLocs,
  ) {
    final selectedLocs = List<ItemLoc>.from(existingLocs);
    final quantityController = TextEditingController();
    Location? selectedLocation;

    void addLocation(StateSetter setState) {
      if (selectedLocation != null && quantityController.text.isNotEmpty) {
        final qty = int.tryParse(quantityController.text) ?? 0;
        final existing = selectedLocs.indexWhere((s) => s.locationId == selectedLocation!.locationId);

        if (existing >= 0) {
          selectedLocs[existing].quantity += qty;
        } else {
          selectedLocs.add(
            ItemLoc(
              locationId: selectedLocation!.locationId ?? 1,
              locationName: getLocationNameById(selectedLocation!.locationId),
              quantity: qty,
            ),
          );
        }
        setState(() {
          quantityController.clear();
          selectedLocation = null;
        });
      }
    }

    return showDialog<List<ItemLoc>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Locations & Quantities'),
          content: StatefulBuilder(
            builder: (context, setState) {
              final totalQty = selectedLocs.fold<int>(0, (sum, s) => sum + s.quantity);
              return SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Location>(
                      initialValue: selectedLocation,
                      hint: const Text('Select Location'),
                      items: availableLocations.map((loc) {
                        return DropdownMenuItem<Location>(
                          value: loc,
                          child: Text(loc.locationName),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedLocation = val),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Location',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        onPressed: () => addLocation(setState),
                      ),
                    ),
                    const Divider(),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedLocs.length,
                        itemBuilder: (context, index) {
                          final loc = selectedLocs[index];
                          final locName = getLocationNameById(loc.locationId);
                          return ListTile(
                            title: Text(locName),
                            trailing: Text('Qty: ${loc.quantity}'),
                            leading: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => selectedLocs.removeAt(index));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total Quantity: $totalQty',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedLocs),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDialog(String actionType, InventoryPayload payload) async {
    final inventory = payload.inventory;
    final brandName = getBrandNameById(inventory.brandId);
    final totalCost = inventory.quantity * inventory.costOfSale;

    final title = actionType == 'add' ? 'Confirm New Item' : 'Confirm Changes';
    final confirmText = actionType == 'add' ? 'Add' : 'Save Changes';
    final question = actionType == 'add' 
        ? 'Are you sure you want to add this item?'
        : 'Are you sure you want to save these changes?';

    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Brand: $brandName'),
                Text('Description: ${inventory.itemDescription}'),
                Text('Pack Size: ${inventory.packSize}'),
                Text('PO Ref: ${inventory.poPireference}'),
                Text('Lot Num: ${inventory.lotNum}'),
                Text('Expiry: ${inventory.expiry}'),
                const Divider(height: 20),

                Text('Total Quantity: ${inventory.quantity}'),
                Text('Unit Cost: ₱${inventory.costOfSale.toStringAsFixed(2)}'),
                Text('Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(height: 20),

                const Text('Locations:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (payload.locations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Text('(No locations specified)', style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ...payload.locations.map((loc) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('• ${getLocationNameById(loc.locationId)}: ${loc.quantity}'),
                )),
                
                const SizedBox(height: 20),
                Text(question,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();

    final drsiController = TextEditingController();
    final lotNumController = TextEditingController();
    final expiryDateController = TextEditingController();
    final costOfSaleController = TextEditingController();
    final noteController = TextEditingController();

    PurchaseOrder? selectedPO;
    List<ItemLoc> itemLocs = [];
    num totalQuantity = 0;

    void recalculateTotalQuantity(StateSetter setStateDialog) {
      setStateDialog(() {
        totalQuantity = itemLocs.fold(0, (sum, loc) => sum + loc.quantity);
      });
    }

    void selectPurchaseOrder(StateSetter setStateDialog) async {
      final po = await selectPODialog(_availablePOs);
      if (po != null) {
        setStateDialog(() => selectedPO = po);
      }
    }

    void addLocation(StateSetter setStateDialog) async {
      final updated = await addLocationDialog(_availableLocations, itemLocs);
      if (updated != null) {
        setStateDialog(() {
          itemLocs = List<ItemLoc>.from(updated);
          recalculateTotalQuantity(setStateDialog);
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Inventory Item'),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
                return SingleChildScrollView(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Purchase Order Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        _buildReadOnlyField(
                          label: 'PO/PI Reference',
                          value: selectedPO?.poPireference ?? '',
                          onTap: () => selectPurchaseOrder(setStateDialog),
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Item Code',
                          value: selectedPO?.itemCode ?? '',
                          onTap: () => selectPurchaseOrder(setStateDialog),
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Brand',
                          value: getBrandNameById(selectedPO?.brandId),
                          onTap: () => selectPurchaseOrder(setStateDialog),
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Description',
                          value: selectedPO?.productDescription ?? '',
                          onTap: () => selectPurchaseOrder(setStateDialog),
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Pack Size',
                          value: selectedPO?.packSize.toString() ?? '',
                          onTap: () => selectPurchaseOrder(setStateDialog),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 24),

                        const Text(
                          'Inventory Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: drsiController,
                          decoration: const InputDecoration(
                            labelText: 'DR/SI Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: lotNumController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Lot Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: expiryDateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              initialDate: DateTime.now(),
                            );
                            if (date != null) {
                              setStateDialog(() {
                                expiryDateController.text =
                                    date.toIso8601String().split('T').first;
                              });
                            }
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: costOfSaleController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,}$'))
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Cost of Sale',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: noteController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Note',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const Divider(height: 24),

                        const Text(
                          'Stock Locations',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        ElevatedButton.icon(
                          onPressed: () => addLocation(setStateDialog),
                          label: const Text('Add Location'),
                        ),
                        const SizedBox(height: 12),

                        if (itemLocs.isNotEmpty)
                          Column(
                            children: itemLocs
                                .map(
                                  (loc) => ListTile(
                                    dense: true,
                                    title: Text(getLocationNameById(loc.locationId)),
                                    trailing: Text('Qty: ${loc.quantity}'),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 12),

                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Total Quantity',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            totalQuantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() && selectedPO != null) {
                  final newInventory = Inventory(
                    poPireference: selectedPO!.poPireference,
                    invoiceNum: drsiController.text,
                    itemCode: selectedPO!.itemCode ?? '',
                    itemDescription: selectedPO!.productDescription,
                    brandId: selectedPO!.brandId,
                    packSize: selectedPO!.packSize,
                    lotNum: int.tryParse(lotNumController.text) ?? 0,
                    expiry: expiryDateController.text,
                    costOfSale: double.tryParse(costOfSaleController.text) ?? 0.0,
                    note: noteController.text.isEmpty ? null : noteController.text,
                    addedBy: 1,
                    dateTimeAdded: DateTime.now().toIso8601String(),
                    quantity: totalQuantity as int,
                  );

                  final payload = InventoryPayload(
                    inventory: newInventory,
                    locations: itemLocs,
                  );

                  final confirmed = await _confirmDialog("add", payload);

                  if (confirmed == true) {
                    try {
                      await _inventoryService.createInventory(payload);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      _showDialog('Success', 'Inventory item added!');
                      _fetchInventories();
                      setState(() {
                        _availablePOs.removeWhere((po) => po.itemCode == selectedPO!.itemCode);
                      });
                    } catch (e) {
                      if (!context.mounted) return;
                      _showDialog('Error', 'Failed to add inventory: $e');
                    }
                  }
                } else if (selectedPO == null) {
                  _showDialog('Error', 'Please select a Purchase Order.');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  } 
  
  void _showEditDialog(InventoryPayload payload) {
    final formKey = GlobalKey<FormState>();

    final Inventory inventory = payload.inventory;

    final drsiController = TextEditingController(text: inventory.invoiceNum);
    final lotNumController = TextEditingController(text: inventory.lotNum.toString());
    final expiryDateController = TextEditingController(text: inventory.expiry);
    final costOfSaleController = TextEditingController(text: inventory.costOfSale.toString());
    final noteController = TextEditingController(text: inventory.note ?? '');

    //PurchaseOrder? selectedPO;
    List<ItemLoc> itemLocs = List.from(payload.locations);
    num totalQuantity = itemLocs.fold(0, (sum, loc) => sum + loc.quantity);

    void recalculateTotalQuantity(StateSetter setStateDialog) {
      setStateDialog(() {
        totalQuantity = itemLocs.fold(0, (sum, loc) => sum + loc.quantity);
      });
    }

    // void selectPurchaseOrder(StateSetter setStateDialog) async {
    //   final po = await selectPODialog(_availablePOs);
    //   if (po != null) {
    //     setStateDialog(() => selectedPO = po);
    //   }
    // }

    void addLocation(StateSetter setStateDialog) async {
      final updated = await addLocationDialog(_availableLocations, itemLocs);
      if (updated != null) {
        setStateDialog(() {
          itemLocs = List<ItemLoc>.from(updated);
          recalculateTotalQuantity(setStateDialog);
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Inventory: ${inventory.itemCode}'),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
                return SingleChildScrollView(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Purchase Order Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        _buildReadOnlyField(
                          label: 'PO/PI Reference',
                          value: inventory.poPireference,
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Item Code',
                          value: inventory.itemCode,
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Brand',
                          value: getBrandNameById(inventory.brandId),
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Description',
                          value: inventory.itemDescription,
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Pack Size',
                          value: inventory.packSize.toString(),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 24),

                        const Text(
                          'Inventory Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: drsiController,
                          decoration: const InputDecoration(
                            labelText: 'DR/SI/CI Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: lotNumController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Lot Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: expiryDateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate: DateTime.tryParse(expiryDateController.text) ??
                                  DateTime.now(),
                            );
                            if (date != null) {
                              setStateDialog(() {
                                expiryDateController.text =
                                    date.toIso8601String().split('T').first;
                              });
                            }
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: costOfSaleController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,}$'))
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Cost of Sale',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: noteController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Note',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const Divider(height: 24),

                        const Text(
                          'Stock Locations',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        ElevatedButton.icon(
                          onPressed: () => addLocation(setStateDialog),
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text('Add Location'),
                        ),
                        const SizedBox(height: 12),

                        if (itemLocs.isNotEmpty)
                          Column(
                            children: itemLocs
                                .map(
                                  (loc) => ListTile(
                                    dense: true,
                                    title: Text(getLocationNameById(loc.locationId)),
                                    trailing: Text('Qty: ${loc.quantity}'),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 12),

                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Total Quantity',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            totalQuantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedInventory = Inventory(
                    poPireference: inventory.poPireference,
                    invoiceNum: drsiController.text,
                    itemCode: inventory.itemCode,
                    itemDescription: inventory.itemDescription,
                    brandId: inventory.brandId,
                    packSize: inventory.packSize,
                    lotNum: int.tryParse(lotNumController.text) ?? 0,
                    expiry: expiryDateController.text,
                    costOfSale: double.tryParse(costOfSaleController.text) ?? 0.0,
                    note: noteController.text,
                    addedBy: 1,
                    dateTimeAdded: inventory.dateTimeAdded,
                    quantity: totalQuantity as int,
                  );

                  final updatePayload = InventoryPayload(
                    inventory: updatedInventory,
                    locations: itemLocs,
                  );

                  final confirmed = await _confirmDialog("edit", updatePayload);

                  if(confirmed == true){
                    try {
                      await _inventoryService.updateInventory(updatePayload);
                      if (mounted) {
                        Navigator.pop(context);
                        _showDialog('Success', 'Inventory updated successfully.');
                        _fetchInventories();
                      }
                    } catch (e) {
                      _showDialog('Error', 'Failed to update: $e');
                    }
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

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isHovered ? Colors.blue.withValues(alpha: 0.05) : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
                child: TextFormField(
                  key: ValueKey<String>(value),
                  decoration: InputDecoration(
                    labelText: label,
                    border: const OutlineInputBorder(),
                    suffixIcon: Icon(
                      Icons.search,
                      color: isHovered ? Colors.blueAccent : null,
                    ),
                  ),
                  controller: TextEditingController(text: value),
                  readOnly: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    final selectedCount = _selectedInventories.length;
    final singleId = _selectedInventories.isNotEmpty ? _selectedInventories.first.inventory.itemCode : "";
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
    final payloadsToDelete = List.from(_selectedInventories);
    
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

      for (InventoryPayload payload in payloadsToDelete) {
        try {
          await _inventoryService.deleteInventory(payload.inventory.itemCode);
          successCount++;
        } catch (e) {
          errors.add('Error deleting ${payload.inventory.itemCode}: $e');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      await _fetchInventories();
      await _fetchAvailablePOs();

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
          'Inventory',
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
                                      'Add',
                                      Icons.add,
                                      _showAddDialog,
                                      isHovered: _isHovered,
                                      isSmall: true,
                                    ),
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
                                MouseRegion(
                                  onEnter: (_) => setState(() => _isHovered = true),
                                  onExit: (_) => setState(() => _isHovered = false),
                                  child: NeumorphicButton(
                                    onPressed: _showAddDialog,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _isHovered ? -4 : 4,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      isMediumScreen ? 'Add' : 'Add Inventory',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF01579B),
                                        fontSize: isMediumScreen ? 13 : 15,
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
                                : Theme(
                                    data: Theme.of(context).copyWith(
                                      scrollbarTheme: ScrollbarThemeData(
                                        thumbColor: WidgetStateProperty.resolveWith<Color?>(
                                          (Set<WidgetState> states) {
                                            if (states.contains(WidgetState.hovered) ||
                                                states.contains(WidgetState.dragged)) {
                                              return Colors.white.withValues(alpha: 0.8);
                                            }
                                            return Colors.white.withValues(alpha: 0.3);
                                          },
                                        ),
                                      ),
                                    ),
                                    child: Scrollbar(
                                      controller: _scrollController,
                                      thumbVisibility: _displayInventories.isNotEmpty,
                                      child: Listener(
                                        onPointerSignal: (PointerSignalEvent event) {
                                          if (event is PointerScrollEvent) {
                                            final double newOffset = _scrollController.offset + event.scrollDelta.dy;
                                            final double clampedOffset = newOffset.clamp(
                                              _scrollController.position.minScrollExtent,
                                              _scrollController.position.maxScrollExtent,
                                            );
                                            _scrollController.jumpTo(clampedOffset);
                                          }
                                        },
                                        child: SingleChildScrollView(
                                          controller: _scrollController,
                                          scrollDirection: Axis.horizontal,
                                          padding: EdgeInsets.only(bottom: _displayInventories.isNotEmpty ? 11 : 0),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: constraints.maxWidth,
                                            ),
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                dataTableTheme: DataTableThemeData(
                                                  checkboxHorizontalMargin: 16.0,
                                                  columnSpacing: constraints.maxWidth > 1200 ? 24.0 : 12.0,
                                                  horizontalMargin: constraints.maxWidth > 800 ? 16.0 : 8.0,
                                                ),
                                                checkboxTheme: CheckboxThemeData(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              child: DataTable(
                                                showCheckboxColumn: true,
                                                columnSpacing: constraints.maxWidth > 1200 ? 24.0 : 12.0,
                                                horizontalMargin: constraints.maxWidth > 800 ? 16.0 : 8.0,
                                                checkboxHorizontalMargin: 16.0,
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
                                                          DataCell(Text('')),
                                                          DataCell(Text('')),
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
                              SizedBox(
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
      DataColumn(label: Text('PO/PI Ref', style: headerStyle)),
      DataColumn(label: Text('DR/CI/SI No.', style: headerStyle)),
      DataColumn(label: Text('Item Code', style: headerStyle)),
      DataColumn(label: Text('Description', style: headerStyle)),
      DataColumn(label: Text('Pack Size', style: headerStyle)),
      DataColumn(label: Text('Lot No.', style: headerStyle)),
      DataColumn(label: Text('Expiry', style: headerStyle,)),
      DataColumn(label: Text('Quantity', style: headerStyle)),
      DataColumn(label: Text('Cost of Sale', style: headerStyle)),
      DataColumn(label: Text('Location', style: headerStyle)),
      DataColumn(label: Text('Note', style: headerStyle)),
      DataColumn(label: Text('Added By', style: headerStyle)),
      DataColumn(label: Text('Date & Time Added', style: headerStyle))
    ];
  }
    List<DataRow> _buildDataRows(DateFormat formatter, int endIndex, double screenWidth) {
    int counter = 0;
    final bool showAll = _rowsPerPage == _showAllValue;
    final recordsToShow = showAll ? _displayInventories : _displayInventories.sublist(_startIndex, endIndex);

    return recordsToShow.map<DataRow>((payload) {
      final inventory = payload.inventory;
      final isSelected = _selectedInventories.contains(payload);
      final rowColor = counter.isEven ? const Color.fromRGBO(241, 245, 255, 1) : const Color.fromRGBO(230, 240, 255, 1);
      counter++;

      return DataRow(
        selected: isSelected,
        onSelectChanged: (bool? selected) => _toggleOrderSelection(payload),
        color: WidgetStateProperty.all(rowColor),
        cells: [
          DataCell(Text(inventory.poPireference)),
          DataCell(Text(inventory.invoiceNum)),
          DataCell(Text(inventory.itemCode)),
          DataCell(Text(inventory.itemDescription)),
          DataCell(Text(inventory.packSize.toString())),
          DataCell(Text(inventory.lotNum.toString())),
          DataCell(Text(inventory.expiry)),
          DataCell(Text(inventory.quantity.toString())),
          DataCell(Text(inventory.costOfSale.toStringAsFixed(2))),
          DataCell(
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Locations'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: payload.locations.isNotEmpty
                          ? payload.locations.map((loc) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('${getLocationNameById(loc.locationId)}: ${loc.quantity}'),
                              );
                            }).toList()
                          : [const Text('No location data')],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Locations list',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          DataCell(Text(inventory.note ?? '')),
          DataCell(Text(getUserNameById(inventory.addedBy))),
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
                : '${_displayInventories.isEmpty ? 0 : _startIndex + 1} - $endIndex of ${_displayInventories.length}',
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