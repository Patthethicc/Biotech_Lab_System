import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordingData {
  final String reference;
  final DateTime transactionDate;
  final String brand;
  final String itemDescription;
  final int lotNumber;
  final DateTime expiryDate;
  final int quantity;
  final String stockLocation;

  RecordingData({
    required this.reference,
    required this.transactionDate,
    required this.brand,
    required this.itemDescription,
    required this.lotNumber,
    required this.expiryDate,
    required this.quantity,
    required this.stockLocation,
  });
}

class DataRecording extends StatelessWidget {
  const DataRecording({super.key});

  List<RecordingData> get sampledata {
    return [
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'asdawdasfwagasdwasdwasdwasdwasdwadswasdwasdwasdwasdwasdwad',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Wasdweagasfniawkamsohfgwiajsndohwabgis',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: const Text('Data Recording')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // opens up a popup where you can add entry ot the table
                },
                child: const Text('Add Entry'),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.blueGrey,
                      width: 1,
                    ),
                    columnSpacing: 24.0,
                    horizontalMargin: 12.0,
                    dataRowMinHeight: 48.0,
                    dataRowMaxHeight: 100.0,
                    headingRowHeight: 56.0,
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'DR/SI Reference',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Transaction Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Brand',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Item Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Lot Number',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Expiry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Stock Location',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: sampledata.map<DataRow>((data) {
                      return DataRow(
                        cells: [
                          DataCell(SizedBox(width: 100, child: Text(data.reference, softWrap: true))),
                          DataCell(SizedBox(width: 90, child: Text(formatter.format(data.transactionDate), softWrap: true))),
                          DataCell(SizedBox(width: 85, child: Text(data.brand, softWrap: true))),
                          DataCell(SizedBox(width: 200, child: Text(data.itemDescription, softWrap: true))),
                          DataCell(SizedBox(width: 70, child: Text(data.lotNumber.toString(), softWrap: true))),
                          DataCell(SizedBox(width: 90, child: Text(formatter.format(data.expiryDate), softWrap: true))),
                          DataCell(SizedBox(width: 45, child: Text(data.quantity.toString(), softWrap: true))),
                          DataCell(SizedBox(width: 190, child: Text(data.stockLocation, softWrap: true))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
