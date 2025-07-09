import 'package:flutter/material.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/services/inventory_service.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Inventory inventory;
  final VoidCallback? onSave;

  const ItemDetailsScreen({
    Key? key,
    required this.inventory,
    this.onSave,
  }) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _itemCodeController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _itemCodeController = TextEditingController(text: widget.inventory.itemCode);
    _quantityController = TextEditingController(text: widget.inventory.quantityOnHand.toString());
  }

  @override
  void dispose() {
    _itemCodeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: ListBody(children: [Text(content)])),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back
              },
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _showConfirmationDialog(
        title: widget.inventory.inventoryID == null ? 'Add Item' : 'Update Item',
        content: 'Do you want to save these changes?',
        onConfirm: () async {
          final updated = Inventory(
            inventoryID: widget.inventory.inventoryID,
            itemCode: _itemCodeController.text,
            quantityOnHand: int.tryParse(_quantityController.text) ?? 0,
            lastUpdated: DateTime.now().toIso8601String(),
          );

          if (widget.inventory.inventoryID == null) {
            await InventoryService().createInventory(updated);
          } else {
            await InventoryService().updateInventory(updated);
          }

          if (widget.onSave != null) widget.onSave!();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item saved successfully')),
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details for ${widget.inventory.itemCode}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _itemCodeController,
                decoration: _inputDecoration('Item Code'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter item code'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Quantity On Hand'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter quantity'
                    : null,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 18)),
                ),
              ),
              if (widget.inventory.inventoryID != null)
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete Item', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      _showConfirmationDialog(
                        title: 'Delete Item',
                        content: 'Are you sure you want to delete this item?',
                        onConfirm: () async {
                          await InventoryService().deleteInventory(widget.inventory.inventoryID!);
                          if (widget.onSave != null) widget.onSave!();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.white,
      );
}
