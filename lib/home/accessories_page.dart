import 'package:axcess/components/home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeAccessories extends StatefulWidget {
  const HomeAccessories({Key? key}) : super(key: key);
  @override
  _HomeAccessoriesState createState() => _HomeAccessoriesState();
}

class _HomeAccessoriesState extends State<HomeAccessories> {
  static const platform = MethodChannel('axcessibility_notify');
  Map<String, List<Map<String, String>>> _roomAccessories = {};

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

      // Group accessories by room
      final Map<String, List<Map<String, String>>> roomAccessories = {};
      for (var accessory in accessories) {
        final room = accessory['room'] ?? 'Unknown Room';
        if (roomAccessories.containsKey(room)) {
          roomAccessories[room]!.add(accessory);
        } else {
          roomAccessories[room] = [accessory];
        }
      }

      setState(() {
        _roomAccessories = roomAccessories;
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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Accessories'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black, Colors.grey[800]!]
                : [Colors.white, Colors.grey[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: _roomAccessories.entries.map((entry) {
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
                          color: isDarkMode ? Colors.white : Colors.black),
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
                              onPressed: () {
                                _toggleAccessory(accessory['name']!, room);
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
    );
  }
}
