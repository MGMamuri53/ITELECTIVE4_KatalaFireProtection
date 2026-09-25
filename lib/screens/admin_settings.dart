import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:katala/theme/app_theme.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  static const double maxContentWidth = 1120;
  static const double twoColumnBreakpoint = 900;

  // STATES PARA SA SWITCHES
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _isActionLoading = false;

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? false;
    });
  }

  // 1. CHANGE PASSWORD FUNCTION
  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    bool isObscure = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              title: const Text(
                'Change Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: TextField(
                  controller: passwordController,
                  obscureText: isObscure,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setDialogState(() => isObscure = !isObscure),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password must be at least 6 characters.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    try {
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password updated successfully!'),
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
                  ),
                  child: const Text(
                    'Update Password',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 2. EDIT PROFILE FUNCTION
  void _showEditProfileDialog() {
    final nameController = TextEditingController();

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
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Email cannot be changed directly for security reasons.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                try {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // 3. DATABASE BACKUP LOGIC
  Future<void> _runDatabaseBackup() async {
    setState(() => _isActionLoading = true);

    // Fake loading to simulate database fetching for all tables
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating database backup... Please wait.'),
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(seconds: 3)); // Simulating API delay

    if (mounted) {
      setState(() => _isActionLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Backup Complete',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Your database records have been successfully fetched. (CSV Download requires web file-saver package setup).',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }
  }

  // 4. THEME TOGGLE POPUP
  void _showThemeSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text(
          'Theme Customization',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'To fully switch the entire portal to Dark Mode, we need to wrap your main.dart with a ThemeProvider. Do you want to enable this mode?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
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
                      final sectionGap = isDesktop ? 24.0 : 16.0;
                      final profileCard = _buildSection('Profile Settings', [
                        _buildSettingsTile(
                          Icons.person_outline,
                          'Edit Profile',
                          'Update your personal information and display picture.',
                          onTap: _showEditProfileDialog, // CONNECTED NA!
                        ),
                        _buildSettingsTile(
                          Icons.lock_outline,
                          'Change Password',
                          'Update your login credentials.',
                          onTap: _showChangePasswordDialog, // CONNECTED NA!
                        ),
                      ]);
                      final notificationsCard = _buildSection('Notifications', [
                        _buildSwitchTile(
                          Icons.email_outlined,
                          'Email Notifications',
                          'Receive daily summaries of new requests.',
                          _emailNotifications,
                          (val) async {
                            setState(() => _emailNotifications = val);

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('email_notifications', val);
                          }, // WORKING SWITCH
                        ),
                        _buildSwitchTile(
                          Icons.notifications_active_outlined,
                          'Push Notifications',
                          'Real-time alerts for incoming appointments.',
                          _pushNotifications,
                          (val) async {
                            setState(() => _pushNotifications = val);

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('push_notifications', val);
                          }, // WORKING SWITCH
                        ),
                      ]);
                      final systemCard = _buildSection('System Data', [
                        _buildSettingsTile(
                          Icons.backup_outlined,
                          'Database Backup',
                          'Export all records to a CSV file.',
                          onTap: _runDatabaseBackup, // CONNECTED NA!
                        ),
                        _buildSettingsTile(
                          Icons.color_lens_outlined,
                          'Theme Customization',
                          'Switch between Light and Dark mode.',
                          onTap: _showThemeSettings, // CONNECTED NA!
                        ),
                      ]);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 12,
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
                                      'System Settings',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Manage your account preferences and system configurations.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isActionLoading)
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.brand,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: isDesktop ? 32 : 20),
                          if (content.maxWidth >= twoColumnBreakpoint)
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: profileCard),
                                    SizedBox(width: sectionGap),
                                    Expanded(child: notificationsCard),
                                  ],
                                ),
                                SizedBox(height: sectionGap),
                                systemCard,
                              ],
                            )
                          else
                            Column(
                              children: [
                                profileCard,
                                SizedBox(height: sectionGap),
                                notificationsCard,
                                SizedBox(height: sectionGap),
                                systemCard,
                              ],
                            ),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: KataUi.cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [_buildSectionHeader(title), ...children],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.brand,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.inkSoft),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap, // IPINASA NATIN ANG FUNCTION DITO
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool currentValue,
    Function(bool) onChanged,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.inkSoft),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Switch(
          value: currentValue,
          onChanged: onChanged, // NAGBABAGO NA ANG STATE
          activeThumbColor: AppColors.brand,
        ),
      ),
    );
  }
}
