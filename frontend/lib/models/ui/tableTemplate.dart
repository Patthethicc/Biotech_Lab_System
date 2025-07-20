import 'package:flutter/material.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:frontend/services/stock_alert_service.dart';

class DataTemplate extends StatefulWidget {
  const DataTemplate({super.key});

  @override
  State<DataTemplate> createState() => _DataTemplateState();
}

class _DataTemplateState extends State<DataTemplate> {

  List<Inventory> _Inventories = [];
  int _startIndex = 0;
  int _endIndex = 5;
  int _maxLength = 0;


  @override

  void initState() {
    final inventoryService = InventoryService();

    inventoryService.getInventories().then((value) {
      print("Fetched data: $value");
      setState(() {
        _Inventories.addAll(value);
      });
    });

    super.initState();
  }

  void nextPage() {
    print('$_startIndex $_endIndex $_maxLength');
    if((_endIndex + 5) < _maxLength){
      setState(() {
        _startIndex = _startIndex + 5;
        _endIndex = _endIndex + 5;
      });
    } else {
      setState(() {
        _startIndex = _startIndex + (_maxLength - _endIndex);
        _endIndex = _endIndex + (_maxLength - _endIndex);
      });
    }
  }

  void prevPage() {
    if((_startIndex - 5) >= 0){
      setState(() {
        _startIndex = _startIndex - 5;
        _endIndex = _endIndex - 5;
      });
    } else {
      setState(() {
        _startIndex = 0;
        _endIndex = 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table Example')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: 1200,
                  child: _Inventories.length < 5 ?
                    SizedBox(height: 300, child:  CircularProgressIndicator())
                    :DataTable(
                    columns: [
                      DataColumn(label: Text("data 1")),
                      DataColumn(label: Text("data 2")),
                      DataColumn(label: Text("data 3")),
                      DataColumn(label: Text("data 4")),
                      DataColumn(label: Text("data 5")),
                      DataColumn(label: Text("data 6")),
                    ],
                   rows: _populateRows().sublist(_startIndex , _endIndex))
                ),
              ),
              Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple, // background color
                        foregroundColor: Colors.white, // text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: prevPage,
                      child: Text('<'),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple, // background color
                        foregroundColor: Colors.white, // text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {},
                      child: Text('${_startIndex + 1} - $_endIndex'),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple, // background color
                        foregroundColor: Colors.white, // text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: nextPage,
                      child: Text('>'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  List<DataRow> _populateRows() {
    _maxLength = _Inventories.length;
    return _Inventories.map((e) {
      return DataRow(
        cells: [
          DataCell(Text(e.inventoryID.toString())),
          DataCell(Text(e.itemCode.toString())),
          DataCell(Text(e.brand.toString())),
          DataCell(Text(e.quantityOnHand.toString())),
          DataCell(Text(e.addedBy.toString())),
          DataCell(Text(e.dateTimeAdded.toString())),
        ]
      );
    }).toList();
  }
}