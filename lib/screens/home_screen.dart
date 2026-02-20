import 'package:flutter/material.dart';
import 'stations_screen.dart';
import 'violation_types_screen.dart';
import 'reports_screen.dart';
import 'report_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Incident Reporter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to Election Incident Reporter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildMenuButton(
              context,
              'View Polling Stations',
              Icons.how_to_vote,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StationsScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              'View Violation Types',
              Icons.warning_amber_rounded,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViolationTypesScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              'View All Reports',
              Icons.list_alt,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              'Create New Report',
              Icons.add_circle_outline,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportFormScreen(),
                ),
              ),
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(title, style: const TextStyle(fontSize: 18)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: isPrimary
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: isPrimary
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
