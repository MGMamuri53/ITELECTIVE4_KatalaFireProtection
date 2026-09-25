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
import 'package:katala/theme/app_theme.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  static const double desktopBreakpoint = 1300;
  static const double wideBreakpoint = 1536;

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
    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        final viewportWidth = viewportConstraints.maxWidth;
        final sidebarWidth = viewportWidth >= wideBreakpoint ? 260.0 : 232.0;
        final showSidebar = viewportWidth >= desktopBreakpoint;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: showSidebar
              ? null
              : AppBar(
                  backgroundColor: AppColors.nav,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: const Text(
                    'Katala Admin',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
          drawer: showSidebar
              ? null
              : Drawer(child: _buildSidebar(context, isDesktop: false)),
          body: SafeArea(
            top: showSidebar,
            child: Row(
              children: [
                if (showSidebar)
                  _buildSidebar(
                    context,
                    isDesktop: true,
                    desktopWidth: sidebarWidth,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      if (showSidebar) _buildTopAppBar(),
                      Expanded(child: _buildAdminBodyContent()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(
    BuildContext context, {
    required bool isDesktop,
    double desktopWidth = 232,
  }) {
    final sidebar = Container(
      color: AppColors.nav,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(isDesktop ? 20 : 16, 20, 12, 20),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Katala Admin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Safety Management',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
                        setState(() => _selectedIndex = index);
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
                            Expanded(
                              child: Text(
                                _menuItems[index]['title'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white60,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.white54, size: 20),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Logout',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!isDesktop) return sidebar;

    return SizedBox(width: desktopWidth, child: sidebar);
  }

  Widget _buildTopAppBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        return Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 28,
            vertical: 12,
          ),
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
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Admin Portal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Overview & management',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.inkMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
              SizedBox(width: isCompact ? 8 : 14),
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.brandTint,
                child: Icon(Icons.person, color: AppColors.brand, size: 18),
              ),
            ],
          ),
        );
      },
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
