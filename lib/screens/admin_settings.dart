import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  // STATES PARA SA SWITCHES
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _isActionLoading = false;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _mobileNumber = '';
  String _role = '';

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? false;
    });

    try {
      final response = await ApiClient.get('/me');
      final user = Map<String, dynamic>.from(response['user'] ?? {});
      if (!mounted) return;
      setState(() {
        _firstName = user['first_name']?.toString() ?? '';
        _lastName = user['last_name']?.toString() ?? '';
        _email = user['email']?.toString() ?? '';
        _mobileNumber = user['contact_number']?.toString() ?? '';
        _role = user['role']?.toString() ?? '';
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load account profile: $error')),
        );
      }
    }
  }

  // 1. CHANGE PASSWORD FUNCTION
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmationController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: isObscure,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: isObscure,
                    decoration: InputDecoration(
                      labelText: 'New Password (at least 8 characters)',
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmationController,
                    obscureText: isObscure,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
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
                    if (passwordController.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password must be at least 8 characters.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (passwordController.text !=
                        confirmationController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'New password confirmation does not match.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    try {
                      await ApiClient.put('/me/password', {
                        'current_password': currentPasswordController.text,
                        'new_password': passwordController.text,
                        'new_password_confirmation':
                            confirmationController.text,
                      });
                      if (mounted) {
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Password updated successfully!'),
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
    final firstNameController = TextEditingController(text: _firstName);
    final lastNameController = TextEditingController(text: _lastName);
    final mobileController = TextEditingController(text: _mobileNumber);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

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
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Email is managed by your account administrator.',
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
                  final response = await ApiClient.put('/me/profile', {
                    'first_name': firstNameController.text.trim(),
                    'last_name': lastNameController.text.trim(),
                    'mobile_number': mobileController.text.trim(),
                  });
                  final user = Map<String, dynamic>.from(
                    response['user'] ?? {},
                  );
                  if (mounted) {
                    setState(() {
                      _firstName = user['first_name']?.toString() ?? '';
                      _lastName = user['last_name']?.toString() ?? '';
                      _mobileNumber = user['contact_number']?.toString() ?? '';
                    });
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Unable to update profile: $e')),
                    );
                  }
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Backups are managed from Supabase Dashboard → Database → Backups.',
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    setState(() => _isActionLoading = true);
    try {
      await ApiClient.post('/logout', {});
      await ApiClient.clearSession();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to sign out: $error')));
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Manage the signed-in account and its preferences.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (_isActionLoading)
                  const CircularProgressIndicator(color: AppColors.brand),
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
                  '$_role • $_email',
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
                  'Manage backups in the Supabase dashboard.',
                  onTap: _runDatabaseBackup, // CONNECTED NA!
                ),
                _buildSettingsTile(
                  Icons.color_lens_outlined,
                  'Theme Customization',
                  'Switch between Light and Dark mode.',
                  onTap: _showThemeSettings, // CONNECTED NA!
                ),
                _buildSettingsTile(
                  Icons.logout,
                  'Sign out',
                  'Revoke this session and return to sign in.',
                  onTap: _signOut,
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
    return ListTile(
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
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Switch(
        value: currentValue,
        onChanged: onChanged, // NAGBABAGO NA ANG STATE
        activeThumbColor: AppColors.brand,
      ),
    );
  }
}
