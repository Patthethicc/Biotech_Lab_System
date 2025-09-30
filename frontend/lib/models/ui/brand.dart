import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/brand_model.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/services/brand_service.dart';
import 'package:frontend/services/inventory_service.dart';
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

class BrandPage extends StatefulWidget {
  const BrandPage({super.key});

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  final brandService = BrandService();

  List<BrandModel> _allBrands = [];
  List<BrandModel> _displayBrands = [];
  bool _isLoading = true;
  bool _isHovered = false;

  int _startIndex = 0;
  final int _rowsPerPage = 5;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    //_searchController.addListener(_filterInventories);
  }

  @override
  void dispose() {
    //_searchController.removeListener(_filterInventories);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchData() {
    brandService.getBrands().then((value) {
      setState(() {
        _allBrands = value;
        _displayBrands = List.from(_allBrands);
        _isLoading = false;
      });
    });
  }


  void _resetToFullList() {
    setState(() {
      _searchController.clear();
     _displayBrands = List.from(_allBrands);
      _startIndex = 0;
    });
  }

  void nextPage() {
    setState(() {
      if (_startIndex + _rowsPerPage < _displayBrands.length) {
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

  // leave invID 0 if ur in write mode
  void showAddDialogue() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    showDialog(context: context, 
    builder: (context) {
      return AlertDialog(
        title: Text('Add Brand'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Brand Name"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid brand name';
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final BrandModel newBrand = BrandModel(brandName: nameController.text,);
              await brandService.createBrand(newBrand);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                builder: (BuildContext context) => super.widget));
              
            } ,
            child: const Text("Add")
          )
        ],
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final endIndex = (_startIndex + _rowsPerPage > _displayBrands.length)
        ? _displayBrands.length
        : _startIndex + _rowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Brand Data',
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 500, right: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Adjust as needed
                  children: [
                    // Search field
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SizedBox(
                          width: 700,
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
                                      hintText: 'Search by Item Code or Brand',
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

                    // Add Data button
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: NeumorphicButton(
                        onPressed: () => showAddDialogue(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), // smaller height
                        style: NeumorphicStyle(
                          depth: _isHovered ? -4 : 4,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                          lightSource: LightSource.topLeft,
                          color: Colors.white,
                        ),
                        child: const Text(
                          'Add Data',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF01579B), // dark blue text
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
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
                            DataColumn(label: Text("", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Brand Name", style: TextStyle(color: Colors.white))),
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
    if  (_displayBrands.isEmpty) {
      return [
        const DataRow(cells: [
          DataCell(Text('')),
          DataCell(Text('No results found')),
        ])
      ];
    }

     int counter = 0;

    return _displayBrands.map((e) {
      return DataRow(cells: [
        DataCell(Row(
          children: [IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await brandService.deleteBrand(e.brandId!.toInt());
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                  builder: (BuildContext context) => super.widget));
            },
            ),

            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                //showAddDialogue("Edit", e.inventoryID!.toInt());
              },
            )
            ]
        )),
        DataCell(Text(e.brandName.toString())),
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
              '${_displayBrands.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayBrands.length}',
            ),
          ),
          _NeumorphicNavButton(
            icon: Icons.chevron_right,
            enabled: endIndex < _displayBrands.length,
            onPressed: nextPage,
            tooltip: 'Next Page',
          ),
        ],
      ),
    );
  }
}