import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';
import 'product_catalog.dart';
import 'services_page.dart';
import 'portfolio_page.dart';
import 'company_profile.dart';
import 'admin_settings.dart';
import 'customer_orders.dart'; // IN-IMPORT NATIN YUNG BAGONG GINAWA MO PARA SA ORDERS

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final _supabase = Supabase.instance.client;

  // UPDATED: DETAILED REQUEST QUOTE FORM
  void _showRequestQuoteDialog(BuildContext context) {
    print('REQUEST QUOTE DIALOG OPENED');

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final locationController = TextEditingController();
    final detailsController = TextEditingController();
    String selectedService = 'System Installation'; // Default dropdown

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Request a Quote',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Color(0xFFB71C1C),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Provide detailed information for our safety engineers to evaluate your requirements accurately.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name / Company Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedService,
                    decoration: const InputDecoration(
                      labelText: 'Primary Service Needed',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'System Installation',
                              'Preventive Maintenance',
                              'Safety Inspection',
                              'Equipment Supply',
                              'System Repair',
                            ]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) selectedService = val;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Project Location (City, Province)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: detailsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Project Details & Specifications',
                      hintText:
                          'Describe the facility size, specific hazards, or current systems installed...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Name and Email are required.'),
                            ),
                          );
                          return;
                        }

                        final session = _supabase.auth.currentSession;
                        final accessToken = session?.accessToken;

                        try {
                          final response = await http.post(
                            Uri.parse(
                              'http://127.0.0.1:8000/api/service-requests',
                            ),
                            headers: {
                              'Accept': 'application/json',
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $accessToken',
                            },
                            body: jsonEncode({
                              'customer_id': 1,
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'contact_number': phoneController.text.trim(),
                              'service': selectedService,
                              'location': locationController.text.trim(),
                              'details': detailsController.text.trim(),
                            }),
                          );

                          if (response.statusCode == 201) {
                            if (context.mounted) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Request Submitted! We will email you shortly.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Request failed: ${response.body}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Request failed: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Submit Detailed Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFB71C1C)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF333333),
                height: 1.6,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFFB71C1C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Back from a section returns to Homepage instead of leaving the
        // main layout and revealing the login page.
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildCustomAppBar(),
        endDrawer: _buildNavigationDrawer(context),
        body: _buildBodyContent(),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: _currentIndex == 0
          ? null
          : IconButton(
              tooltip: 'Back to Homepage',
              icon: const Icon(Icons.arrow_back, color: Color(0xFFB71C1C)),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Katala Fire Protection',
            style: TextStyle(
              color: Color(0xFFB71C1C),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Safeguarding Lives and Assets',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => Scaffold.of(context).openEndDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB71C1C),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.menu, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Katala Fire Protection',
                          style: TextStyle(
                            color: Color(0xFFB71C1C),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Safeguarding Lives and Assets',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _buildMenuItem(
                    icon: Icons.home_outlined,
                    title: 'Homepage',
                    index: 0,
                  ),
                  _buildMenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Product Catalog',
                    index: 1,
                  ),
                  _buildMenuItem(
                    icon: Icons.construction_outlined,
                    title: 'Services',
                    index: 2,
                  ),
                  _buildMenuItem(
                    icon: Icons.cases_outlined,
                    title: 'Project Portfolio',
                    index: 3,
                  ),
                  _buildMenuItem(
                    icon: Icons.business_outlined,
                    title: 'Company Profile',
                    index: 4,
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    index: 5,
                  ),
                  _buildMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Orders',
                    index: 6,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close drawer first
                        _showRequestQuoteDialog(context); // Then open form
                      },
                      icon: const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Request Quote',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFooterLink(
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    () => _showLegalDialog(
                      context,
                      'Privacy Policy',
                      'Katala Fire Protection is committed to protecting your personal data...',
                    ),
                  ),
                  _buildFooterLink(
                    Icons.description_outlined,
                    'Terms of Service',
                    () => _showLegalDialog(
                      context,
                      'Terms of Service',
                      'By using the Katala Fire Protection application and services, you agree to abide by our operational terms...',
                    ),
                  ),
                  _buildFooterLink(
                    Icons.verified_outlined,
                    'ISO Certification',
                    () => _showLegalDialog(
                      context,
                      'ISO Certification',
                      'Katala Fire Protection strictly adheres to international standards for quality management...',
                    ),
                  ),
                  _buildFooterLink(
                    Icons.domain_outlined,
                    'Business Registration',
                    () => _showLegalDialog(
                      context,
                      'Business Registration',
                      'Katala Fire Protection Product Trading is officially registered with the SEC and DTI...',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
            InkWell(
              onTap: () async {
                await _supabase.auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.grey, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB71C1C), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFFB71C1C)
                      : const Color(0xFF333333),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 0:
        return Homepage(
          onRequestQuote: () => _showRequestQuoteDialog(context),
          onExploreServices: () => setState(() => _currentIndex = 2),
          onViewCatalog: () => setState(() => _currentIndex = 1),
        );
      case 1:
        return const ProductCatalog();
      case 2:
        // FIX: DINAGDAG NATIN YUNG onStartInquiry DITO PARA HINDI MAG-ERROR
        return ServicesPage(
          onStartInquiry: () => _showRequestQuoteDialog(context),
        );
      case 3:
        return const PortfolioPage();
      case 4:
        return CompanyProfile(
          onRequestQuote: () => _showRequestQuoteDialog(context),
        );
      case 5:
        return const AdminSettings();
      case 6:
        return const CustomerOrders();
      default:
        return Homepage(
          onRequestQuote: () => _showRequestQuoteDialog(context),
          onExploreServices: () => setState(() => _currentIndex = 2),
          onViewCatalog: () => setState(() => _currentIndex = 1),
        );
    }
  }
}
