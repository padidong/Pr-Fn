import 'package:flutter/material.dart';
import '../models/violation_type.dart';
import '../services/api_service.dart';

class ViolationTypesScreen extends StatefulWidget {
  const ViolationTypesScreen({super.key});

  @override
  State<ViolationTypesScreen> createState() => _ViolationTypesScreenState();
}

class _ViolationTypesScreenState extends State<ViolationTypesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ViolationType>> _typesFuture;

  @override
  void initState() {
    super.initState();
    _typesFuture = _apiService.getViolationTypes();
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Violation Types')),
      body: FutureBuilder<List<ViolationType>>(
        future: _typesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No violation types found'));
          }

          final types = snapshot.data!;
          return ListView.builder(
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getSeverityColor(
                      type.severity,
                    ).withValues(alpha: 0.2),
                    child: Icon(
                      Icons.warning,
                      color: _getSeverityColor(type.severity),
                    ),
                  ),
                  title: Text(
                    type.typeName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(type.severity),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      type.severity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
