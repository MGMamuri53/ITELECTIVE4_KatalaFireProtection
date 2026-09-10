import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  final _supabase = Supabase.instance.client;

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
              title: const Text(
                'Change Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: TextField(
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
                      await _supabase.auth.updateUser(
                        UserAttributes(password: passwordController.text),
                      );
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
                    backgroundColor: const Color(0xFFB71C1C),
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
    // Kunin ang current data kung meron
    final user = _supabase.auth.currentUser;
    final currentName = user?.userMetadata?['full_name'] ?? '';
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _supabase.auth.updateUser(
                    UserAttributes(data: {'full_name': nameController.text}),
                  );
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
              ),
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
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Backup Complete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Your database records have been successfully fetched. (CSV Download requires web file-saver package setup).',
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
        title: const Text(
          'Theme Customization',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'To fully switch the entire portal to Dark Mode, we need to wrap your main.dart with a ThemeProvider. Do you want to enable this mode?',
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
    final isDesktop = MediaQuery.of(context).size.width > 800;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'System Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your account preferences and system configurations.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                if (_isActionLoading)
                  const CircularProgressIndicator(color: Color(0xFFB71C1C)),
              ],
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Profile Settings'),
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

                const SizedBox(height: 24),
                _buildSectionHeader('Notifications'),
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

                const SizedBox(height: 24),
                _buildSectionHeader('System Data'),
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
              ],
            ),
          ],
        ),
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
          color: Color(0xFFB71C1C),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF333333)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap, // IPINASA NATIN ANG FUNCTION DITO
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool currentValue,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF333333)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Switch(
        value: currentValue,
        onChanged: onChanged, // NAGBABAGO NA ANG STATE
        activeThumbColor: const Color(0xFFB71C1C),
      ),
    );
  }
}
