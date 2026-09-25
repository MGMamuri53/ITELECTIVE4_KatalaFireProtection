import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminRequests extends StatefulWidget {
  const AdminRequests({super.key});

  @override
  State<AdminRequests> createState() => _AdminRequestsState();
}

class _AdminRequestsState extends State<AdminRequests> {
  static const double maxContentWidth = 1400;
  static const double cardBreakpoint = 940;
  static const double tableMinWidth = 940;
  static const double twoColumnBreakpoint = 560;
  static const double fourColumnBreakpoint = 1100;

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

  String _normalizeStatus(String rawStatus) {
    if (rawStatus == 'Pending') return 'Inquiry / Requirements';
    if (rawStatus == 'Under Review') return 'Design & Engineering';
    if (rawStatus == 'Quoted') return 'Quotation & Approvals';
    return rawStatus;
  }

  void _showRespondDialog(Map<String, dynamic> request) {
    String rawStatus = request['status'] ?? 'Inquiry / Requirements';

    // MAPPING PARA SA MGA LUMANG DATA NA 'PENDING' O 'UNDER REVIEW'
    rawStatus = _normalizeStatus(rawStatus);

    String newStatus = _projectStatuses.contains(rawStatus)
        ? rawStatus
        : 'Inquiry / Requirements';

    final responseController = TextEditingController(
      text: request['admin_response'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final clientDetails = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Project ${request['reference_no']}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.brand,
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
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(12),
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
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _projectStatuses
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
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
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 16,
              runSpacing: 12,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
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
                    backgroundColor: AppColors.brand,
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSplit = constraints.maxWidth >= 680;
                  return SingleChildScrollView(
                    child: isSplit
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
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    const labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.grey,
    );
    const valueStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 320) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 2),
                Text(value, style: valueStyle),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 100, child: Text(label, style: labelStyle)),
              Expanded(child: Text(value, style: valueStyle)),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        List<Map<String, dynamic>> filteredRequests = _requests;
        if (_selectedTab != 0) {
          String filterStatus = _tabs[_selectedTab];
          filteredRequests = _requests.where((req) {
            String status = req['status'] ?? 'Inquiry / Requirements';
            // MAP LEGACY STATUSES FOR FILTERING
            return _normalizeStatus(status) == filterStatus;
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
                  r['status'] == 'Quoted' ||
                  r['status'] == 'Quotation & Approvals',
            )
            .length;
        int installationCount = _requests
            .where((r) => r['status'] == 'Installation Progress')
            .length;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Container(
                margin: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, content) {
                      final gap = content.maxWidth >= twoColumnBreakpoint
                          ? 16.0
                          : 12.0;
                      final sectionGap = isDesktop ? 32.0 : 20.0;
                      final useCards = content.maxWidth < cardBreakpoint;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 620,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'Service Project Tracker',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Track service inquiries from requirements, design, quotation, to installation and warranty.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _fetchRequests,
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
                                  side: const BorderSide(
                                    color: AppColors.brand,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sectionGap),

                          _buildStatsGrid(
                            content.maxWidth,
                            gap,
                            inquiryCount,
                            quoteCount,
                            installationCount,
                          ),
                          SizedBox(height: sectionGap),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildTabs(),
                          ),
                          const SizedBox(height: 16),

                          if (useCards)
                            _buildRequestCards(filteredRequests)
                          else
                            _buildRequestTable(content, filteredRequests),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(
    double availableWidth,
    double gap,
    int inquiryCount,
    int quoteCount,
    int installationCount,
  ) {
    final columns = availableWidth >= fourColumnBreakpoint
        ? 4
        : availableWidth >= twoColumnBreakpoint
        ? 2
        : 1;

    final cards = <Widget>[
      _buildStatCard(
        'TOTAL PROJECTS',
        _requests.length.toString(),
        Colors.black,
      ),
      _buildStatCard('INQUIRIES', inquiryCount.toString(), Colors.orange),
      _buildStatCard('QUOTATIONS', quoteCount.toString(), Colors.deepPurple),
      _buildStatCard(
        'INSTALLATIONS',
        installationCount.toString(),
        Colors.indigo,
      ),
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

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              count,
              maxLines: 1,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
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
                  color: isSelected ? AppColors.brand : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              _tabs[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.brand : Colors.grey,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRequestTable(
    BoxConstraints constraints,
    List<Map<String, dynamic>> requests,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: constraints.maxWidth < tableMinWidth
            ? tableMinWidth
            : constraints.maxWidth,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 2),
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
                    flex: 2,
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
                      child: CircularProgressIndicator(color: AppColors.brand),
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
                      final status = _normalizeStatus(
                        req['status'] ?? 'Inquiry / Requirements',
                      );
                      final statusColor = _statusColorFor(status);
                      final rawDate = req['created_at'] ?? 'TBA';
                      final formattedDate = rawDate.length >= 10
                          ? rawDate.substring(0, 10)
                          : rawDate;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.surfaceMuted),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                req['reference_no'] ?? 'N/A',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brand,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                req['customer_name'] ?? 'Unknown',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
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
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.inkMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                formattedDate,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.inkMuted,
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
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () => _showRespondDialog(req),
                                child: Text(
                                  'Update Tracker',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.brand,
                                    fontWeight: FontWeight.bold,
                                  ),
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

  Widget _buildRequestCards(List<Map<String, dynamic>> requests) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(child: CircularProgressIndicator(color: AppColors.brand)),
      );
    }
    if (requests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            'No service projects found in this stage.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final req = requests[index];
        final status = _normalizeStatus(
          req['status'] ?? 'Inquiry / Requirements',
        );
        final statusColor = _statusColorFor(status);
        final rawDate = req['created_at'] ?? 'TBA';
        final formattedDate = rawDate.length >= 10
            ? rawDate.substring(0, 10)
            : rawDate;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          req['customer_name'] ?? 'Unknown',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          req['reference_no'] ?? 'N/A',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showRespondDialog(req),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Text(
                        'Update Tracker',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.brand,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildMetaChip(
                    Icons.build_outlined,
                    req['request_type']?.toString() ?? 'General',
                  ),
                  _buildMetaChip(Icons.event_outlined, formattedDate),
                  _buildStatusChip(status, statusColor),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaChip(IconData icon, String value) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.inkMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColorFor(String status) {
    if (status == 'Inquiry / Requirements') return Colors.orange;
    if (status == 'Design & Engineering') return Colors.blue;
    if (status == 'Quotation & Approvals') return Colors.deepPurple;
    if (status == 'Payment Arrangement') return Colors.teal;
    if (status == 'Installation Progress') return Colors.indigo;
    if (status == 'Completion & Warranty') return Colors.green;
    if (status == 'Cancelled') return Colors.red;
    return Colors.grey;
  }
}
