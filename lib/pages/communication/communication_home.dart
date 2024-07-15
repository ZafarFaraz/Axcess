import 'package:axcess/pages/communication/communication_contact.dart';
import 'package:axcess/pages/communication/communication_keypad.dart';
import 'package:flutter/material.dart';

class CommunicationHomePage extends StatefulWidget {
  const CommunicationHomePage({super.key});

  @override
  _CommunicationHomePageState createState() => _CommunicationHomePageState();
}

class _CommunicationHomePageState extends State<CommunicationHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[CommunicationKeypadPage()];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communicate'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dialpad),
                label: Text('Keypad'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  Icons.contacts,
                ),
                label: Text('Contacts'),
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                CommunicationKeypadPage(),
                CommunicationContactsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
