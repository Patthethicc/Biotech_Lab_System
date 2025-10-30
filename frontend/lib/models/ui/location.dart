import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/location.dart';
import 'package:frontend/services/location_service.dart';

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

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final locationService = LocationService();

  List<Location> _allLocations = [];
  List<Location> _displayLocations = [];
  bool _isLoading = true;

  int _startIndex = 0;
  final int _rowsPerPage = 5;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchData() {
    locationService.getLocations().then((value) {
      setState(() {
        _allLocations = value;
        _displayLocations = List.from(_allLocations);
        _isLoading = false;
      });
    }).catchError((e) {
        setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load locations: $e')),
      );
    });
  }

  void _resetToFullList() {
    setState(() {
      _searchController.clear();
     _displayLocations = List.from(_allLocations);
      _startIndex = 0;
    });
  }

  void nextPage() {
    setState(() {
      if (_startIndex + _rowsPerPage < _displayLocations.length) {
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

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _displayLocations = _allLocations.where((location) {
        return location.locationName.toLowerCase().contains(query);
      }).toList();
      _startIndex = 0;
    });
  }

  void showAddDialogue() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    showDialog(context: context, 
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('Add Location'),
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
                      labelText: "Location Name"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid location name';
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if(formKey.currentState!.validate()){
                final Location newLocation = Location(locationName: nameController.text,);
                try {
                  await locationService.createLocation(newLocation);
                  if (!mounted) return;
                  Navigator.pop(context);
                  _fetchData();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add location: $e')),
                  );
                }
              }
            },
            child: const Text("Add")
          )
        ],
      );
    });
  }

  void showEditDialogue(Location loc) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: loc.locationName);
    final originalName = loc.locationName;

    showDialog(context: context, 
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('Edit Location'),
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
                      labelText: "Location Name"
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if(formKey.currentState!.validate()){
                final Location updatedLocation = Location(locationId:loc.locationId , locationName: nameController.text,);
                try {
                  await locationService.updateLocation(originalName, updatedLocation);
                  if (!mounted) return;
                  Navigator.pop(context);
                  _fetchData();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add location: $e')),
                  );
                }
              }
            },
            child: const Text("Edit")
          )
        ],
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final endIndex = (_startIndex + _rowsPerPage > _displayLocations.length)
        ? _displayLocations.length
        : _startIndex + _rowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location Data',
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/Images/bg.png'),
            fit: BoxFit.cover,
          )
        ),
        child:Center(
        child:ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                                        hintText: 'Search by Location Name',
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
                                        _onSearchChanged();
                                      },
                                      child: const Icon(Icons.clear, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      _AddDataButton(
                        onPressed: () => showAddDialogue(),
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
                        : _displayLocations.isEmpty
                          ? Center(child: Text("No Locations Found"))
                          : DataTable(                         
                            columns: const [
                              DataColumn(label: Text("", style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text("Location Name", style: TextStyle(color: Colors.white))),
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
      ),
      )
    );
  }

  List<DataRow> _populateRows() {
    if  (_displayLocations.isEmpty) {
      return [
        const DataRow(cells: [
          DataCell(Text('')),
          DataCell(Text('No results found')),
        ])
      ];
    }

     int counter = 0;

    return _displayLocations.map((e) {
      return DataRow(cells: [
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () {
                _deleteConfirmationDialog(e);
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showEditDialogue(e);
              },
            )
          ]
        )),
        DataCell(Text(e.locationName.toString())),
      ],
      color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        final subtleBlueTint1 = Color.fromRGBO(241, 245, 255, 1);
        final subtleBlueTint2 = Color.fromRGBO(230, 240, 255, 1);

        final color = counter.isEven ? subtleBlueTint1 : subtleBlueTint2;
        counter++;
        return color;
      }));
    }).toList();
  }

  void _deleteConfirmationDialog(Location loc){
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text("Are you sure you want to delete ${loc.locationName} as a location?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await locationService.deleteLocation(loc.locationId ?? 0);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  _fetchData();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete location: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
              '${_displayLocations.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayLocations.length}',
            ),
          ),
          _NeumorphicNavButton(
            icon: Icons.chevron_right,
            enabled: endIndex < _displayLocations.length,
            onPressed: nextPage,
            tooltip: 'Next Page',
          ),
        ],
      ),
    );
  }
}

class _AddDataButton extends StatefulWidget {
  const _AddDataButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_AddDataButton> createState() => _AddDataButtonState();
}

class _AddDataButtonState extends State<_AddDataButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: NeumorphicButton(
        onPressed: widget.onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        style: NeumorphicStyle(
          // --- This now works perfectly ---
          depth: _isHovered ? -4 : 4,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
          lightSource: LightSource.topLeft,
          color: Colors.white,
        ),
        child: const Text(
          'Add Data',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF01579B),
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}