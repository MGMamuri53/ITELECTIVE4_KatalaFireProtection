import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class ServicesPage extends StatefulWidget {
  final VoidCallback onStartInquiry; // DINAGDAG NATIN ITO PARA MA-LINK SA FORM

  const ServicesPage({super.key, required this.onStartInquiry});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final response = await ApiClient.get('/services');
      if (!mounted) return;
      setState(() {
        _services = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _serviceIcon(String category) {
    return switch (category.toLowerCase()) {
      'installation' => Icons.construction_outlined,
      'inspection' || 'testing' => Icons.fact_check_outlined,
      'repair' => Icons.build_circle_outlined,
      'preventive maintenance' => Icons.settings_outlined,
      _ => Icons.design_services_outlined,
    };
  }

  void _showServiceDetails(
    BuildContext context,
    String title,
    String description,
    String category,
    String imageUrl,
    String priceLabel,
    String duration,
    String requirements,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.design_services, color: AppColors.brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(KataUi.radiusCard),
                    child: Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brandTintBorder),
                ),
                child: Text(
                  'Category: $category',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.inkSoft,
                  height: 1.5,
                ),
              ),
              if (priceLabel.isNotEmpty || duration.isNotEmpty) ...[
                const SizedBox(height: 16),
                if (priceLabel.isNotEmpty)
                  _buildInfoRow('Price range', priceLabel),
                if (duration.isNotEmpty)
                  _buildInfoRow('Estimated duration', duration),
              ],
              if (requirements.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Requirements',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  requirements,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.inkSoft,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            // DINAGDAG DIN NATIN ANG INQUIRY BUTTON SA LOOB NG DIALOG
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog first
                widget.onStartInquiry(); // Open inquiry form
              },
              child: const Text('Start service inquiry'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _servicePriceLabel(Map<String, dynamic> service) {
    final minPrice = double.tryParse(service['min_price']?.toString() ?? '');
    final maxPrice = double.tryParse(service['max_price']?.toString() ?? '');
    final basePrice = double.tryParse(service['base_price']?.toString() ?? '');

    if (minPrice != null && maxPrice != null && minPrice != maxPrice) {
      return 'PHP ${minPrice.toStringAsFixed(2)} - ${maxPrice.toStringAsFixed(2)}';
    }
    final price = minPrice ?? maxPrice ?? basePrice;
    if (price == null || price <= 0) return '';
    return 'PHP ${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeaderSection(), _buildServicesList(), _buildFooter()],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Fire Protection Services',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Explore our fire-protection services. When you are ready, start an inquiry and our team can help assess your project requirements.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.inkMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onStartInquiry,
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text(
                'Start service inquiry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Text('Unable to load services. $_loadError'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchServices,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No services are currently available.')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: _services.map((service) {
          final title = service['service_name']?.toString() ?? '';
          final desc = service['description']?.toString() ?? '';
          final category = service['category']?.toString() ?? 'Service';
          final imageUrl = service['image_url']?.toString() ?? '';
          final priceLabel = _servicePriceLabel(service);
          final duration = service['estimated_duration']?.toString() ?? '';
          final requirements = service['requirements']?.toString() ?? '';
          final serviceIcon = _serviceIcon(category);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KataUi.radiusCard),
              border: Border.all(color: AppColors.divider),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A12151C),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.brandTint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        serviceIcon,
                        color: AppColors.brand,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            desc,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (priceLabel.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              priceLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.brand,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // IN-UPDATE NATIN ANG BUTTONS DITO PARA DALAWA NA
                LayoutBuilder(
                  builder: (context, constraints) {
                    final detailsButton = OutlinedButton(
                      onPressed: () => _showServiceDetails(
                        context,
                        title,
                        desc,
                        category,
                        imageUrl,
                        priceLabel,
                        duration,
                        requirements,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.inkMuted,
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            KataTheme.radiusControl,
                          ),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Details'),
                    );
                    final inquiryButton = ElevatedButton.icon(
                      onPressed: widget.onStartInquiry,
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Start service inquiry'),
                    );

                    if (constraints.maxWidth < 360) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          detailsButton,
                          const SizedBox(height: 8),
                          inquiryButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: detailsButton),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: inquiryButton),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: AppColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.shield, color: AppColors.brand, size: 36),
          const SizedBox(height: 16),
          const Text(
            'Katala Fire Protection',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Safeguarding Lives and Assets',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.inkSoft),
          const SizedBox(height: 16),
          const Text(
            '© 2026 Katala Fire Protection Product Trading.\nAll rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 10, height: 1.5),
          ),
        ],
      ),
    );
  }
}
