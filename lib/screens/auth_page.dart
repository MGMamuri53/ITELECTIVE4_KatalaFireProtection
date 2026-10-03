import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'main_layout.dart';
import 'admin_layout.dart'; // IN-IMPORT NATIN ANG ADMIN LAYOUT DITO
import 'package:katala/theme/app_theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  bool _isLoading = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        final response = await ApiClient.post('/login', {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        });

        final token = response['token']?.toString() ?? '';
        final user = Map<String, dynamic>.from(response['user'] ?? {});
        final role = user['role']?.toString() ?? 'Customer';
        await ApiClient.saveSession(token, role, user: user);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => role.toLowerCase().contains('admin')
                  ? const AdminLayout()
                  : const MainLayout(),
            ),
          );
        }
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Passwords do not match!'),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }

        await ApiClient.post('/register', {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'contact_number': _phoneController.text.trim(),
          'password': _passwordController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! You can now log in.'),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() {
            _isLogin = true;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
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
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [_buildMobileHeader(), _buildAuthForm()]),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=800&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield, color: AppColors.brand, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Katala FireSafe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Engineering Life Safety.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Professional Portal',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Secure access to technical documentation, compliance reports, and quotation management designed for facility engineers.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm() {
    final isNarrow = MediaQuery.of(context).size.width < 480;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLogin ? 'Welcome Back' : 'Create Your Professional Account',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLogin
                ? 'Sign in to Katala FireSafe to continue.'
                : 'Access Katala FireSafe to manage your quotations and service requests.',
            style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 16),

          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 32),

          if (!_isLogin) ...[
            if (isNarrow)
              Column(
                children: [
                  _buildTextField('First Name', 'Jane', _firstNameController),
                  const SizedBox(height: 16),
                  _buildTextField('Last Name', 'Doe', _lastNameController),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'First Name',
                      'Jane',
                      _firstNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Last Name',
                      'Doe',
                      _lastNameController,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
          ],

          _buildTextField(
            'Work Email',
            'jane.doe@company.com',
            _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          if (!_isLogin) ...[
            _buildTextField(
              'Contact Number',
              '+1 (555) 000-0000',
              _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
          ],

          if (!_isLogin) ...[
            if (isNarrow)
              Column(
                children: [
                  _buildTextField(
                    'Password',
                    '••••••••',
                    _passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Confirm Password',
                    '••••••••',
                    _confirmPasswordController,
                    isPassword: true,
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Password',
                      '••••••••',
                      _passwordController,
                      isPassword: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Confirm Password',
                      '••••••••',
                      _confirmPasswordController,
                      isPassword: true,
                    ),
                  ),
                ],
              ),
          ] else ...[
            _buildTextField(
              'Password',
              '••••••••',
              _passwordController,
              isPassword: true,
            ),
          ],

          const SizedBox(height: 24),

          if (!_isLogin)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(KataUi.radiusCard),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.inkMuted,
                    size: 16,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your data is handled according to our Privacy Policy and ISO security standards.',
                      style: TextStyle(fontSize: 10, color: AppColors.inkMuted),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: _isLogin ? 16 : 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleAuth,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(_isLogin ? 'Sign In' : 'Create Account'),
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: InkWell(
              onTap: () => setState(() {
                _isLogin = !_isLogin;
                _passwordController.clear();
                _confirmPasswordController.clear();
              }),
              child: RichText(
                text: TextSpan(
                  text: _isLogin
                      ? "Don't have an account? "
                      : "Already have an account? ",
                  style: const TextStyle(
                    color: AppColors.inkMuted,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: _isLogin ? 'Sign up' : 'Sign in',
                      style: const TextStyle(
                        color: AppColors.brand,
                        fontWeight: FontWeight.bold,
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

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
