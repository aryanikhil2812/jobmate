import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/job_model.dart';

class JobService {
  Future<List<Job>> fetchJobs() async {
    final response = await http.get(
      Uri.parse(
        'https://himalayas.app/jobs/api?limit=20',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
      jsonDecode(response.body);

      final List<dynamic> jobs = data['jobs'] ?? [];

      return jobs.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        // Create a Firestore-safe ID.
        // API guid can contain "/" which Firestore doesn't allow
        // inside a document ID/path.
        final rawId = item['id']?.toString();

        final safeId = (rawId != null && rawId.isNotEmpty)
            ? rawId.replaceAll('/', '_')
            : 'job_$index';

        return Job(
          id: safeId,
          title: item['title']?.toString() ??
              'Unknown Job',
          company: item['companyName']?.toString() ??
              item['company']?.toString() ??
              'Unknown Company',
          location: item['location']?.toString() ??
              'Remote',
          type: item['employmentType']?.toString() ??
              'Job',
          description: item['description']?.toString() ??
              '',
          applyUrl: item['applicationLink']?.toString() ??
              item['url']?.toString() ??
              '',
        );
      }).toList();
    } else {
      throw Exception(
        'Failed to load jobs: ${response.statusCode}',
      );
    }
  }
}