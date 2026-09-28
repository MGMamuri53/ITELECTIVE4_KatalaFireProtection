import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminAppointments extends StatefulWidget {
  const AdminAppointments({super.key});

  @override
  State<AdminAppointments> createState() => _AdminAppointmentsState();
}

class _AdminAppointmentsState extends State<AdminAppointments> {
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _projects = [];
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
      final projectsResponse = await ApiClient.get('/admin/projects');
      if (!mounted) return;
      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
        _projects = List<Map<String, dynamic>>.from(projectsResponse);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // BAGONG DIALOG PARA MAG-ADD NG APPOINTMENT NA NAKA-LINK SA PROJECT
  void _showAddAppointmentDialog() {
    final dateController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    String selectedType = 'Site Consultation';
    int? selectedProjectId = _projects.isEmpty
        ? null
        : int.tryParse(_projects.first['id'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
                DropdownButtonFormField<int>(
                  initialValue: selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    border: OutlineInputBorder(),
                  ),
                  items: _projects.map((project) {
                    final id = int.tryParse(project['id'].toString());
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(
                        '${project['project_number'] ?? project['id']} — ${project['project_name'] ?? 'Project'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => selectedProjectId = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
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
                    labelText: 'Date & Time (YYYY-MM-DDTHH:MM)',
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
                if (selectedProjectId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Create or select a project first.'),
                    ),
                  );
                  return;
                }

                final scheduledDate = DateTime.tryParse(
                  dateController.text.trim(),
                );
                if (scheduledDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a valid date and time, for example 2026-08-30T10:00.',
                      ),
                    ),
                  );
                  return;
                }
                final project = _projects.firstWhere(
                  (item) =>
                      item['id'].toString() == selectedProjectId.toString(),
                );
                try {
                  await ApiClient.post('/admin/appointments', {
                    'customer_id': int.parse(project['customer_id'].toString()),
                    'project_id': selectedProjectId,
                    'service_id': project['service_id'],
                    'type': selectedType,
                    'scheduled_date': scheduledDate.toIso8601String(),
                  });
                  if (mounted) {
                    navigator.pop();
                    _fetchAppointments();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Appointment Scheduled!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
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
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Update Appointment Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: DropdownButtonFormField<String>(
            initialValue:
                [
                  'Pending',
                  'Confirmed',
                  'Completed',
                  'Cancelled',
                ].contains(currentStatus)
                ? currentStatus
                : 'Pending',
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiClient.put('/admin/appointments/$id', {
                    'status': newStatus,
                  });
                  if (mounted) {
                    navigator.pop();
                    _fetchAppointments();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Status Updated!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
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
    final isDesktop = MediaQuery.of(context).size.width > 800;

    List<Map<String, dynamic>> filteredAppointments = _appointments;
    if (_selectedTab != 0) {
      String filterStatus = _tabs[_selectedTab];
      filteredAppointments = _appointments
          .where((appt) => appt['status'] == filterStatus)
          .toList();
    }

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
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 8,
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
                      style: TextStyle(color: AppColors.brand),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.brand),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddAppointmentDialog,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
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
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'TEAM SUGGESTION: Calendar scheduling rules (e.g., auto-assigning engineers, time blocking) are pending client confirmation. Currently, site visits are manually tied to Project References.',
                    style: TextStyle(fontSize: 12, color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTabs(),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildTable(filteredAppointments)),
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

  Widget _buildTable(List<Map<String, dynamic>> appointments) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 900, // In-expand natin width para magkasya ang bagong columns
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
                    flex: 1,
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
                        final status = appt['status'] ?? 'Pending';
                        Color statusColor = Colors.orange;
                        if (status == 'Confirmed') statusColor = Colors.blue;
                        if (status == 'Completed') statusColor = Colors.green;
                        if (status == 'Cancelled') statusColor = Colors.red;

                        String rawDate = appt['appointment_date'] ?? 'TBA';
                        String formattedDate = rawDate.length >= 10
                            ? rawDate.substring(0, 10)
                            : rawDate;

                        return _buildTableRow(
                          appt['id'].toString(),
                          appt['project_ref'] ?? 'Unlinked',
                          appt['client_name'] ?? 'Unknown',
                          appt['appt_type'] ?? 'Consultation',
                          formattedDate,
                          status,
                          statusColor,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
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
              style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
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
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () => _showUpdateStatusDialog(id, status),
              child: const Text(
                'Update',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.brand,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
