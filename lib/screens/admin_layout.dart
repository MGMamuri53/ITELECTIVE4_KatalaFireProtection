import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'admin_dashboard.dart';
import 'admin_products.dart';
import 'admin_services.dart';
import 'admin_portfolio.dart';
import 'admin_requests.dart';
import 'admin_appointments.dart';
import 'admin_customers.dart';
import 'admin_accounts.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;
  bool _isCheckingAccess = true;
  bool _isAuthorized = false;

  // TINANGGAL NA NATIN ANG SETTINGS DITO
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard_outlined, 'title': 'Dashboard'},
    {'icon': Icons.inventory_2_outlined, 'title': 'Products'},
    {'icon': Icons.design_services_outlined, 'title': 'Services'},
    {'icon': Icons.cases_outlined, 'title': 'Portfolio'},
    {'icon': Icons.description_outlined, 'title': 'Requests'},
    {'icon': Icons.calendar_today_outlined, 'title': 'Appointments'},
    {'icon': Icons.people_outline, 'title': 'Customers'},
    {'icon': Icons.manage_accounts_outlined, 'title': 'Accounts'},
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final response = await ApiClient.get('/me');
      final user = Map<String, dynamic>.from(response['user'] ?? {});
      final role = user['role']?.toString().toLowerCase() ?? '';

      if (!mounted) return;

      if (!role.contains('admin')) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      setState(() {
        _isAuthorized = true;
        _isCheckingAccess = false;
      });
    } catch (e) {
      debugPrint('Admin authorization check failed: $e');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess || !_isAuthorized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF2C3E50),
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Katala Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

      drawer: isDesktop
          ? null
          : Drawer(child: _buildSidebar(context, isDesktop)),

      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, isDesktop),

          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildTopAppBar(),
                Expanded(child: _buildAdminBodyContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDesktop) {
    return Container(
      width: 260,
      color: const Color(0xFF2C3E50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Color(0xFFB71C1C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Katala Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Safety Management',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    if (!isDesktop) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFB71C1C)
                          : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _menuItems[index]['icon'],
                          color: isSelected ? Colors.white : Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _menuItems[index]['title'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // LOGOUT BUTTON SA ILALIM
          const Divider(color: Colors.white12, height: 1),
          InkWell(
            onTap: () async {
              try {
                await ApiClient.post('/logout', {});
              } catch (_) {
                // Local logout still clears the stale token if the server is unavailable.
              }
              await ApiClient.clearSession();
              if (context.mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  '/',
                ); // Babalik sa login page
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.white54, size: 20),
                  SizedBox(width: 16),
                  Text(
                    'Logout',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Admin Portal',
            style: TextStyle(
              color: Color(0xFFB71C1C),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.notifications_outlined, color: Colors.grey),
              SizedBox(width: 24),
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF2C3E50),
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return const AdminDashboard();
      case 1:
        return const AdminProducts();
      case 2:
        return const AdminServices();
      case 3:
        return const AdminPortfolio();
      case 4:
        return const AdminRequests();
      case 5:
        return const AdminAppointments();
      case 6:
        return const AdminCustomers();
      case 7:
        return const AdminAccounts();
      // TINANGGAL NA ANG CASE 8 (Settings)
      default:
        return const AdminDashboard();
    }
  }
}
