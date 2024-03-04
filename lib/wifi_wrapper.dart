import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'home.dart';

class WifiConnectWrapper extends StatefulWidget {
  const WifiConnectWrapper({super.key});

  @override
  State<WifiConnectWrapper> createState() => _WifiConnectWrapperState();
}

class _WifiConnectWrapperState extends State<WifiConnectWrapper> {
  bool _isConnected = false;
  String _ssid = "";

  @override
  void initState() {
    super.initState();
    _checkAndConnectWifi();
  }

  void _navigateToSettingsPage() {
    Navigator.pushReplacementNamed(context, '/settings');
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToSettingsPage();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkAndConnectWifi() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await Permission.location.request().isGranted) {
      return _showAlert('Location permission is required to connect to WiFi');
    }

    final String? ssid = prefs.getString('ssid');

    if (ssid == null || !prefs.containsKey('password')) {
      return _navigateToSettingsPage();
    }

    setState(() {
      _ssid = ssid;
    });

    if (!await WiFiForIoTPlugin.isEnabled()) {
      await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
    }

    await WiFiForIoTPlugin.connect(
      ssid,
      password: prefs.getString('password')!,
      joinOnce: true,
      isHidden: true,
      security: NetworkSecurity.WPA,
    ).catchError((error) {
      _showAlert(error.toString());
      return true;
    }).then((value) {
      if (!value) return _showAlert('Failed to connect to $ssid');

      WiFiForIoTPlugin.forceWifiUsage(true);

      setState(() {
        _isConnected = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected) {
      return const HomePage();
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Center(
            child: CircularProgressIndicator(),
          ),
          Center(
            child: Text('Connecting to $_ssid...'),
          ),
        ],
      ),
    );
  }
}
