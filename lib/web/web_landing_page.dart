import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class WebLandingPage extends StatefulWidget {
  const WebLandingPage({super.key});

  @override
  State<WebLandingPage> createState() => _WebLandingPageState();
}

class _WebLandingPageState extends State<WebLandingPage> {
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
        await ApiClient.saveSession(
          token,
          user['role']?.toString() ?? 'Customer',
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/web-home');
        }
      } else {
        // WEB SIGN UP LOGIC
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
              content: Text('Web Account created! You can now log in.'),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isDesktop
          ? Row(
              children: [
                Expanded(child: _buildBrandingSide()),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(child: _buildAuthForm()),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // TINANGGAL YUNG SIZEDBOX HEIGHT 300 PARA HINDI MA-CUT ANG BUTTON
                  _buildBrandingSide(),
                  _buildAuthForm(),
                ],
              ),
            ),
    );
  }

  // LEFT SIDE / TOP SIDE: BRANDING AT BUTTON PARA SA MOBILE
  Widget _buildBrandingSide() {
    return Container(
      width: double.infinity, // PARA PUNO ANG SCREEN LAPAD SA MOBILE
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, Color(0xFF2A1416)],
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 60,
      ), // INAYOS ANG PADDING
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brandTint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.brand.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(Icons.shield, color: AppColors.brand, size: 44),
          ),
          const SizedBox(height: 28),
          const Text(
            'Katala Fire Protection\nWeb Portal',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Access your dashboard, manage quotations, and review safety compliance reports from your browser.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

          // BUTTON PARA PUMUNTA SA MOBILE VERSION
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/app'),
            icon: const Icon(Icons.smartphone, color: Colors.white),
            label: const Text(
              'Go to Mobile Version',
              style: TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white70),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // RIGHT SIDE / BOTTOM SIDE: YUNG FORM PARA SA SIGN UP AT LOGIN
  Widget _buildAuthForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 450),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isLogin ? 'Web Sign In' : 'Create Web Account',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLogin
                ? 'Enter your credentials to access the web portal.'
                : 'Register to manage your fire safety systems online.',
            style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 32),

          if (!_isLogin) ...[
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
            'Email Address',
            'jane.doe@company.com',
            _emailController,
          ),
          const SizedBox(height: 16),

          if (!_isLogin) ...[
            _buildTextField(
              'Contact Number',
              '+63 900 000 0000',
              _phoneController,
            ),
            const SizedBox(height: 16),
          ],

          _buildTextField(
            'Password',
            '••••••••',
            _passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 16),

          if (!_isLogin) ...[
            _buildTextField(
              'Confirm Password',
              '••••••••',
              _confirmPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 24),
          ],

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
                  : Text(_isLogin ? 'Sign In' : 'Sign Up'),
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
              child: Text(
                _isLogin
                    ? "Don't have an account? Sign up here."
                    : "Already have an account? Sign in here.",
                style: const TextStyle(
                  color: AppColors.brand,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }
}
