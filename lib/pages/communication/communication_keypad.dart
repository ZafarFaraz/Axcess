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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                _phoneNumber,
                style:
                    const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildKeypad(),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.phone, _makeCall),
                    const SizedBox(height: 20),
                    _buildActionButton(Icons.videocam, _facetime),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonSize = (constraints.maxWidth - 80) / 4;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildKeypadRow(['1', '2', '3'], buttonSize),
            _buildKeypadRow(['4', '5', '6'], buttonSize),
            _buildKeypadRow(['7', '8', '9'], buttonSize),
            _buildKeypadRow([Icons.backspace, '0', Icons.clear], buttonSize),
          ],
        );
      },
    );
  }

  Widget _buildKeypadRow(List<dynamic> items, double buttonSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.all(8.0), // Add padding around buttons
          child: item is String
              ? _buildNumberButton(item, buttonSize)
              : _buildSpecialButton(item, buttonSize),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number, double buttonSize) {
    return ElevatedButton(
      onPressed: () => _appendNumber(number),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(), backgroundColor: Colors.grey[800],
        minimumSize: Size(buttonSize, buttonSize), // Change color as needed
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 36, color: Colors.white),
      ),
    );
  }

  Widget _buildSpecialButton(dynamic icon, double buttonSize) {
    return ElevatedButton(
      onPressed: icon == Icons.backspace ? _deleteLastNumber : _clearNumber,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(), backgroundColor: Colors.grey[800],
        minimumSize: Size(buttonSize, buttonSize), // Change color as needed
      ),
      child: Icon(
        icon,
        size: 36,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 400,
      height: 200,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(30)),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 32),
        ),
        child: Icon(
          icon,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}
