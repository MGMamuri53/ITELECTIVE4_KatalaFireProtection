import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminServices extends StatefulWidget {
  const AdminServices({super.key});

  @override
  State<AdminServices> createState() => _AdminServicesState();
}

class _AdminServicesState extends State<AdminServices> {
  static const double maxContentWidth = 1280;
  static const double cardBreakpoint = 880;
  static const double tableMinWidth = 880;

  List<Map<String, dynamic>> _allServices = [];
  List<Map<String, dynamic>> _filteredServices = [];
  bool _isLoading = true;
  bool _hasError = false;
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
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    _hasError = false;
    try {
      final response = await ApiClient.get('/admin/services');
      if (mounted) {
        setState(() {
          _allServices = List<Map<String, dynamic>>.from(response);
          _filteredServices = _allServices;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to load services. Please check your internet connection.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterServices(String query) {
    if (_hasError) return; // Don't filter if there's an error

    setState(() {
      if (query.isEmpty) {
        _filteredServices = _allServices;
      } else {
        _filteredServices = _allServices.where((service) {
          final name = (service['service_name'] ?? '').toString().toLowerCase();
          final category = (service['category'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || category.contains(searchLower);
        }).toList();
      }
    });
  }

  void _showServiceDialog({Map<String, dynamic>? service}) {
    final isEditing = service != null;
    final nameController = TextEditingController(
      text: isEditing ? service['service_name'] : '',
    );
    final descController = TextEditingController(
      text: isEditing ? service['description'] : '',
    );

    String selectedCategory =
        (isEditing && _serviceCategories.contains(service['category']))
        ? service['category']
        : _serviceCategories.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
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
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _serviceCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedCategory = val;
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                final data = {
                  'service_name': nameController.text,
                  'category': selectedCategory,
                  'description': descController.text,
                };

                try {
                  if (isEditing) {
                    await ApiClient.put(
                      '/admin/services/${service['id']}',
                      data,
                    );
                  } else {
                    await ApiClient.post('/admin/services', data);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchServices();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing ? 'Service Updated!' : 'Service Added!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint(e.toString());
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

  void _deleteService(String id) async {
    try {
      await ApiClient.delete('/admin/services/$id');
      _fetchServices();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Container(
                margin: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // BINALOT NATIN SA WRAP PARA HINDI MA-CUT ANG BUTTON SA MOBILE
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 620,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Service Management',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Manage your offered fire protection services.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showServiceDialog(),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
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
                            SizedBox(height: isDesktop ? 24 : 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 44),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.canvas,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _filterServices,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Search Service Name or Category...',
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, content) =>
                            content.maxWidth < cardBreakpoint
                            ? _buildServiceCards()
                            : _buildServiceTable(content),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // BINALOT ANG HEADER AT LIST SA ISANG HORIZONTAL SCROLLVIEW
  Widget _buildServiceTable(BoxConstraints constraints) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: constraints.maxWidth < tableMinWidth
            ? tableMinWidth
            : constraints.maxWidth,
        height: constraints.maxHeight,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 2),
                ),
              ),
              child: Row(
                children: const [
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
                      child: CircularProgressIndicator(color: AppColors.brand),
                    )
                  : _hasError
                  ? _buildErrorState()
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
                              bottom: BorderSide(color: AppColors.surfaceMuted),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  service['service_name'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _actionButton(
                                      icon: Icons.edit_outlined,
                                      color: Colors.blue,
                                      tooltip: 'Edit service',
                                      onPressed: () =>
                                          _showServiceDialog(service: service),
                                    ),
                                    _actionButton(
                                      icon: Icons.delete_outline,
                                      color: Colors.red,
                                      tooltip: 'Delete service',
                                      onPressed: () =>
                                          _deleteService(service['id']),
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
    );
  }

  Widget _buildServiceCards() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }
    if (_hasError) return _buildErrorState();
    if (_filteredServices.isEmpty) {
      return const Center(
        child: Text(
          'No services match your search.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _filteredServices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      service['service_name'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  _actionButton(
                    icon: Icons.edit_outlined,
                    color: Colors.blue,
                    tooltip: 'Edit service',
                    onPressed: () => _showServiceDialog(service: service),
                  ),
                  _actionButton(
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    tooltip: 'Delete service',
                    onPressed: () => _deleteService(service['id']),
                  ),
                ],
              ),
              if ((service['description'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  service['description'].toString(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkFaint,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildMetaChip(
                    Icons.category_outlined,
                    service['category']?.toString() ?? '',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Unable to load services',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your internet connection',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchServices,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 18),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      onPressed: onPressed,
    );
  }

  Widget _buildMetaChip(IconData icon, String value) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.inkMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
