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
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _ssidController.text = prefs.getString('ssid') ?? '';
    _passwordController.text = prefs.getString('password') ?? '';
    _urlController.text = prefs.getString('url') ?? '';
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ssid', _ssidController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('url', _urlController.text);

    if (_ssidController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _urlController.text.isEmpty) {
      return;
    }

    _goBack();
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
