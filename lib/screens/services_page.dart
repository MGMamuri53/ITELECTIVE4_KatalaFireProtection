import 'package:flutter/material.dart';
import 'package:katala/theme/app_theme.dart';

class ServicesPage extends StatefulWidget {
  final VoidCallback onStartInquiry; // DINAGDAG NATIN ITO PARA MA-LINK SA FORM

  const ServicesPage({super.key, required this.onStartInquiry});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  static const List<Map<String, dynamic>> _services = [
    {
      'title': 'Fire Extinguishers',
      'description':
          'Supply, selection, inspection, and servicing of portable fire extinguishers for your facility.',
      'icon': Icons.fire_extinguisher,
    },
    {
      'title': 'Fire Alarm & Detection Systems',
      'description':
          'Design, installation, testing, and maintenance of fire alarm and detection systems.',
      'icon': Icons.sensors,
    },
    {
      'title': 'Fire Sprinkler Systems',
      'description':
          'Sprinkler system design, installation, inspection, testing, and preventive maintenance.',
      'icon': Icons.shower_outlined,
    },
    {
      'title': 'Kitchen Suppression Systems',
      'description':
          'Fire suppression solutions for commercial kitchens, hoods, ducts, and cooking equipment.',
      'icon': Icons.restaurant_outlined,
    },
    {
      'title': 'Firefighting Equipment',
      'description':
          'Fire hoses, cabinets, hydrants, pumps, piping, and other firefighting equipment.',
      'icon': Icons.settings_outlined,
    },
    {
      'title': 'System Installation',
      'description':
          'Professional installation of fire-protection systems suited to your site requirements.',
      'icon': Icons.construction_outlined,
    },
    {
      'title': 'Maintenance & Inspection',
      'description':
          'Scheduled inspection, testing, repair, and preventive maintenance for existing systems.',
      'icon': Icons.build_circle_outlined,
    },
    {
      'title': 'Fire Safety Monitoring',
      'description':
          'Ongoing monitoring and support to help keep your fire-protection systems ready.',
      'icon': Icons.visibility_outlined,
    },
  ];

  void _showServiceDetails(
    BuildContext context,
    String title,
    String description,
    String category,
    String imageUrl,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          constraints: const BoxConstraints(maxWidth: 640),
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
          content: SingleChildScrollView(
            child: Column(
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
              ],
            ),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildHeaderSection(), _buildServicesList()],
              ),
            ),
          ),
          _buildFooter(),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int columns = constraints.maxWidth >= 920
              ? 3
              : constraints.maxWidth >= 560
              ? 2
              : 1;
          const double gridSpacing = 16;
          final double cardWidth =
              (constraints.maxWidth - gridSpacing * (columns - 1)) / columns;
          return Wrap(
            spacing: gridSpacing,
            runSpacing: 20,
            children: _services.map((service) {
              final title = service['title'] as String;
              final desc = service['description'] as String;
              final serviceIcon = service['icon'] as IconData;

              return SizedBox(
                width: cardWidth,
                child: Container(
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
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, actionConstraints) {
                          final textScale =
                              MediaQuery.textScalerOf(context).scale(14) / 14;
                          final stackActions =
                              actionConstraints.maxWidth < 300 ||
                              textScale > 1.3;
                          final detailsButton = OutlinedButton(
                            onPressed: () => _showServiceDetails(
                              context,
                              title,
                              desc,
                              'Fire Protection Service',
                              '',
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

                          if (stackActions) {
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
                              Expanded(flex: 1, child: detailsButton),
                              const SizedBox(width: 8),
                              Expanded(flex: 2, child: inquiryButton),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
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
