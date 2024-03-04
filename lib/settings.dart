import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _refreshIntervalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _refreshIntervalController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _ssidController.text = prefs.getString('ssid') ?? 'bike';
    _passwordController.text = prefs.getString('password') ?? '';
    _urlController.text = prefs.getString('url') ?? 'http://192.168.1.1/read';
    _refreshIntervalController.text =
        prefs.getInt('refreshInterval')?.toString() ?? '60';
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }

  Future<void> _saveSettings() async {
    if (_ssidController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _urlController.text.isEmpty ||
        _refreshIntervalController.text.isEmpty) {
      return _showSnackBar('Please fill in all fields');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ssid', _ssidController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('url', _urlController.text);
    await prefs.setInt(
        'refreshInterval', int.parse(_refreshIntervalController.text));

    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextField(
                  controller: _ssidController,
                  decoration: const InputDecoration(labelText: 'WiFi SSID'),
                )),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'WiFi Password'),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Fuel Get URL'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: TextField(
                controller: _refreshIntervalController,
                decoration: const InputDecoration(labelText: 'Refresh Interval (s)'),
                keyboardType: TextInputType.number,
              ),
            ),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
