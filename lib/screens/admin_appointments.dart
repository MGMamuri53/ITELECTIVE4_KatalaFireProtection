import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminAppointments extends StatefulWidget {
  const AdminAppointments({super.key});

  @override
  State<AdminAppointments> createState() => _AdminAppointmentsState();
}

class _AdminAppointmentsState extends State<AdminAppointments> {
  static const double maxContentWidth = 1280;
  static const double cardBreakpoint = 900;
  static const double tableMinWidth = 900;

  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  final List<String> _tabs = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/admin/appointments');
      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
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

  // BAGONG DIALOG PARA MAG-ADD NG APPOINTMENT NA NAKA-LINK SA PROJECT
  void _showAddAppointmentDialog() {
    final clientController = TextEditingController();
    final projectRefController = TextEditingController();
    final dateController = TextEditingController();
    String selectedType = 'Site Consultation';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Schedule Site Visit',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: projectRefController,
                  decoration: const InputDecoration(
                    labelText: 'Project Reference (e.g. REQ-1234)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: clientController,
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Visit Type',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                            'Site Consultation',
                            'Installation Visit',
                            'Inspection',
                            'Maintenance',
                          ]
                          .map(
                            (val) =>
                                DropdownMenuItem(value: val, child: Text(val)),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) selectedType = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date & Time (e.g. 2026-08-30 10:00 AM)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (projectRefController.text.isEmpty ||
                    clientController.text.isEmpty) {
                  return;
                }

                try {
                  throw Exception(
                    'Appointments are not available in the Laravel schema yet.',
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchAppointments();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment Scheduled!'),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStatusDialog(String id, String currentStatus) {
    String newStatus = currentStatus;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: const Text(
            'Update Appointment Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: DropdownButtonFormField<String>(
              initialValue:
                  [
                    'Pending',
                    'Confirmed',
                    'Completed',
                    'Cancelled',
                  ].contains(currentStatus)
                  ? currentStatus
                  : 'Pending',
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ['Pending', 'Confirmed', 'Completed', 'Cancelled'].map((
                String val,
              ) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: (value) {
                if (value != null) newStatus = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  throw Exception(
                    'Appointments are not available in the Laravel schema yet.',
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchAppointments();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status Updated!'),
                        backgroundColor: Colors.blue,
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        List<Map<String, dynamic>> filteredAppointments = _appointments;
        if (_selectedTab != 0) {
          String filterStatus = _tabs[_selectedTab];
          filteredAppointments = _appointments
              .where((appt) => appt['status'] == filterStatus)
              .toList();
        }

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 560,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Project Site Visits',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Manage site consultations tied to specific service inquiries.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _fetchAppointments,
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: AppColors.brand,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Refresh',
                                        style: TextStyle(
                                          color: AppColors.brand,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppColors.brand,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _showAddAppointmentDialog,
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Schedule Visit',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.brand,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // TEAM SUGGESTION BANNER
                            SizedBox(height: isDesktop ? 24 : 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warningTint,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'TEAM SUGGESTION: Calendar scheduling rules (e.g., auto-assigning engineers, time blocking) are pending client confirmation. Currently, site visits are manually tied to Project References.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isDesktop ? 24 : 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildTabs(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, content) =>
                            content.maxWidth < cardBreakpoint
                            ? _buildCardList(filteredAppointments)
                            : _buildTable(content, filteredAppointments),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  Widget _buildTable(
    BoxConstraints constraints,
    List<Map<String, dynamic>> appointments,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: constraints.maxWidth < tableMinWidth
            ? tableMinWidth
            : constraints.maxWidth,
        height: constraints.maxHeight,
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
                      'PROJECT REF',
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
                      'TYPE',
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
                      'DATE',
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
                      'STATUS',
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
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    )
                  : appointments.isEmpty
                  ? const Center(
                      child: Text(
                        'No appointments booked yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appt = appointments[index];
                        return _buildTableRow(
                          appt['id'].toString(),
                          appt['project_ref'] ?? 'Unlinked',
                          appt['client_name'] ?? 'Unknown',
                          appt['appt_type'] ?? 'Consultation',
                          _formatDate(appt['appointment_date'] ?? 'TBA'),
                          appt['status'] ?? 'Pending',
                          _statusColorFor(appt['status'] ?? 'Pending'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(List<Map<String, dynamic>> appointments) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }
    if (appointments.isEmpty) {
      return const Center(
        child: Text(
          'No appointments booked yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: appointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final appt = appointments[index];
        final status = appt['status'] ?? 'Pending';
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
                          appt['client_name'] ?? 'Unknown',
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
                          appt['project_ref'] ?? 'Unlinked',
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
                    onTap: () =>
                        _showUpdateStatusDialog(appt['id'].toString(), status),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Text(
                        'Update',
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
                    Icons.design_services_outlined,
                    appt['appt_type']?.toString() ?? 'Consultation',
                  ),
                  _buildMetaChip(
                    Icons.event_outlined,
                    _formatDate(appt['appointment_date'] ?? 'TBA'),
                  ),
                  _buildStatusChip(status, _statusColorFor(status)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableRow(
    String id,
    String projectRef,
    String name,
    String type,
    String date,
    String status,
    Color dotColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceMuted)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              projectRef,
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
            flex: 2,
            child: Text(
              name,
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
            child: Text(
              type,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
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
            child: InkWell(
              onTap: () => _showUpdateStatusDialog(id, status),
              child: Text(
                'Update',
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
  }

  String _formatDate(String rawDate) {
    return rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
  }

  Color _statusColorFor(String status) {
    if (status == 'Confirmed') return Colors.blue;
    if (status == 'Completed') return Colors.green;
    if (status == 'Cancelled') return Colors.red;
    return Colors.orange;
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
}
