import 'package:flutter/material.dart';
import '../models/station.dart';
import '../services/api_service.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Station>> _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = _apiService.getStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polling Stations'),
      ),
      body: FutureBuilder<List<Station>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No stations found'));
          }

          final stations = snapshot.data!;
          return ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.how_to_vote),
                  ),
                  title: Text(station.stationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${station.zone}, ${station.province}'),
                  trailing: Text('ID: ${station.stationId}', style: const TextStyle(color: Colors.grey)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
