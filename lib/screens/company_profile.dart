import 'package:flutter/material.dart';
import 'package:katala/theme/app_theme.dart';

class CompanyProfile extends StatelessWidget {
  final VoidCallback onRequestQuote;

  const CompanyProfile({super.key, required this.onRequestQuote});

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
                children: [
                  _buildHeaderSection(),
                  _buildOriginSection(),
                  _buildMissionVision(),
                  _buildCoreValues(),
                  _buildCTASection(), // Hiwalay na Call-To-Action section
                ],
              ),
            ),
          ),
          _buildFooter(), // Updated Uniform Dark Footer
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Safeguarding Lives and Assets',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Katala Fire Protection Product Trading is a premier provider of life-safety equipment and highly engineered fire suppression solutions, dedicated to uncompromising reliability.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.inkMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Origin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Founded on the principle of absolute structural integrity and uncompromising safety, Katala emerged as a critical response to the growing demand for dependable, industrial-grade fire protection systems in modern facilities.\n\nWe don\'t just sell equipment; we engineer peace of mind through rigorous testing, certified deployment, and steadfast maintenance protocols.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.inkMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionVision() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoCard(
            icon: Icons.track_changes_outlined,
            title: 'Mission',
            description:
                'To deliver highly engineered, rigorously tested fire protection solutions that unequivocally safeguard human life, protect critical infrastructure, and ensure uninterrupted operational continuity for our clients.',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.visibility_outlined,
            title: 'Vision',
            description:
                'To be the industry standard-bearer for technical excellence and reliability in fire safety engineering across the region, recognized for our unwavering commitment to quality and precision.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.brandTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.brand, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brand,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreValues() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Core Values',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The principles that govern our engineering and service operations.',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final int columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 480
                  ? 2
                  : 1;
              const double gridSpacing = 12;
              final double cardWidth =
                  (constraints.maxWidth - gridSpacing * (columns - 1)) /
                  columns;
              return Wrap(
                spacing: gridSpacing,
                runSpacing: gridSpacing,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _buildValueCard(
                      Icons.health_and_safety,
                      'Safety',
                      'Absolute priority in all environments.',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildValueCard(
                      Icons.verified,
                      'Reliability',
                      'Consistent performance under pressure.',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildValueCard(
                      Icons.military_tech,
                      'Quality',
                      'Excellence in materials and execution.',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildValueCard(
                      Icons.engineering,
                      'Professionalism',
                      'Expertise driven technical conduct.',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildValueCard(
                      Icons.support_agent,
                      'Customer Care',
                      'Responsive, dedicated support.',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.brand, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }

  // BAGONG SECTION PARA SA CALL-TO-ACTION (REQUEST QUOTE)
  Widget _buildCTASection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: AppColors.surfaceMuted,
      child: Column(
        children: [
          const Text(
            'Ready to secure your facility?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Consult with our safety engineers today.',
            style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRequestQuote,
              icon: const Icon(
                Icons.engineering_outlined,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                'REQUEST SERVICE PROJECT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                padding: const EdgeInsets.symmetric(vertical: 16),
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

  // IN-UPDATE NA UNIFORM DARK FOOTER AT TINANGGAL ANG 'ISO CERTIFICATION'
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
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: const [
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text('•', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(
                'Terms of Service',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text('•', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(
                'SEC & DTI Registered',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
