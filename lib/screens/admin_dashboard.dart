import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _supabase = Supabase.instance.client;

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
      // 1. Bilangin ang total products
      final productsRes = await _supabase.from('products').select('id');
      _totalProducts = productsRes.length;

      // 2. Bilangin ang total services
      final servicesRes = await _supabase.from('services').select('id');
      _totalServices = servicesRes.length;

      // 3. Bilangin ang pending requests
      final quotesRes = await _supabase
          .from('quotations')
          .select('id')
          .eq('status', 'Pending');
      _pendingRequests = quotesRes.length;

      // 4. Kunin ang 5 pinakabagong requests para sa "Recent Activity"
      final recentRes = await _supabase
          .from('quotations')
          .select()
          .order('date_submitted', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _recentActivities = List<Map<String, dynamic>>.from(recentRes);
        });
      }
    } catch (e) {
      debugPrint('Dashboard Error: $e');
      if (mounted) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load dashboard data. Please check your internet connection.'),
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
                  child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
                )
              : _hasError
              ? Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load dashboard data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
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
                          backgroundColor: const Color(0xFFB71C1C),
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
                      Expanded(
                        flex: 2,
                        child: _buildPlaceholderChart('Request Volume Trend'),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: _buildPlaceholderChart('Status Distribution'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildPlaceholderChart('Request Volume Trend'),
                      const SizedBox(height: 16),
                      _buildPlaceholderChart('Status Distribution'),
                    ],
                  ),
            const SizedBox(height: 32),

            // TABLES & RECENT ACTIVITY SECTION (Magiging patayo pag mobile)
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildPlaceholderTable('Upcoming Appointments'),
                      ),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRecentActivity()),
                    ],
                  )
                : Column(
                    children: [
                      _buildPlaceholderTable('Upcoming Appointments'),
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
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'High-level operational metrics and recent activity for Katala Fire Protection.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: _fetchDashboardStats,
          icon: const Icon(Icons.refresh, color: Color(0xFFB71C1C), size: 18),
          label: const Text(
            'Refresh Data',
            style: TextStyle(color: Color(0xFFB71C1C)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFB71C1C)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
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
            child: _buildStatCard('TOTAL CUSTOMERS', '0', Icons.people_outline),
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
          _buildStatCard('TOTAL CUSTOMERS', '0', Icons.people_outline),
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlight
              ? const Color(0xFFB71C1C).withValues(alpha: 0.3)
              : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isHighlight ? const Color(0xFFB71C1C) : Colors.grey,
                  ),
                ),
              ),
              Icon(icon, size: 16, color: Colors.grey.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_recentActivities.isEmpty)
            const Text(
              'No recent activities.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            )
          else
            ..._recentActivities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFB71C1C),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New quotation requested by ${activity['customer_name']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['date_submitted']?.toString().substring(
                                  0,
                                  10,
                                ) ??
                                '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
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
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Chart Visualization UI Pending',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTable(String title) {
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Table UI Pending',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
