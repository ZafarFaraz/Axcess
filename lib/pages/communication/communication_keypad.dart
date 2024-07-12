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
            child: Container(
              child: Center(
                child: Text(
                  _phoneNumber,
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          _buildKeypad(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(Icons.phone, _makeCall),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(Icons.videocam, _facetime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildKeypadRow([Icons.backspace, '0', Icons.clear]),
      ],
    );
  }

  Widget _buildKeypadRow(List<dynamic> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          items[i] is String
              ? _buildNumberButton(items[i])
              : _buildSpecialButton(
                  items[i],
                  items[i] == Icons.backspace
                      ? _deleteLastNumber
                      : _clearNumber),
        ]
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      onPressed: () => _appendNumber(number),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
        minimumSize: const Size(120, 120),
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildSpecialButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
        minimumSize: const Size(120, 120),
      ),
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
        shape: const RoundedRectangleBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Icon(
        icon,
        size: 32,
      ),
    );
  }
}
