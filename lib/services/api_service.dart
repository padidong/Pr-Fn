import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';
import '../models/station.dart';
import '../models/violation_type.dart';
import '../models/incident_report.dart';

class ApiService {
  Future<List<Station>> getStations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/stations'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stations: $e');
    }
  }

  Future<List<ViolationType>> getViolationTypes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/violation_types'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ViolationType.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load violation types: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching violation types: $e');
    }
  }

  Future<List<IncidentReport>> getReports() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/reports'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => IncidentReport.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }

  Future<bool> createReport(IncidentReport report) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/create_report'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(report.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to create report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating report: $e');
    }
  }

  Future<bool> updateAiResult(
    int reportId,
    String aiResult,
    double aiConfidence,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/update_ai'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'report_id': reportId,
          'ai_result': aiResult,
          'ai_confidence': aiConfidence,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to update AI result: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating AI result: $e');
    }
  }
}
