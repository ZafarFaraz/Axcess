import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunicationKeypadPage extends StatefulWidget {
  const CommunicationKeypadPage({super.key});

  @override
  _CommunicationKeypadPageState createState() =>
      _CommunicationKeypadPageState();
}

class _CommunicationKeypadPageState extends State<CommunicationKeypadPage> {
  String _phoneNumber = '';

  void _appendNumber(String number) {
    setState(() {
      _phoneNumber += number;
    });
  }

  void _deleteLastNumber() {
    if (_phoneNumber.isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
    }
  }

  void _clearNumber() {
    setState(() {
      _phoneNumber = '';
    });
  }

  Future<void> _makeCall() async {
    final Uri url = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _facetime() async {
    final Uri url = Uri(scheme: 'facetime', path: _phoneNumber);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                _phoneNumber,
                style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GridView.builder(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 2.0,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              if (index < 9) {
                return _buildNumberButton((index + 1).toString());
              } else if (index == 10) {
                return _buildSpecialButton(Icons.backspace, _deleteLastNumber);
              } else if (index == 9) {
                return _buildNumberButton('0');
              } else {
                return _buildSpecialButton(Icons.clear, _clearNumber);
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.phone, _makeCall),
              _buildActionButton(Icons.videocam, _facetime),
            ],
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      onPressed: () => _appendNumber(number),
      child: Text(
        number,
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildSpecialButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
      ),
      child: Icon(
        icon,
        size: 32,
      ),
    );
  }
}
