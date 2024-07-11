import 'package:axcess/components/home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/colors.dart';

class HomeAccessories extends StatefulWidget {
  const HomeAccessories({Key? key}) : super(key: key);
  @override
  _HomeAccessoriesState createState() => _HomeAccessoriesState();
}

class _HomeAccessoriesState extends State<HomeAccessories> {
  static const platform = MethodChannel('axcessibility_notify');
  Map<String, Map<String, List<Map<String, String>>>> _homeAccessories = {};
  String? _selectedHome;
  bool editMode = false;
  Color _backgroundColor = wcagColorPairs[6].backgroundColor;
  double _fontSize = 20.0;

  @override
  void initState() {
    super.initState();
    _fetchAccessories();
  }

  Future<void> _fetchAccessories() async {
    try {
      final List<dynamic> result =
          await platform.invokeMethod('fetchAccessories');
      final List<Map<String, String>> accessories =
          result.map((item) => Map<String, String>.from(item)).toList();

      // Group accessories by home and room
      final Map<String, Map<String, List<Map<String, String>>>>
          homeAccessories = {};
      for (var accessory in accessories) {
        final home = accessory['home'] ?? 'Unknown Home';
        final room = accessory['room'] ?? 'Unknown Room';
        if (homeAccessories.containsKey(home)) {
          if (homeAccessories[home]!.containsKey(room)) {
            homeAccessories[home]![room]!.add(accessory);
          } else {
            homeAccessories[home]![room] = [accessory];
          }
        } else {
          homeAccessories[home] = {
            room: [accessory]
          };
        }
      }

      setState(() {
        _homeAccessories = homeAccessories;
        if (_homeAccessories.isNotEmpty) {
          _selectedHome = _homeAccessories.keys.first;
        }
      });
    } on PlatformException catch (e) {
      print("Failed to fetch accessories: '${e.message}'.");
    }
  }

  Future<void> _toggleAccessory(String name, String room) async {
    try {
      await platform
          .invokeMethod('toggleAccessory', {'name': name, 'room': room});
      print('Toggled accessory: $name in room: $room');
    } on PlatformException catch (e) {
      print("Failed to toggle accessory: '${e.message}'.");
    }
  }

  void toggleEditMode(bool value) {
    setState(() {
      editMode = value;
    });
  }

  void _changeBackgroundColor(Color color) {
    setState(() {
      _backgroundColor = color;
    });
  }

  void _incrementFontSize() {
    setState(() {
      _fontSize += 2;
    });
  }

  void _decrementFontSize() {
    setState(() {
      if (_fontSize > 8) _fontSize -= 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Accessories'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: SizedBox(
                child: Text('Admin'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.all(10)),
                const Text('Edit Mode'),
                Switch(value: editMode, onChanged: toggleEditMode)
              ],
            ),
            if (editMode)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Background Color:'),
                  ),
                  DropdownButton<Color>(
                    value: _backgroundColor,
                    items: wcagColorPairs
                        .map((colorPair) => DropdownMenuItem<Color>(
                              value: colorPair.backgroundColor,
                              child: Container(
                                width: 100,
                                height: 20,
                                color: colorPair.backgroundColor,
                              ),
                            ))
                        .toList(),
                    onChanged: (Color? newColor) {
                      if (newColor != null) {
                        _changeBackgroundColor(newColor);
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      Text('Font Size:'),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _decrementFontSize,
                      ),
                      Text('$_fontSize'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _incrementFontSize,
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
      body: _homeAccessories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Row(
              children: [
                if (_homeAccessories.length > 1)
                  NavigationRail(
                    selectedIndex: _homeAccessories.keys
                        .toList()
                        .indexOf(_selectedHome ?? ''),
                    onDestinationSelected: (index) {
                      setState(() {
                        _selectedHome = _homeAccessories.keys.toList()[index];
                      });
                    },
                    labelType: NavigationRailLabelType.selected,
                    destinations: _homeAccessories.keys
                        .map((home) => NavigationRailDestination(
                              icon: Icon(Icons.home),
                              selectedIcon: Icon(Icons.home_filled),
                              label: Text(home),
                            ))
                        .toList(),
                  ),
                if (_homeAccessories.length > 1)
                  VerticalDivider(thickness: 1, width: 1),
                if (_selectedHome != null &&
                    _homeAccessories[_selectedHome!] != null)
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(16.0),
                      children: _homeAccessories[_selectedHome!]!
                          .entries
                          .map((entry) {
                        final room = entry.key;
                        final accessories = entry.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.black54
                                    : Colors.grey.withOpacity(0.3),
                                blurRadius: 8.0,
                                spreadRadius: 1.0,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                SizedBox(height: 8.0),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: accessories.map((accessory) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 10.0),
                                        child: HomeButton(
                                          text: accessory['name']!,
                                          fontSize: _fontSize,
                                          backgroundColor: _backgroundColor,
                                          textColor: getTextColorForBackground(
                                              _backgroundColor),
                                          onPressed: () {
                                            _toggleAccessory(
                                                accessory['name']!, room);
                                          },
                                          onLongPress: () {},
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
    );
  }
}

class ColorPair {
  final Color backgroundColor;
  final Color textColor;

  ColorPair({required this.backgroundColor, required this.textColor});
}
