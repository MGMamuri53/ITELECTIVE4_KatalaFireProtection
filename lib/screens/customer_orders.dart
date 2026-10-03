import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class CustomerOrders extends StatefulWidget {
  const CustomerOrders({super.key});

  @override
  State<CustomerOrders> createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  List<Map<String, dynamic>> _myOrders = [];
  List<Map<String, dynamic>> _serviceRequests = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _selectedFilter = 0;

  static const _filters = ['All activity', 'Purchases', 'Services', 'Completed'];

  @override
  void initState() {
    super.initState();
    _fetchMyOrders();
  }

  Future<void> _fetchMyOrders() async {
    setState(() => _isLoading = true);
    _hasError = false;
    try {
      final accessToken = await ApiClient.token();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Please sign in before viewing orders.');
      }

      List<Map<String, dynamic>> orders = [];
      List<Map<String, dynamic>> serviceRequests = [];
      Object? ordersError;
      Object? serviceRequestsError;

      try {
        final data = await ApiClient.get('/orders/my');
        orders = List<Map<String, dynamic>>.from(data);
      } catch (error) {
        ordersError = error;
        debugPrint('Error fetching product orders: $error');
      }

      try {
        final data = await ApiClient.get('/service-requests/my');
        serviceRequests = List<Map<String, dynamic>>.from(data);
      } catch (error) {
        serviceRequestsError = error;
        debugPrint('Error fetching service requests: $error');
      }

      if (ordersError != null && serviceRequestsError != null) {
        throw Exception('Unable to load orders or service requests.');
      }

      setState(() {
        _myOrders = orders;
        _serviceRequests = serviceRequests;
      });

      if (mounted && (ordersError != null || serviceRequestsError != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Some order information could not be loaded.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (mounted) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to load orders. Please check your internet connection.',
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending confirmation':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
      case 'in transit':
        return Colors.purple;
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  List<Map<String, dynamic>> get _combinedItems {
    final items = <Map<String, dynamic>>[
      ..._myOrders.map((order) => {'type': 'product', 'data': order}),
      ..._serviceRequests.map((request) => {'type': 'service', 'data': request}),
    ];
    items.sort((a, b) {
      final aDate = _itemDate(a);
      final bDate = _itemDate(b);
      return bDate.compareTo(aDate);
    });
    if (_selectedFilter == 1) {
      return items.where((item) => item['type'] == 'product').toList();
    }
    if (_selectedFilter == 2) {
      return items.where((item) => item['type'] == 'service').toList();
    }
    if (_selectedFilter == 3) {
      return items.where((item) {
        final data = item['data'] as Map<String, dynamic>;
        final status = (item['type'] == 'service'
                ? data['status']
                : data['v_orderStatus'])
            ?.toString()
            .toLowerCase();
        return status == 'completed' || status == 'delivered';
      }).toList();
    }
    return items;
  }

  DateTime _itemDate(Map<String, dynamic> item) {
    final data = item['data'] as Map<String, dynamic>;
    final rawDate = item['type'] == 'service'
        ? data['created_at']
        : data['v_orderDate'];
    return DateTime.tryParse(rawDate?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Widget _buildStatusChip(String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildProductOrderCard(Map<String, dynamic> order) {
    final status = order['v_orderStatus'] ?? 'Pending';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order['v_orderNumber'] ?? 'N/A',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.brand,
                    ),
                  ),
                ),
                _buildStatusChip(status, statusColor),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'PRODUCT ORDER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.inkFaint,
              ),
            ),
            const Divider(height: 24, color: AppColors.surfaceMuted),
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order['v_productNameSnapshot'] ?? 'Unknown Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Text(
                  'Qty: ${order['v_quantity']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Date',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      _formatDate(order['v_orderDate'] ?? ''),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      '₱ ${double.tryParse(order['v_totalAmount'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRequestCard(Map<String, dynamic> request) {
    final status = request['status'] ?? 'Pending';
    final statusColor = _getStatusColor(status);
    final serviceName =
        request['service_name'] ?? request['project_type'] ?? 'Service Request';
    final details = request['details']?.toString() ?? '';
    final location = request['location']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request['request_number'] ?? 'REQ-${request['id'] ?? 'N/A'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.brand,
                    ),
                  ),
                ),
                _buildStatusChip(status, statusColor),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'SERVICE REQUEST',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.inkFaint,
              ),
            ),
            const Divider(height: 24, color: AppColors.surfaceMuted),
            Row(
              children: [
                const Icon(
                  Icons.design_services_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    serviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                details,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Date',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      _formatDate(request['created_at'] ?? ''),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (location.isNotEmpty)
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.brand),
            )
          : _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load orders',
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
                    onPressed: _fetchMyOrders,
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
          : RefreshIndicator(
              color: AppColors.brand,
              onRefresh: _fetchMyOrders,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: [
                  const Text(
                    'Activity & History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'View your previous purchases and service requests in one place.',
                    style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_filters.length, (index) {
                        final selected = _selectedFilter == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_filters[index]),
                            selected: selected,
                            selectedColor: AppColors.brand,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => setState(() => _selectedFilter = index),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_combinedItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        children: [
                          Icon(Icons.history_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 3 ? 'No completed activity' : 'No activity found',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.inkSoft),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your past purchases and service requests will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._combinedItems.map((item) {
                      final data = item['data'] as Map<String, dynamic>;
                      return item['type'] == 'service'
                          ? _buildServiceRequestCard(data)
                          : _buildProductOrderCard(data);
                    }),
                ],
              ),
            ),
    );
  }
}
