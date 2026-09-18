import 'package:flutter/material.dart';
import 'package:katala/theme/app_theme.dart';

class WebHomePage extends StatelessWidget {
  const WebHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Katala Web Portal'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: AppColors.inkMuted),
            onPressed: () {
              // Babalik sa Web Login Page kapag nag-logout
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 120,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.brandTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.construction,
                  size: 56,
                  color: AppColors.brand,
                ),
              ),
            ),
            SizedBox(height: 28),
            Text(
              'Web User Dashboard',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'lib/web/web_home_page.dart - dyan kayo mag start mag code for web - sean',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.inkMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
