import 'package:flutter/material.dart';
import 'package:katala/services/api_client.dart';

import 'screens/auth_page.dart';
import 'screens/admin_layout.dart';
import 'screens/main_layout.dart';
import 'theme/app_theme.dart';

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
      theme: KataTheme.light(),
      home: const _SessionHome(),
      routes: {
        '/app': (context) => const AuthPage(),
        '/main': (context) => const MainLayout(),
        '/admin': (context) => const AdminLayout(),
      },
    );
  }
}

class _SessionHome extends StatefulWidget {
  const _SessionHome();

  @override
  State<_SessionHome> createState() => _SessionHomeState();
}

class _SessionHomeState extends State<_SessionHome> {
  late final Future<Widget> _initialScreen = _resolveInitialScreen();

  Future<Widget> _resolveInitialScreen() async {
    final token = await ApiClient.token();
    final role = await ApiClient.role();
    if (token == null || token.isEmpty || role == null || role.isEmpty) {
      return const AuthPage();
    }
    return role.toLowerCase().contains('admin')
        ? const AdminLayout()
        : const MainLayout();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _initialScreen,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Unable to restore your session.')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
