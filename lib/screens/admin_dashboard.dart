import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const double maxContentWidth = 1400;
  static const double splitBreakpoint = 900;
  static const double twoColumnBreakpoint = 560;
  static const double fourColumnBreakpoint = 1100;

  int _totalProducts = 0;
  int _totalServices = 0;
  int _pendingRequests = 0;
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  Future<void> _fetchDashboardStats() async {
    setState(() => _isLoading = true);
    _hasError = false;
    try {
      final response = await ApiClient.get('/admin/dashboard');
      _totalProducts = response['total_products'] ?? 0;
      _totalServices = response['total_services'] ?? 0;
      _pendingRequests = response['pending_quotes'] ?? 0;

      if (mounted) {
        setState(() {
          _recentActivities = List<Map<String, dynamic>>.from(
            response['recent_activities'] ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('Dashboard Error: $e');
      if (mounted) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to load dashboard data. Please check your internet connection.',
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isRoomy = constraints.maxWidth >= 1024;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isRoomy ? 32.0 : 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: LayoutBuilder(
                builder: (context, content) {
                  final gap = content.maxWidth >= twoColumnBreakpoint
                      ? 16.0
                      : 12.0;
                  final sectionGap = isRoomy ? 32.0 : 20.0;
                  final isSplit = content.maxWidth >= splitBreakpoint;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: sectionGap),
                      _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 48),
                                child: CircularProgressIndicator(
                                  color: AppColors.brand,
                                ),
                              ),
                            )
                          : _hasError
                          ? _buildErrorState()
                          : _buildStatsGrid(content.maxWidth, gap),
                      if (!_hasError) ...[
                        SizedBox(height: sectionGap),
                        if (isSplit)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildPlaceholderChart(
                                  'Request Volume Trend',
                                ),
                              ),
                              SizedBox(width: gap),
                              Expanded(
                                flex: 1,
                                child: _buildPlaceholderChart(
                                  'Status Distribution',
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildPlaceholderChart('Request Volume Trend'),
                              SizedBox(height: gap),
                              _buildPlaceholderChart('Status Distribution'),
                            ],
                          ),
                        SizedBox(height: sectionGap),
                        if (isSplit)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildPlaceholderTable(
                                  'Upcoming Appointments',
                                ),
                              ),
                              SizedBox(width: gap),
                              Expanded(flex: 1, child: _buildRecentActivity()),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildPlaceholderTable('Upcoming Appointments'),
                              SizedBox(height: gap),
                              _buildRecentActivity(),
                            ],
                          ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: KataUi.cardBox(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Unable to load dashboard data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your internet connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchDashboardStats,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'System Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'High-level operational metrics and recent activity for Katala Fire Protection.',
                style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: _fetchDashboardStats,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Refresh Data'),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(double availableWidth, double gap) {
    final columns = availableWidth >= fourColumnBreakpoint
        ? 4
        : availableWidth >= twoColumnBreakpoint
        ? 2
        : 1;

    final cards = <Widget>[
      _buildStatCard(
        'TOTAL ACTIVE PRODUCTS',
        _totalProducts.toString(),
        Icons.inventory_2_outlined,
      ),
      _buildStatCard(
        'TOTAL SERVICES',
        _totalServices.toString(),
        Icons.design_services_outlined,
      ),
      _buildStatCard(
        'PENDING SERVICE REQS',
        _pendingRequests.toString(),
        Icons.description_outlined,
        isHighlight: true,
      ),
      _buildStatCard('TOTAL CUSTOMERS', '0', Icons.people_outline),
    ];

    if (columns <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            cards[i],
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += columns) {
      final end = (i + columns) > cards.length ? cards.length : i + columns;
      final rowChildren = <Widget>[];
      for (var j = i; j < end; j++) {
        if (j > i) rowChildren.add(SizedBox(width: gap));
        rowChildren.add(Expanded(child: cards[j]));
      }
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rowChildren,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          rows[i],
        ],
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KataUi.radiusCard),
        border: Border.all(
          color: isHighlight
              ? AppColors.brand.withValues(alpha: 0.35)
              : AppColors.divider,
        ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: isHighlight ? AppColors.brand : AppColors.inkMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              KataUi.iconTile(
                icon,
                size: 16,
                background: isHighlight
                    ? AppColors.brandTint
                    : AppColors.surfaceMuted,
                foreground: isHighlight ? AppColors.brand : AppColors.inkMuted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              count,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: KataUi.cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),
          if (_recentActivities.isEmpty)
            const Text(
              'No recent activities.',
              style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
            )
          else
            ..._recentActivities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.brandTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'New quotation requested by ${activity['customer_name']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['date_submitted']?.toString().substring(
                                  0,
                                  10,
                                ) ??
                                '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPlaceholderChart(String title) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: KataUi.cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Chart Visualization UI Pending',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTable(String title) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: KataUi.cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Table UI Pending',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
