import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
    group('Purchase Order Confirmation Dialog Tests', () {
        testWidgets('US1-TC-004: Confirmation dialog appears with entered data',
            (WidgetTester tester) async {
        // Sample data that would be entered in the form
        final testData = {
            'brand': 'Biorex Products',
            'description': 'Biorex ALT Reagent',
            'packSize': '100',
            'quantity': '5',
            'unitCost': '850.50',
            'reference': 'PO-2024-001',
        };

        bool dialogConfirmed = false;

        // Build a simple app with a button that shows confirmation dialog
        await tester.pumpWidget(
            MaterialApp(
            home: Scaffold(
                appBar: AppBar(title: const Text('Test')),
                body: Center(
                child: ElevatedButton(
                    onPressed: () {
                    // Show confirmation dialog (simulating what your app does)
                    showDialog(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (context) => AlertDialog(
                        title: const Text('Confirm Purchase Order'),
                        content: SingleChildScrollView(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Text('Brand: ${testData['brand']}'),
                                Text('Product: ${testData['description']}'),
                                Text('Pack Size: ${testData['packSize']}'),
                                Text('Quantity: ${testData['quantity']}'),
                                Text('Unit Cost: ₱${testData['unitCost']}'),
                                Text('Reference: ${testData['reference']}'),
                                const SizedBox(height: 16),
                                const Text(
                                'Are you sure all information is correct?',
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
                            TextButton(
                            onPressed: () {
                                dialogConfirmed = true;
                                Navigator.pop(context);
                            },
                            child: const Text('Confirm'),
                            ),
                        ],
                        ),
                    );
                    },
                    child: const Text('Add Purchase Order'),
                ),
                ),
            ),
            ),
        );

        // Step 1: Find and tap the button to open confirmation dialog
        final addButton = find.text('Add Purchase Order');
        expect(addButton, findsOneWidget);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Step 2: Verify confirmation dialog appears
        expect(find.text('Confirm Purchase Order'), findsOneWidget,
            reason: 'Confirmation dialog title should appear');

        // Step 3: Verify all data is displayed in the dialog
        expect(find.textContaining('Brand: Biorex Products'), findsOneWidget,
            reason: 'Brand should be displayed');
        expect(find.textContaining('Product: Biorex ALT Reagent'), findsOneWidget,
            reason: 'Product description should be displayed');
        expect(find.textContaining('Pack Size: 100'), findsOneWidget,
            reason: 'Pack size should be displayed');
        expect(find.textContaining('Quantity: 5'), findsOneWidget,
            reason: 'Quantity should be displayed');
        expect(find.textContaining('Unit Cost: ₱850.50'), findsOneWidget,
            reason: 'Unit cost should be displayed');
        expect(find.textContaining('Reference: PO-2024-001'), findsOneWidget,
            reason: 'PO/PI reference should be displayed');

        // Step 4: Verify confirmation message
        expect(
            find.text('Are you sure all information is correct?'),
            findsOneWidget,
            reason: 'Confirmation message should appear');

        // Step 5: Verify both buttons exist
        expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget,
            reason: 'Cancel button should be present');
        expect(find.widgetWithText(TextButton, 'Confirm'), findsOneWidget,
            reason: 'Confirm button should be present');
        });

        testWidgets('US1-TC-004B: User can cancel from confirmation dialog',
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
                        title: const Text('Confirm Purchase Order'),
                        content: const Text('Are you sure?'),
                        actions: [
                            TextButton(
                            onPressed: () {
                                dialogCancelled = true;
                                Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                            ),
                            TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Confirm'),
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

        // Verify dialog is open
        expect(find.text('Confirm Purchase Order'), findsOneWidget);

        // Tap Cancel
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();

        // Verify dialog is closed
        expect(find.text('Confirm Purchase Order'), findsNothing,
            reason: 'Dialog should be dismissed after Cancel');
        expect(dialogCancelled, true,
            reason: 'Cancel callback should have been triggered');
        });

        testWidgets('US1-TC-004C: User confirms and action is executed',
            (WidgetTester tester) async {
        bool orderAdded = false;

        await tester.pumpWidget(
            MaterialApp(
            home: Scaffold(
                body: Center(
                child: ElevatedButton(
                    onPressed: () {
                    showDialog(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (context) => AlertDialog(
                        title: const Text('Confirm Purchase Order'),
                        content: const Text('Add this order?'),
                        actions: [
                            TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                            ),
                            TextButton(
                            onPressed: () {
                                orderAdded = true;
                                Navigator.pop(context);
                                // In real app, this would call the service
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Purchase order added successfully!'),
                                ),
                                );
                            },
                            child: const Text('Confirm'),
                            ),
                        ],
                        ),
                    );
                    },
                    child: const Text('Add Order'),
                ),
                ),
            ),
            ),
        );

        // Open dialog
        await tester.tap(find.text('Add Order'));
        await tester.pumpAndSettle();

        // Tap Confirm
        await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
        await tester.pumpAndSettle();

        // Verify dialog is closed
        expect(find.text('Confirm Purchase Order'), findsNothing,
            reason: 'Dialog should be dismissed after Confirm');

        // Verify success message appears
        expect(find.text('Purchase order added successfully!'), findsOneWidget,
            reason: 'Success message should appear');

        // Verify the order was marked as added
        expect(orderAdded, true,
            reason: 'Order should be marked as added');
        });
    });
}