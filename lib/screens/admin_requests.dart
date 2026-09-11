import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AdminRequests extends StatefulWidget {
  const AdminRequests({super.key});

  @override
  State<AdminRequests> createState() => _AdminRequestsState();
}

class _AdminRequestsState extends State<AdminRequests> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  // BAGONG TABS PARA SA STRUCTURED WORKFLOW
  final List<String> _tabs = [
    'All Projects',
    'Inquiry / Requirements',
    'Design & Engineering',
    'Quotation & Approvals',
    'Installation Progress',
    'Completion & Warranty',
  ];

  // BUONG PROJECT LIFECYCLE STATUSES
  final List<String> _projectStatuses = [
    'Inquiry / Requirements',
    'Design & Engineering',
    'Quotation & Approvals',
    'Payment Arrangement',
    'Installation Progress',
    'Completion & Warranty',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/admin/requests');
      setState(() {
        _requests = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRespondDialog(Map<String, dynamic> request) {
    String rawStatus = request['status'] ?? 'Inquiry / Requirements';

    // MAPPING PARA SA MGA LUMANG DATA NA 'PENDING' O 'UNDER REVIEW'
    if (rawStatus == 'Pending') rawStatus = 'Inquiry / Requirements';
    if (rawStatus == 'Under Review') rawStatus = 'Design & Engineering';
    if (rawStatus == 'Quoted') rawStatus = 'Quotation & Approvals';

    String newStatus = _projectStatuses.contains(rawStatus)
        ? rawStatus
        : 'Inquiry / Requirements';

    final responseController = TextEditingController(
      text: request['admin_response'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final isDialogDesktop = MediaQuery.of(context).size.width > 800;

        final clientDetails = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Project ${request['reference_no']}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Client Name', request['customer_name'] ?? 'N/A'),
            _buildInfoRow('Email', request['email'] ?? 'N/A'),
            _buildInfoRow('Contact', request['contact_number'] ?? 'N/A'),
            _buildInfoRow('Location', request['location'] ?? 'N/A'),
            _buildInfoRow('Service Req.', request['request_type'] ?? 'N/A'),
            const SizedBox(height: 16),
            const Text(
              'Client Notes / Details:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                request['details'] ?? 'No additional details provided.',
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ],
        );

        final adminActions = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Project Tracker Workflow',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Current Stage:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: newStatus,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _projectStatuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) newStatus = val;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Official Remarks / Document Links (Quotation, Design, Billing):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: responseController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText:
                    'Paste links to approved designs, quotation docs, or billing invoices here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ApiClient.put('/admin/requests/${request['id']}', {
                        'status': newStatus,
                        'admin_response': responseController.text,
                      });

                      if (mounted) {
                        Navigator.pop(context);
                        _fetchRequests();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Project Stage & Documents Updated!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Update Project',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.all(isDialogDesktop ? 32 : 16),
          child: Container(
            width: isDialogDesktop ? 800 : double.infinity,
            padding: EdgeInsets.all(isDialogDesktop ? 32.0 : 16.0),
            child: SingleChildScrollView(
              child: isDialogDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: clientDetails),
                        const SizedBox(width: 32),
                        Expanded(child: adminActions),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        clientDetails,
                        const SizedBox(height: 32),
                        adminActions,
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    List<Map<String, dynamic>> filteredRequests = _requests;
    if (_selectedTab != 0) {
      String filterStatus = _tabs[_selectedTab];
      filteredRequests = _requests.where((req) {
        String status = req['status'] ?? 'Inquiry / Requirements';
        // MAP LEGACY STATUSES FOR FILTERING
        if (status == 'Pending') status = 'Inquiry / Requirements';
        if (status == 'Under Review') status = 'Design & Engineering';
        if (status == 'Quoted') status = 'Quotation & Approvals';
        return status == filterStatus;
      }).toList();
    }

    int inquiryCount = _requests
        .where(
          (r) =>
              r['status'] == 'Pending' ||
              r['status'] == 'Inquiry / Requirements',
        )
        .length;
    int quoteCount = _requests
        .where(
          (r) =>
              r['status'] == 'Quoted' || r['status'] == 'Quotation & Approvals',
        )
        .length;
    int installationCount = _requests
        .where((r) => r['status'] == 'Installation Progress')
        .length;

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      'Service Project Tracker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track service inquiries from requirements, design, quotation, to installation and warranty.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _fetchRequests,
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFFB71C1C),
                    size: 18,
                  ),
                  label: const Text(
                    'Refresh List',
                    style: TextStyle(color: Color(0xFFB71C1C)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFB71C1C)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'TOTAL PROJECTS',
                          _requests.length.toString(),
                          Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'INQUIRIES',
                          inquiryCount.toString(),
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'QUOTATIONS',
                          quoteCount.toString(),
                          Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'INSTALLATIONS',
                          installationCount.toString(),
                          Colors.indigo,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildStatCard(
                        'TOTAL PROJECTS',
                        _requests.length.toString(),
                        Colors.black,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        'INQUIRIES',
                        inquiryCount.toString(),
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        'QUOTATIONS',
                        quoteCount.toString(),
                        Colors.deepPurple,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        'INSTALLATIONS',
                        installationCount.toString(),
                        Colors.indigo,
                      ),
                    ],
                  ),

            const SizedBox(height: 32),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTabs(),
            ),
            const SizedBox(height: 16),

            _buildTable(filteredRequests),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: List.generate(_tabs.length, (index) {
        bool isSelected = _selectedTab == index;
        return InkWell(
          onTap: () => setState(() => _selectedTab = index),
          child: Container(
            margin: const EdgeInsets.only(right: 24),
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? const Color(0xFFB71C1C)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              _tabs[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFB71C1C) : Colors.grey,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> requests) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1000, // ADJUSTED WIDTH PARA MAGKASYA ANG MAHABANG STATUS
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 2),
                ),
              ),
              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'PROJECT REF.',
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
                      'CLIENT NAME',
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
                      'PROJECT TYPE',
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
                      'DATE LOGGED',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3, // BINIGYAN NG MAS MALAKING ESPASYO ANG STATUS
                    child: Text(
                      'CURRENT STAGE',
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

            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  )
                : requests.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No service projects found in this stage.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];

                      // FIX LEGACY STATUSES FOR DISPLAY
                      String status = req['status'] ?? 'Inquiry / Requirements';
                      if (status == 'Pending') {
                        status = 'Inquiry / Requirements';
                      }
                      if (status == 'Under Review') {
                        status = 'Design & Engineering';
                      }
                      if (status == 'Quoted') status = 'Quotation & Approvals';

                      // ASSIGN COLORS BASE SA PROJECT STAGE
                      Color statusColor = Colors.grey;
                      if (status == 'Inquiry / Requirements') {
                        statusColor = Colors.orange;
                      }
                      if (status == 'Design & Engineering') {
                        statusColor = Colors.blue;
                      }
                      if (status == 'Quotation & Approvals') {
                        statusColor = Colors.deepPurple;
                      }
                      if (status == 'Payment Arrangement') {
                        statusColor = Colors.teal;
                      }
                      if (status == 'Installation Progress') {
                        statusColor = Colors.indigo;
                      }
                      if (status == 'Completion & Warranty') {
                        statusColor = Colors.green;
                      }
                      if (status == 'Cancelled') statusColor = Colors.red;

                      String rawDate = req['created_at'] ?? 'TBA';
                      String formattedDate = rawDate.length >= 10
                          ? rawDate.substring(0, 10)
                          : rawDate;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFF0F0F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                req['reference_no'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB71C1C),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                req['customer_name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.build_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      req['request_type'] ?? 'General',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF666666),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () => _showRespondDialog(req),
                                child: const Text(
                                  'Update Tracker',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB71C1C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
