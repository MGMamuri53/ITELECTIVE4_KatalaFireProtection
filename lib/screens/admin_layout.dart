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
import 'admin_settings.dart';
import 'package:katala/theme/app_theme.dart';

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
    {'icon': Icons.settings_outlined, 'title': 'Account Settings'},
  ];

  @override
  void initState() {
    super.initState();
    _restoreSectionAndCheckAccess();
  }

  Future<void> _restoreSectionAndCheckAccess() async {
    final role = await ApiClient.role();
    if (role == null || !role.toLowerCase().contains('admin')) {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
      return;
    }
    final section = await ApiClient.savedSection('Admin');
    if (!mounted) return;
    if (section >= 0 && section < _menuItems.length) {
      setState(() => _selectedIndex = section);
    }
    await _checkAdminAccess();
  }

  Future<void> _selectAdminSection(int index) async {
    if (index < 0 || index >= _menuItems.length) return;
    setState(() => _selectedIndex = index);
    try {
      await ApiClient.saveSection('Admin', index);
    } catch (error) {
      debugPrint('Unable to save admin navigation state: $error');
    }
  }

  Future<void> _checkAdminAccess() async {
    try {
      final response = await ApiClient.get('/me');
      final user = Map<String, dynamic>.from(response['user'] ?? {});
      final role = user['role']?.toString().toLowerCase() ?? '';

      if (!mounted) return;

      if (!role.contains('admin')) {
        await ApiClient.clearSession();
        if (!mounted) return;
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
        final savedRole = await ApiClient.role();
        if (!mounted) return;
        if (savedRole != null && savedRole.toLowerCase().contains('admin')) {
          setState(() {
            _isAuthorized = true;
            _isCheckingAccess = false;
          });
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
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
      backgroundColor: AppColors.canvas,

      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.nav,
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
      color: AppColors.nav,
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
                    color: AppColors.brand,
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
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _selectAdminSection(index);
                      if (!isDesktop) {
                        Navigator.pop(context);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brand
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _menuItems[index]['icon'],
                            color: isSelected ? Colors.white : Colors.white60,
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _menuItems[index]['title'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.white54, size: 20),
                  SizedBox(width: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: AppColors.divider)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A12151C),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Admin Portal',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Overview & management',
                style: TextStyle(color: AppColors.inkMuted, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.inkMuted,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.brandTint,
                child: const Icon(
                  Icons.person,
                  color: AppColors.brand,
                  size: 18,
                ),
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
      case 8:
        return const AdminSettings();
      default:
        return const AdminDashboard();
    }
  }
}
