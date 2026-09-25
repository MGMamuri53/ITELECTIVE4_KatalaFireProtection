import 'package:flutter/material.dart';
import 'package:katala/theme/app_theme.dart';
import '../services/api_client.dart';

class WebHomePage extends StatelessWidget {
  const WebHomePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await ApiClient.post('/logout', {});
    } catch (_) {}
    await ApiClient.clearSession();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Katala Web Portal',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout, color: AppColors.inkMuted),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, bodyConstraints) {
            final isCompact =
                bodyConstraints.maxWidth < 480 ||
                bodyConstraints.maxHeight < 480;
            final horizontalPadding = isCompact ? 16.0 : 32.0;
            final verticalPadding = isCompact ? 16.0 : 32.0;
            final iconSize = isCompact ? 72.0 : 120.0;
            final minimumHeight = bodyConstraints.maxHeight
                .clamp(0.0, double.infinity)
                .toDouble();

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minimumHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: const BoxDecoration(
                                color: AppColors.brandTint,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.construction,
                                size: iconSize * 0.47,
                                color: AppColors.brand,
                              ),
                            ),
                            SizedBox(height: isCompact ? 16 : 28),
                            Text(
                              'Web User Dashboard',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isCompact ? 24 : 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: AppColors.ink,
                              ),
                            ),
                            SizedBox(height: isCompact ? 8 : 12),
                            const Text(
                              'lib/web/web_home_page.dart - dyan kayo mag start mag code for web - sean',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.inkMuted,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
