import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'homepage.dart';
import 'product_catalog.dart';
import 'services_page.dart';
import 'portfolio_page.dart';
import 'company_profile.dart';
import 'admin_settings.dart';
import 'customer_orders.dart'; // IN-IMPORT NATIN YUNG BAGONG GINAWA MO PARA SA ORDERS
import 'package:katala/theme/app_theme.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  static const Map<String, List<String>> _provinceCities = {
    'Batangas': [
      'Batangas City',
      'Lipa City',
      'Tanauan City',
      'Sto. Tomas City',
      'Bauan',
      'Nasugbu',
    ],
    'Bulacan': [
      'Malolos City',
      'Meycauayan City',
      'San Jose del Monte City',
      'Bocaue',
      'Marilao',
      'Santa Maria',
    ],
    'Cavite': [
      'Bacoor City',
      'Cavite City',
      'Dasmarinas City',
      'General Trias City',
      'Imus City',
      'Tagaytay City',
      'Trece Martires City',
    ],
    'Laguna': [
      'Binan City',
      'Calamba City',
      'San Pablo City',
      'Santa Rosa City',
      'Los Banos',
      'San Pedro City',
    ],
    'Metro Manila': [
      'Caloocan City',
      'Las Pinas City',
      'Makati City',
      'Manila City',
      'Muntinlupa City',
      'Paranaque City',
      'Pasig City',
      'Quezon City',
      'Taguig City',
    ],
    'Rizal': [
      'Antipolo City',
      'Cainta',
      'Rodriguez',
      'San Mateo',
      'Taytay',
    ],
  };

  @override
  void initState() {
    super.initState();
    _restoreSection();
  }

  Future<void> _restoreSection() async {
    final section = await ApiClient.savedSection('Customer');
    if (!mounted || section < 0 || section > 6) return;
    setState(() => _currentIndex = section);
  }

  Future<void> _selectSection(int index) async {
    if (index < 0 || index > 6) return;
    setState(() => _currentIndex = index);
    try {
      await ApiClient.saveSection('Customer', index);
    } catch (error) {
      debugPrint('Unable to save customer navigation state: $error');
    }
  }

  // UPDATED: DETAILED REQUEST QUOTE FORM
  Future<void> _showRequestQuoteDialog(BuildContext context) async {
    final List<Map<String, dynamic>> services;
    try {
      services = List<Map<String, dynamic>>.from(
        await ApiClient.get('/services'),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load services: $error')),
        );
      }
      return;
    }
    if (!context.mounted) return;
    if (services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No services are currently available.')),
      );
      return;
    }

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final detailsController = TextEditingController();
    String selectedService = services.first['service_name'].toString();
    String? selectedProvince;
    String? selectedCity;

    try {
      final profileResponse = await ApiClient.get('/me');
      final user = Map<String, dynamic>.from(profileResponse['user'] ?? {});
      emailController.text = user['email']?.toString() ?? '';
      phoneController.text = user['contact_number']?.toString() ?? '';
    } catch (error) {
      debugPrint('Unable to prefill quote contact info: $error');
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final cities = selectedProvince == null
                ? const <String>[]
                : _provinceCities[selectedProvince] ?? const <String>[];

            return Dialog(
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
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.3,
                              color: AppColors.ink,
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Provide detailed information for our safety engineers to evaluate your requirements accurately.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Project / Company Name',
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (MediaQuery.of(context).size.width < 600)
                        Column(
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Number',
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Contact Number',
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
                        ),
                        items: services.map((service) {
                          final serviceName = service['service_name']
                              .toString();
                          return DropdownMenuItem(
                            value: serviceName,
                            child: Text(serviceName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) selectedService = val;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedProvince,
                        decoration: const InputDecoration(
                          labelText: 'Province',
                        ),
                        items: _provinceCities.keys.map((province) {
                          return DropdownMenuItem(
                            value: province,
                            child: Text(province),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedProvince = val;
                            selectedCity = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'City / Municipality',
                        ),
                        items: cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: selectedProvince == null
                            ? null
                            : (val) {
                                setDialogState(() => selectedCity = val);
                              },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: detailsController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Project Details & Specifications',
                          hintText:
                              'Describe the facility size, specific hazards, or current systems installed...',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final missingFields = <String>[];
                            if (nameController.text.trim().isEmpty) {
                              missingFields.add('Project / Company Name');
                            }
                            if (emailController.text.trim().isEmpty) {
                              missingFields.add('Email');
                            }
                            if (phoneController.text.trim().isEmpty) {
                              missingFields.add('Contact Number');
                            }
                            if (selectedService.trim().isEmpty) {
                              missingFields.add('Service');
                            }
                            if (selectedProvince == null) {
                              missingFields.add('Province');
                            }
                            if (selectedCity == null) {
                              missingFields.add('City / Municipality');
                            }
                            if (detailsController.text.trim().isEmpty) {
                              missingFields.add('Project Details');
                            }
                            if (missingFields.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please complete: ${missingFields.join(', ')}.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final accessToken = await ApiClient.token();
                            if (!context.mounted) return;

                            if (accessToken == null || accessToken.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please sign in before requesting a quote.',
                                  ),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                              return;
                            }

                            final projectLocation =
                                '$selectedCity, $selectedProvince';

                            try {
                              await ApiClient.post('/service-requests', {
                                'name': nameController.text.trim(),
                                'email': emailController.text.trim(),
                                'contact_number': phoneController.text.trim(),
                                'service': selectedService,
                                'location': projectLocation,
                                'details': detailsController.text.trim(),
                              });

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Request Submitted! We will email you shortly.',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Request failed: $e'),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Submit Detailed Request'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.ink,
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
                color: AppColors.inkSoft,
                height: 1.6,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          _selectSection(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: _buildCustomAppBar(),
        endDrawer: _buildMenuTile(context),
        body: _buildBodyContent(),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      leading: _currentIndex == 0
          ? null
          : IconButton(
              tooltip: 'Back to Homepage',
              icon: const Icon(Icons.arrow_back, color: AppColors.brand),
              onPressed: () => _selectSection(0),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Katala Fire Protection',
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.4,
            ),
          ),
          Text(
            'Safeguarding Lives and Assets',
            style: TextStyle(
              color: AppColors.inkMuted,
              fontSize: 11,
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
              borderRadius: BorderRadius.circular(10),
              onTap: () => Scaffold.of(context).openEndDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu, color: AppColors.brand, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.nav,
      child: Column(
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
                      'Katala',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Fire Protection',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close drawer first
                    _showRequestQuoteDialog(context); // Then open form
                  },
                  icon: const Icon(Icons.description_outlined, size: 20),
                  label: const Text('Request Quote'),
                ),
                const SizedBox(height: 24),
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
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.white54, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white54,
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
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    bool isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _selectSection(index);
          Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandTint : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.brand : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? AppColors.brand : Colors.white70,
                  ),
                ),
              ),
              Icon(
                isSelected ? Icons.check : Icons.chevron_right,
                color: isSelected ? AppColors.brand : Colors.white24,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
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
          onExploreServices: () => _selectSection(2),
          onViewCatalog: () => _selectSection(1),
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
          onExploreServices: () => _selectSection(2),
          onViewCatalog: () => _selectSection(1),
        );
    }
  }
}
