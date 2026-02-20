import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incident_report.dart';
import '../services/api_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final IncidentReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late IncidentReport _currentReport;

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('MMM dd, yyyy - HH:mm:ss').format(date);
    } catch (e) {
      return timestamp;
    }
  }

  Future<void> _runAiDemo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String aiResult;
      double aiConfidence;
      final description = _currentReport.description.toLowerCase();

      // Simulate AI classification
      if (description.contains('เงิน') ||
          description.contains('จ่าย') ||
          description.contains('ซื้อ') ||
          description.contains('money')) {
        aiResult = 'Money';
        aiConfidence = 0.90;
      } else if (description.contains('เสียงดัง') ||
          description.contains('แห่') ||
          description.contains('รบกวน') ||
          description.contains('crowd') ||
          description.contains('noise')) {
        aiResult = 'Crowd';
        aiConfidence = 0.75;
      } else {
        aiResult = 'Poster';
        aiConfidence = 0.60;
      }

      final success = await _apiService.updateAiResult(
        _currentReport.reportId!,
        aiResult,
        aiConfidence,
      );

      if (success) {
        setState(() {
          _currentReport = IncidentReport(
            reportId: _currentReport.reportId,
            stationId: _currentReport.stationId,
            typeId: _currentReport.typeId,
            reporterName: _currentReport.reporterName,
            description: _currentReport.description,
            evidencePhoto: _currentReport.evidencePhoto,
            timestamp: _currentReport.timestamp,
            aiResult: aiResult,
            aiConfidence: aiConfidence,
            stationName: _currentReport.stationName,
            zone: _currentReport.zone,
            province: _currentReport.province,
            typeName: _currentReport.typeName,
            severity: _currentReport.severity,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI classification updated successfully'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating AI: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(
          context,
          true,
        ); // Return true to trigger refresh on previous screen
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'Incident Information',
                icon: Icons.info_outline,
                children: [
                  _buildDetailRow(
                    'Report ID',
                    _currentReport.reportId?.toString() ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Timestamp',
                    _formatDate(_currentReport.timestamp),
                  ),
                  _buildDetailRow('Reporter', _currentReport.reporterName),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Location',
                icon: Icons.location_on_outlined,
                children: [
                  _buildDetailRow(
                    'Station',
                    _currentReport.stationName ?? 'Unknown',
                  ),
                  _buildDetailRow('Zone', _currentReport.zone ?? 'Unknown'),
                  _buildDetailRow(
                    'Province',
                    _currentReport.province ?? 'Unknown',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Violation Details',
                icon: Icons.warning_amber_outlined,
                children: [
                  _buildDetailRow('Type', _currentReport.typeName ?? 'Unknown'),
                  _buildDetailRow(
                    'Severity',
                    _currentReport.severity ?? 'Unknown',
                    valueColor: _currentReport.severity == 'High'
                        ? Colors.red
                        : (_currentReport.severity == 'Medium'
                              ? Colors.orange
                              : Colors.green),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentReport.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'AI Analysis',
                icon: Icons.auto_awesome,
                children: [
                  if (_currentReport.aiResult != null) ...[
                    _buildDetailRow('Classification', _currentReport.aiResult!),
                    _buildDetailRow(
                      'Confidence',
                      '${(_currentReport.aiConfidence! * 100).toStringAsFixed(1)}%',
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No AI analysis performed yet.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.psychology),
                      label: Text(_isLoading ? 'Processing...' : 'Run AI Demo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _runAiDemo,
                    ),
                  ),
                ],
              ),
              if (_currentReport.evidencePhoto != null &&
                  _currentReport.evidencePhoto!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Evidence',
                  icon: Icons.image_outlined,
                  children: [
                    Text('Path: ${_currentReport.evidencePhoto}'),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Text(
                          'Image preview not implemented in demo',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: valueColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
