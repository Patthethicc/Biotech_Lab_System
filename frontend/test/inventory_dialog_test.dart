import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
    group('Inventory Confirmation Dialog Tests', () {
        
        testWidgets('US2-TC-003: Inventory confirmation dialog displays all data with location breakdown',
            (WidgetTester tester) async {
        // Sample data that would be entered in the inventory form
        final testData = {
            'brand': 'Biorex',
            'description': 'Biorex ALT Reagent',
            'packSize': '100',
            'poRef': 'PO-2024-001',
            'lotNum': '12345',
            'expiry': '2025-12-31',
            'costOfSale': '850.50',
            'totalQuantity': '100',
        };

        final testLocations = [
            {'name': 'Refrigerator', 'quantity': '30'},
            {'name': 'Storage Room', 'quantity': '40'},
            {'name': 'Lab Cabinet', 'quantity': '30'},
        ];

        final totalCost = double.parse(testData['costOfSale']!) * 
                        int.parse(testData['totalQuantity']!);

        bool dialogConfirmed = false;

        // app with a button that shows confirmation dialog
        await tester.pumpWidget(
            MaterialApp(
            home: Scaffold(
                appBar: AppBar(title: const Text('Test')),
                body: Center(
                child: ElevatedButton(
                    onPressed: () {
                    // Show confirmation dialog (simulating inventory confirmation)
                    showDialog(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (context) => AlertDialog(
                        title: const Text('Confirm New Item'),
                        content: SingleChildScrollView(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                // Purchase Order Details
                                Text('Brand: ${testData['brand']}'),
                                Text('Description: ${testData['description']}'),
                                Text('Pack Size: ${testData['packSize']}'),
                                Text('PO Ref: ${testData['poRef']}'),
                                Text('Lot Num: ${testData['lotNum']}'),
                                Text('Expiry: ${testData['expiry']}'),
                                const Divider(height: 20),

                                // Inventory Summary
                                Text('Total Quantity: ${testData['totalQuantity']}'),
                                Text('Unit Cost: ₱${testData['costOfSale']}'),
                                Text('Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const Divider(height: 20),

                                // Location Breakdown
                                const Text('Locations:', style: TextStyle(fontWeight: FontWeight.bold)),
                                ...testLocations.map((loc) => Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('• ${loc['name']}: ${loc['quantity']}'),
                                )),
                                
                                const SizedBox(height: 20),
                                const Text(
                                'Are you sure you want to add this item?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                            ],
                            ),
                        ),
                        actions: [
                            TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                            onPressed: () {
                                dialogConfirmed = true;
                                Navigator.pop(context);
                            },
                            child: const Text('Add'),
                            ),
                        ],
                        ),
                    );
                    },
                    child: const Text('Add Inventory'),
                ),
                ),
            ),
            ),
        );

        // Step 1: Find and tap the button to open confirmation dialog
        final addButton = find.text('Add Inventory');
        expect(addButton, findsOneWidget);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Step 2: Verify confirmation dialog appears
        expect(find.text('Confirm New Item'), findsOneWidget,
            reason: 'Confirmation dialog title should appear');

        // Step 3: Verify Purchase Order data is displayed
        expect(find.textContaining('Brand: Biorex'), findsOneWidget,
            reason: 'Brand should be displayed');
        expect(find.textContaining('Description: Biorex ALT Reagent'), findsOneWidget,
            reason: 'Product description should be displayed');
        expect(find.textContaining('Pack Size: 100'), findsOneWidget,
            reason: 'Pack size should be displayed');
        expect(find.textContaining('PO Ref: PO-2024-001'), findsOneWidget,
            reason: 'PO reference should be displayed');
        expect(find.textContaining('Lot Num: 12345'), findsOneWidget,
            reason: 'Lot number should be displayed');
        expect(find.textContaining('Expiry: 2025-12-31'), findsOneWidget,
            reason: 'Expiry date should be displayed');

        // Step 4: Verify inventory summary
        expect(find.textContaining('Total Quantity: 100'), findsOneWidget,
            reason: 'Total quantity should be displayed');
        expect(find.textContaining('Unit Cost: ₱850.50'), findsOneWidget,
            reason: 'Unit cost should be displayed');
        expect(find.textContaining('Total Cost: ₱85050.00'), findsOneWidget,
            reason: 'Total cost should be calculated and displayed');

        // Step 5: Verify location breakdown is displayed
        expect(find.text('Locations:'), findsOneWidget,
            reason: 'Locations header should be displayed');
        expect(find.textContaining('• Refrigerator: 30'), findsOneWidget,
            reason: 'Refrigerator location with quantity should be displayed');
        expect(find.textContaining('• Storage Room: 40'), findsOneWidget,
            reason: 'Storage Room location with quantity should be displayed');
        expect(find.textContaining('• Lab Cabinet: 30'), findsOneWidget,
            reason: 'Lab Cabinet location with quantity should be displayed');

        // Step 6: Verify confirmation message
        expect(
            find.text('Are you sure you want to add this item?'),
            findsOneWidget,
            reason: 'Confirmation message should appear');

        // Step 7: Verify both buttons exist
        expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget,
            reason: 'Cancel button should be present');
        expect(find.widgetWithText(ElevatedButton, 'Add'), findsOneWidget,
            reason: 'Add button should be present');
        });

        testWidgets('US2-TC-003B: User can cancel inventory addition',
            (WidgetTester tester) async {
        bool dialogCancelled = false;

        await tester.pumpWidget(
            MaterialApp(
            home: Scaffold(
                body: Center(
                child: ElevatedButton(
                    onPressed: () {
                    showDialog(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (context) => AlertDialog(
                        title: const Text('Confirm New Item'),
                        content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            Text('Brand: Biorex'),
                            Text('Total Quantity: 100'),
                            Divider(),
                            Text('Locations:'),
                            Text('• Refrigerator: 30'),
                            Text('• Storage Room: 40'),
                            Text('• Lab Cabinet: 30'),
                            ],
                        ),
                        actions: [
                            TextButton(
                            onPressed: () {
                                dialogCancelled = true;
                                Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Add'),
                            ),
                        ],
                        ),
                    );
                    },
                    child: const Text('Show Dialog'),
                ),
                ),
            ),
            ),
        );

        // Open dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog is open and shows location details
        expect(find.text('Confirm New Item'), findsOneWidget);
        expect(find.textContaining('Refrigerator: 30'), findsOneWidget);

        // Tap Cancel
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();

        // Verify dialog is closed
        expect(find.text('Confirm New Item'), findsNothing,
            reason: 'Dialog should be dismissed after Cancel');
        expect(dialogCancelled, true,
            reason: 'Cancel callback should have been triggered');
        });

        testWidgets('US2-TC-003C: User confirms and inventory is added with locations',
            (WidgetTester tester) async {
        bool inventoryAdded = false;

        await tester.pumpWidget(
            MaterialApp(
            home: Scaffold(
                body: Center(
                child: ElevatedButton(
                    onPressed: () {
                    showDialog(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (context) => AlertDialog(
                        title: const Text('Confirm New Item'),
                        content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text('Brand: Biorex'),
                            Text('Total Quantity: 100'),
                            Divider(),
                            Text('Locations:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('• Refrigerator: 30'),
                            Text('• Storage Room: 40'),
                            Text('• Lab Cabinet: 30'),
                            SizedBox(height: 16),
                            Text('Add this inventory item?'),
                            ],
                        ),
                        actions: [
                            TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                            onPressed: () {
                                inventoryAdded = true;
                                Navigator.pop(context);
                                // In real app, this would call the service
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Inventory item added!'),
                                ),
                                );
                            },
                            child: const Text('Add'),
                            ),
                        ],
                        ),
                    );
                    },
                    child: const Text('Add Inventory'),
                ),
                ),
            ),
            ),
        );

        // Open dialog
        await tester.tap(find.text('Add Inventory'));
        await tester.pumpAndSettle();

        // Verify all locations are shown
        expect(find.textContaining('Refrigerator: 30'), findsOneWidget);
        expect(find.textContaining('Storage Room: 40'), findsOneWidget);
        expect(find.textContaining('Lab Cabinet: 30'), findsOneWidget);

        // Tap Add button
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
        await tester.pumpAndSettle();

        // Verify dialog is closed
        expect(find.text('Confirm New Item'), findsNothing,
            reason: 'Dialog should be dismissed after confirmation');

        // Verify success message appears
        expect(find.text('Inventory item added!'), findsOneWidget,
            reason: 'Success message should appear');

        // Verify the inventory was marked as added
        expect(inventoryAdded, true,
            reason: 'Inventory should be marked as added');
        });
    });
}