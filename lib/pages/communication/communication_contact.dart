import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class CommunicationContactsPage extends StatefulWidget {
  const CommunicationContactsPage({super.key});

  @override
  _CommunicationContactsPageState createState() =>
      _CommunicationContactsPageState();
}

class _CommunicationContactsPageState extends State<CommunicationContactsPage> {
  static const platform = MethodChannel('axcessibility_notify');
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestContactPermission();
    _searchController.addListener(() {
      _filterContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _requestContactPermission() async {
    try {
      final bool granted =
          await platform.invokeMethod('requestContactPermission');
      if (granted) {
        _getContacts();
      } else {
        print('Contact permission denied');
      }
    } on PlatformException catch (e) {
      print("Failed to request contact permission: '${e.message}'.");
    }
  }

  Future<void> _getContacts() async {
    List<Contact> contacts = (await ContactsService.getContacts()).toList();
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
    });
    print("Contacts fetched: ${_contacts.length}");
  }

  void _filterContacts() {
    List<Contact> _contactsFiltered = [];
    _contactsFiltered.addAll(_contacts);
    if (_searchController.text.isNotEmpty) {
      _contactsFiltered.retainWhere((contact) {
        String searchTerm = _searchController.text.toLowerCase();
        String contactName = contact.displayName?.toLowerCase() ?? '';
        return contactName.contains(searchTerm);
      });
    }
    setState(() {
      _filteredContacts = _contactsFiltered;
    });
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _facetime(String phoneNumber) async {
    final Uri url = Uri(scheme: 'facetime', path: phoneNumber);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _scrollUp() {
    final double scrollAmount = 300.0; // Adjust this value as needed
    final double currentScroll = _scrollController.position.pixels;
    final double targetScroll = currentScroll - scrollAmount;

    _scrollController.animateTo(
      targetScroll < 0 ? 0 : targetScroll,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _scrollDown() {
    final double scrollAmount = 300.0; // Adjust this value as needed
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;
    final double targetScroll = currentScroll + scrollAmount;

    _scrollController.animateTo(
      targetScroll > maxScroll ? maxScroll : targetScroll,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search Contacts',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _scrollUp,
                  child: Container(
                    child: Center(
                      child: Icon(Icons.arrow_upward,
                          size: 36, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _scrollDown,
                  child: Container(
                    child: Center(
                      child: Icon(Icons.arrow_downward,
                          size: 36, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _filteredContacts.isEmpty
                    ? SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            Contact contact = _filteredContacts[index];
                            String? phoneNumber = contact.phones!.isNotEmpty
                                ? contact.phones!.first.value
                                : null;
                            return ListTile(
                              title: Text(contact.displayName ?? ''),
                              subtitle: phoneNumber != null
                                  ? Text(phoneNumber)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.phone),
                                    onPressed: phoneNumber != null
                                        ? () => _makeCall(phoneNumber)
                                        : null,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.videocam),
                                    onPressed: phoneNumber != null
                                        ? () => _facetime(phoneNumber)
                                        : null,
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: _filteredContacts.length,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        child: Icon(Icons.arrow_upward),
      ),
    );
  }
}
