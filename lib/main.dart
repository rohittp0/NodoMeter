import 'package:flutter/material.dart';

import 'home.dart';
import 'settings.dart';
import 'wifi_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    routes: {
      '/settings': (context) => const SettingsPage(),
      '/wifi': (context) => const WifiConnectWrapper(),
      '/': (context) => const HomePage(),
    },
  ));
}
