import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:katala/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';

class AdminServices extends StatefulWidget {
  const AdminServices({super.key});

  @override
  State<AdminServices> createState() => _AdminServicesState();
}

class _AdminServicesState extends State<AdminServices> {
  List<Map<String, dynamic>> _allServices = [];
  List<Map<String, dynamic>> _filteredServices = [];
  bool _isLoading = true;
  bool _hasError = false;
  static const _servicesCacheKey = 'admin_services_cache';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _serviceCategories = [
    'Installation',
    'Inspection',
    'Testing',
    'Repair',
    'Preventive Maintenance',
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final cachedServices = preferences.getString(_servicesCacheKey);
      if (cachedServices != null && mounted) {
        final services = List<Map<String, dynamic>>.from(
          (jsonDecode(cachedServices) as List).map(
            (service) => Map<String, dynamic>.from(service as Map),
          ),
        );
        setState(() {
          _allServices = services;
          _filteredServices = _filterList(services, _searchController.text);
          _isLoading = false;
        });
      }
    } on FormatException catch (error) {
      debugPrint('Ignoring invalid cached services: $error');
    } on TypeError catch (error) {
      debugPrint('Ignoring invalid cached services: $error');
    } catch (error) {
      debugPrint('Unable to read cached services: $error');
    }
    await _fetchServices(showLoading: _allServices.isEmpty);
  }

  Future<void> _fetchServices({bool showLoading = false}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = showLoading;
      _hasError = false;
    });

    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      final response = await ApiClient.get(
        '/admin/services',
        timeout: const Duration(seconds: 10),
      );
      if (!mounted) return;

      final services = List<Map<String, dynamic>>.from(response);
      setState(() {
        _allServices = services;
        _filteredServices = _filterList(services, _searchController.text);
      });
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(_servicesCacheKey, jsonEncode(services));
      } catch (error) {
        debugPrint('Unable to cache services: $error');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = _allServices.isEmpty;
      });
      if (_allServices.isEmpty && context.mounted) {
        messenger?.showSnackBar(
          SnackBar(content: Text('Unable to load services: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterServices(String query) {
    if (_hasError) return;

    setState(() {
      _filteredServices = _filterList(_allServices, query);
    });
  }

  List<Map<String, dynamic>> _filterList(
    List<Map<String, dynamic>> services,
    String query,
  ) {
    final searchLower = query.trim().toLowerCase();
    if (searchLower.isEmpty) return List<Map<String, dynamic>>.from(services);
    return services.where((service) {
      final name = (service['service_name'] ?? '').toString().toLowerCase();
      final category = (service['category'] ?? '').toString().toLowerCase();
      return name.contains(searchLower) || category.contains(searchLower);
    }).toList();
  }

  void _showServiceDialog({Map<String, dynamic>? service}) {
    final isEditing = service != null;

    String serviceName = '';
    String serviceDescription = '';
    String servicePrice = '';
    String selectedCategory = _serviceCategories.first;

    if (isEditing) {
      serviceName = (service['service_name'] ?? '').toString();
      serviceDescription = (service['description'] ?? '').toString();
      servicePrice = (service['base_price'] ?? '').toString();

      final category = service['category'];
      if (_serviceCategories.contains(category)) {
        selectedCategory = category.toString();
      }
    }

    final nameController = TextEditingController(text: serviceName);
    final descController = TextEditingController(text: serviceDescription);
    final priceController = TextEditingController(text: servicePrice);
    final mainMessenger = ScaffoldMessenger.maybeOf(context);
    final mainNavigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            isEditing ? 'Edit Service' : 'Add New Service',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _serviceCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedCategory = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Base price',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final cleanedName = nameController.text.trim();
                if (cleanedName.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Service name is required.')),
                  );
                  return;
                }

                final rawPrice = priceController.text.trim();
                final basePrice = rawPrice.isEmpty
                    ? null
                    : double.tryParse(rawPrice);
                if (rawPrice.isNotEmpty &&
                    (basePrice == null || basePrice < 0)) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Enter a valid base price.')),
                  );
                  return;
                }

                final data = {
                  'service_name': cleanedName,
                  'category': selectedCategory,
                  'description': descController.text.trim(),
                  'base_price': basePrice,
                };

                try {
                  if (isEditing) {
                    final serviceId = service['id'];
                    if (serviceId == null) {
                      return;
                    }
                    await ApiClient.put('/admin/services/$serviceId', data);
                  } else {
                    await ApiClient.post('/admin/services', data);
                  }

                  if (!mounted) return;
                  mainNavigator.pop();

                  await _fetchServices();

                  if (!mounted) return;
                  mainMessenger?.showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing ? 'Service Updated!' : 'Service Added!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  mainMessenger?.showSnackBar(
                    SnackBar(content: Text('Unable to save service: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
              child: Text(
                isEditing ? 'Update' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteService(String id) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Archive service?'),
          content: const Text(
            'This service will be hidden from customer listings; existing requests remain unchanged.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Archive'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await ApiClient.delete('/admin/services/$id');
      await _fetchServices();

      if (!context.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(content: Text('Service archived.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        SnackBar(content: Text('Unable to archive service: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage your offered fire protection services.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showServiceDialog(),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  'Add Service',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterServices,
                    decoration: const InputDecoration(
                      hintText: 'Search Service Name or Category...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 900,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.divider,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'SERVICE NAME',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'CATEGORY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'DESCRIPTION',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'ACTIONS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.brand,
                              ),
                            )
                          : _hasError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Unable to load services',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.inkSoft,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Please check your internet connection',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _fetchServices,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brand,
                                    ),
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _filteredServices.isEmpty
                          ? const Center(
                              child: Text(
                                'No services match your search.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredServices.length,
                              itemBuilder: (context, index) {
                                final service = _filteredServices[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.surfaceMuted,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          service['service_name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          service['category'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          service['description'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.inkFaint,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Colors.blue,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  _showServiceDialog(
                                                    service: service,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              onPressed: () => _deleteService(
                                                service['id'].toString(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
