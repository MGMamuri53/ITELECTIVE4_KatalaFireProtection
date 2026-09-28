import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminCustomers extends StatefulWidget {
  const AdminCustomers({super.key});

  @override
  State<AdminCustomers> createState() => _AdminCustomersState();
}

class _AdminCustomersState extends State<AdminCustomers> {
  List<Map<String, dynamic>> _allCustomers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/admin/customers');

      if (mounted) {
        setState(() {
          _allCustomers = List<Map<String, dynamic>>.from(response);
          _filteredCustomers = _allCustomers;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load customer accounts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _allCustomers;
      } else {
        _filteredCustomers = _allCustomers.where((customer) {
          final firstName = (customer['first_name'] ?? '')
              .toString()
              .toLowerCase();
          final lastName = (customer['last_name'] ?? '')
              .toString()
              .toLowerCase();
          final email = (customer['email'] ?? '').toString().toLowerCase();
          final phone = (customer['contact_number'] ?? '')
              .toString()
              .toLowerCase();
          final searchLower = query.toLowerCase();

          return firstName.contains(searchLower) ||
              lastName.contains(searchLower) ||
              email.contains(searchLower) ||
              phone.contains(searchLower);
        }).toList();
      }
    });
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
          // WRAP PARA SA RESPONSIVE HEADER
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Registered Accounts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Directory of all clients registered in the Katala portal.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _fetchCustomers,
                icon: const Icon(
                  Icons.refresh,
                  color: AppColors.brand,
                  size: 18,
                ),
                label: const Text(
                  'Refresh List',
                  style: TextStyle(color: AppColors.brand),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.brand),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SEARCH BAR
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
                    onChanged: _filterCustomers,
                    decoration: const InputDecoration(
                      hintText: 'Search by Name or Email...',
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

          // RESPONSIVE TABLE WRAPPED IN HORIZONTAL SCROLL
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800, // MINIMUM WIDTH PARA HINDI MAG-SQUEEZE
                child: Column(
                  children: [
                    // TABLE HEADER
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
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'ACCOUNT ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'FULL NAME',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'EMAIL ADDRESS',
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
                              'CONTACT NUMBER',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TABLE BODY
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.brand,
                              ),
                            )
                          : _hasError
                          ? Center(
                              child: ElevatedButton(
                                onPressed: _fetchCustomers,
                                child: const Text('Retry'),
                              ),
                            )
                          : _filteredCustomers.isEmpty
                          ? const Center(
                              child: Text(
                                'No registered accounts found.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = _filteredCustomers[index];
                                final String id =
                                    customer['id']?.toString() ?? 'N/A';
                                final String shortId = id.length > 8
                                    ? id.substring(0, 8).toUpperCase()
                                    : id;
                                final String fullName =
                                    '${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'
                                        .trim();

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
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
                                        flex: 2,
                                        child: Text(
                                          '#$shortId',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.inkFaint,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: const Color(
                                                0xFFFFF0F0,
                                              ),
                                              child: Text(
                                                fullName.isNotEmpty
                                                    ? fullName[0].toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: AppColors.brand,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                fullName,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          customer['email'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          customer['contact_number'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.inkMuted,
                                          ),
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
