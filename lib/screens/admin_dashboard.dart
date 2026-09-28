import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _totalProducts = 0;
  int _totalServices = 0;
  int _pendingRequests = 0;
  int _totalCustomers = 0;
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _requestVolume = [];
  List<Map<String, dynamic>> _requestStatuses = [];
  List<Map<String, dynamic>> _upcomingAppointments = [];
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
      _totalCustomers = response['total_customers'] ?? 0;

      if (mounted) {
        setState(() {
          _requestVolume = List<Map<String, dynamic>>.from(
            response['request_volume'] ?? [],
          );
          _requestStatuses = List<Map<String, dynamic>>.from(
            response['request_statuses'] ?? [],
          );
          _upcomingAppointments = List<Map<String, dynamic>>.from(
            response['upcoming_appointments'] ?? [],
          );
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
    // ETO ANG LOGIC PARA MALAMAN KUNG NAKA-MOBILE O DESKTOP
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isDesktop ? 32.0 : 16.0,
      ), // Mas maliit na padding pag mobile
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.brand),
                )
              : _hasError
              ? Center(
                  child: Column(
                    children: [
                      Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load dashboard data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please check your internet connection and try again',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchDashboardStats,
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
              : _buildStatsRow(isDesktop), // Ipinasa natin ang isDesktop dito
          if (!_hasError) const SizedBox(height: 32),

          // CHARTS SECTION (Magiging patayo pag mobile)
          if (!_hasError) ...[
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildRequestVolumeChart()),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRequestStatusChart()),
                    ],
                  )
                : Column(
                    children: [
                      _buildRequestVolumeChart(),
                      const SizedBox(height: 16),
                      _buildRequestStatusChart(),
                    ],
                  ),
            const SizedBox(height: 32),

            // TABLES & RECENT ACTIVITY SECTION (Magiging patayo pag mobile)
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildUpcomingAppointments()),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRecentActivity()),
                    ],
                  )
                : Column(
                    children: [
                      _buildUpcomingAppointments(),
                      const SizedBox(height: 16),
                      _buildRecentActivity(),
                    ],
                  ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // GINAWANG WRAP PARA BUMABA ANG BUTTON KUNG HINDI KASYA SA MOBILE
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        OutlinedButton.icon(
          onPressed: _fetchDashboardStats,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Refresh Data'),
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isDesktop) {
    // KAPAG NAKA DESKTOP, NAKATABI-TABI (Row)
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'TOTAL ACTIVE PRODUCTS',
              _totalProducts.toString(),
              Icons.inventory_2_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'TOTAL SERVICES',
              _totalServices.toString(),
              Icons.design_services_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'PENDING SERVICE REQS',
              _pendingRequests.toString(),
              Icons.description_outlined,
              isHighlight: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'TOTAL CUSTOMERS',
              _totalCustomers.toString(),
              Icons.people_outline,
            ),
          ),
        ],
      );
    }
    // KAPAG NAKA MOBILE, MAGPAPATONG-PATONG (Column) PARA DI MA-SQUEEZE
    else {
      return Column(
        children: [
          _buildStatCard(
            'TOTAL ACTIVE PRODUCTS',
            _totalProducts.toString(),
            Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'TOTAL SERVICES',
            _totalServices.toString(),
            Icons.design_services_outlined,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'PENDING SERVICE REQS',
            _pendingRequests.toString(),
            Icons.description_outlined,
            isHighlight: true,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'TOTAL CUSTOMERS',
            _totalCustomers.toString(),
            Icons.people_outline,
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Container(
      width: double.infinity, // PARA SAKUPIN ANG BUONG LAPAD SA MOBILE
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: isHighlight ? AppColors.brand : AppColors.inkMuted,
                  ),
                ),
              ),
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
          Text(
            count,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.ink,
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
                        children: [
                          Text(
                            activity['description']?.toString().isNotEmpty ==
                                    true
                                ? activity['description'].toString()
                                : '${activity['action_type']} ${activity['table_name']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['created_at']?.toString().substring(
                                  0,
                                  10,
                                ) ??
                                '',
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

  Widget _buildRequestVolumeChart() {
    final maximum = _requestVolume.fold<int>(1, (value, item) {
      final count = int.tryParse(item['count'].toString()) ?? 0;
      return count > value ? count : value;
    });
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: KataUi.cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Volume Trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _requestVolume.isEmpty
                ? const Center(
                    child: Text(
                      'No request history available.',
                      style: TextStyle(color: AppColors.inkMuted),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _requestVolume.map((item) {
                      final count = int.tryParse(item['count'].toString()) ?? 0;
                      return Row(
                        children: [
                          SizedBox(
                            width: 38,
                            child: Text(
                              item['month']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: count / maximum,
                                minHeight: 12,
                                backgroundColor: AppColors.surfaceMuted,
                                color: AppColors.brand,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 34,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestStatusChart() {
    final total = _requestStatuses.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item['count'].toString()) ?? 0),
    );
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: KataUi.cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Status Distribution',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _requestStatuses.isEmpty
                ? const Center(
                    child: Text(
                      'No service requests available.',
                      style: TextStyle(color: AppColors.inkMuted),
                    ),
                  )
                : ListView(
                    children: _requestStatuses.map((item) {
                      final count = int.tryParse(item['count'].toString()) ?? 0;
                      final ratio = total == 0 ? 0.0 : count / total;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['status']?.toString() ?? 'Unknown',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: ratio,
                              minHeight: 6,
                              backgroundColor: AppColors.surfaceMuted,
                              color: AppColors.brand,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: KataUi.cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Appointments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _upcomingAppointments.isEmpty
                ? const Center(
                    child: Text(
                      'No upcoming appointments.',
                      style: TextStyle(color: AppColors.inkMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _upcomingAppointments.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final appointment = _upcomingAppointments[index];
                      final date = DateTime.tryParse(
                        appointment['scheduled_date'].toString(),
                      );
                      final dateLabel = date == null
                          ? 'Date TBD'
                          : '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          appointment['project_name']?.toString() ??
                              'Project visit',
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${appointment['customer_name'] ?? 'Customer'} • $dateLabel',
                        ),
                        trailing: Text(
                          appointment['status']?.toString() ?? '',
                          style: const TextStyle(
                            color: AppColors.brand,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
