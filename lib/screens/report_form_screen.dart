import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incident_report.dart';
import '../models/station.dart';
import '../models/violation_type.dart';
import '../services/api_service.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _reporterNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _evidencePhotoController =
      TextEditingController();
  final TextEditingController _timestampController = TextEditingController();

  List<Station> _stations = [];
  List<ViolationType> _violationTypes = [];

  int? _selectedStationId;
  int? _selectedTypeId;
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _timestampController.text = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final stations = await _apiService.getStations();
      final types = await _apiService.getViolationTypes();

      setState(() {
        _stations = stations;
        _violationTypes = types;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading form data: $e')));
      }
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStationId == null || _selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a station and violation type'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final report = IncidentReport(
        stationId: _selectedStationId!,
        typeId: _selectedTypeId!,
        reporterName: _reporterNameController.text.trim(),
        description: _descriptionController.text.trim(),
        evidencePhoto: _evidencePhotoController.text.trim().isEmpty
            ? null
            : _evidencePhotoController.text.trim(),
        timestamp: _timestampController.text.trim(),
      );

      final success = await _apiService.createReport(report);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reporterNameController.dispose();
    _descriptionController.dispose();
    _evidencePhotoController.dispose();
    _timestampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Report')),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Polling Station',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      value: _selectedStationId,
                      items: _stations.map((station) {
                        return DropdownMenuItem<int>(
                          value: station.stationId,
                          child: Text(
                            '${station.stationName} (${station.zone})',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedStationId = value),
                      validator: (value) =>
                          value == null ? 'Please select a station' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Violation Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber),
                      ),
                      value: _selectedTypeId,
                      items: _violationTypes.map((type) {
                        return DropdownMenuItem<int>(
                          value: type.typeId,
                          child: Text(type.typeName),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedTypeId = value),
                      validator: (value) => value == null
                          ? 'Please select a violation type'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _reporterNameController,
                      decoration: const InputDecoration(
                        labelText: 'Reporter Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter reporter name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter description'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _evidencePhotoController,
                      decoration: const InputDecoration(
                        labelText: 'Evidence Photo Path (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                        hintText: 'e.g. /path/to/image.jpg',
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _timestampController,
                      decoration: const InputDecoration(
                        labelText: 'Timestamp (YYYY-MM-DD HH:MM:SS)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter timestamp';
                        }

                        // Basic regex for YYYY-MM-DD HH:MM:SS
                        final regex = RegExp(
                          r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$',
                        );
                        if (!regex.hasMatch(value)) {
                          return 'Format must be YYYY-MM-DD HH:MM:SS';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Submit Report',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
