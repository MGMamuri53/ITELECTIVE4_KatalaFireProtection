import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'screens/auth_page.dart';
import 'screens/admin_layout.dart';
import 'screens/main_layout.dart';
import 'web/web_landing_page.dart';
import 'web/web_home_page.dart'; // BAGONG IMPORT PARA SA BLANK PAGE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const KatalaApp());
}

class KatalaApp extends StatelessWidget {
  const KatalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katala Fire Protection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFB71C1C),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB71C1C)),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => kIsWeb ? const WebLandingPage() : const AuthPage(),
        '/app': (context) => const AuthPage(),
        '/main': (context) => const MainLayout(),
        '/admin': (context) => const AdminLayout(),
        '/web-home': (context) =>
            const WebHomePage(), // BAGONG ROUTE PARA SA KA-GRUPO MO
      },
    );
  }
}
