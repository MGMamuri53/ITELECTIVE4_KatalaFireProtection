import 'package:flutter/material.dart';
import 'package:katala/theme/app_theme.dart';

class Homepage extends StatelessWidget {
  final VoidCallback onRequestQuote;
  final VoidCallback onExploreServices;
  final VoidCallback onViewCatalog;

  const Homepage({
    super.key,
    required this.onRequestQuote,
    required this.onExploreServices,
    required this.onViewCatalog,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Total Protection,\nUncompromising\nReliability',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Delivering professional fire safety services and precision-engineered suppression systems for industrial, commercial, and high-risk environments.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // HIGHLIGHTED PRIMARY ACTIONS (Separated Workflows)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onRequestQuote,
                        icon: const Icon(
                          Icons.engineering_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Request a Service Project',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand, // Katala Red
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onViewCatalog,
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Order Products',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF2C3E50,
                          ), // Dark Blue for separation
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Hero Image with System Active Badge
                    LayoutBuilder(
                      builder: (context, heroConstraints) {
                        final double heroHeight =
                            (heroConstraints.maxWidth * 9 / 16).clamp(
                              150.0,
                              320.0,
                            );
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?q=80&w=800&auto=format&fit=crop',
                                width: double.infinity,
                                height: heroHeight,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: double.infinity,
                                      height: heroHeight,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 50,
                                      ),
                                    ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.brand,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'System Active',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Trust Badges (REVISED TO REMOVE UNVERIFIED CLAIMS)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 20,
                      children: [
                        _buildTrustBadge(
                          Icons.verified_outlined,
                          'SEC Registered',
                        ),
                        _buildTrustBadge(
                          Icons.domain_verification_outlined,
                          'DTI Registered',
                        ),
                        _buildTrustBadge(
                          Icons.shield_outlined,
                          'BFP Compliant',
                        ),
                        _buildTrustBadge(
                          Icons.thumb_up_outlined,
                          'Quality Assured',
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Center(
                      child: Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Precision Equipment Section
                    const Text(
                      'Precision Equipment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Industrial-grade fire safety products engineered for maximum reliability in critical situations.',
                      style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                    ),
                    const SizedBox(height: 16),

                    _buildEquipmentCard(
                      icon: Icons.fire_extinguisher,
                      title: 'Extinguishers',
                      desc:
                          'Comprehensive range of ABC Dry Chemical, CO2, and specialized extinguishing units for all fire classes.',
                      onTap: onViewCatalog,
                    ),
                    const SizedBox(height: 12),
                    _buildEquipmentCard(
                      icon: Icons.notifications_active_outlined,
                      title: 'Alarm Systems',
                      desc:
                          'Addressable and conventional fire detection panels, sensors, and notification appliances.',
                      onTap: onViewCatalog,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // FOOTER
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.canvas,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.inkMuted, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.inkMuted),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEquipmentCard({
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.brand, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Text(
                        'View Specifications',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brand,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: AppColors.brand,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
