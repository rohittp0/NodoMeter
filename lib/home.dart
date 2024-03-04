import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_iot/wifi_iot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _fuelLevel = 0; // Assume fuel level starts at 0
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchFuelLevel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final duration = Duration(seconds: prefs.getInt('refreshInterval') ?? 60);

    _timer = Timer.periodic(duration, (_) {
      if(context.mounted) {
        _fetchFuelLevel();
      }
    });
  }

  void _navigateToSettingsPage() {
    Navigator.pushReplacementNamed(context, '/settings');
  }

  void _navigateToWifiPage() {
    Navigator.pushReplacementNamed(context, '/wifi');
  }

  void _showSnackBar(String message) {
    if(!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  double _toFuelLevel(double value) {
    double voltage = value / 1024;
    return voltage ;
  }

  Future<void> _fetchFuelLevel() async {
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('url')) {
      return _navigateToSettingsPage();
    }

    if (await WiFiForIoTPlugin.getSSID() != prefs.getString('ssid')) {
      return _navigateToWifiPage();
    }

    try {
      final response = await http.get(Uri.parse(prefs.getString('url')!));
      if (response.statusCode == 200) {
        log(response.body);
        setState(() {
          _fuelLevel = _toFuelLevel(double.parse(response.body));
        });
      } else {
        // Handle server errors or invalid responses
        _showSnackBar('Server error: ${response.statusCode}');
        log('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error connecting to server');
      log('Error connecting to server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('NodoMeter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_gas_station,
                        size: 30,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '${(_fuelLevel * 100).toStringAsFixed(2)}%',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                    SizedBox(
                      height: 30,
                      child: LinearProgressIndicator(
                        value: _fuelLevel, //current / max
                        semanticsLabel: 'Fuel Level',
                        semanticsValue: '${(_fuelLevel * 100).toInt()}%',
                        backgroundColor: Colors.blue.shade100,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchFuelLevel,
        tooltip: 'Refresh Fuel Level',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
