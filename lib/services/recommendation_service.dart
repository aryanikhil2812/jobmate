import '../models/job_model.dart';

class RecommendationService {
  List<Job> getRecommendedJobs({
    required List<Job> jobs,
    required String skills,
  }) {
    if (skills.trim().isEmpty || jobs.isEmpty) {
      return [];
    }

    final userSkills = skills
        .toLowerCase()
        .split(RegExp(r'[,|\n]'))
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    final scoredJobs = <Map<String, dynamic>>[];

    for (final job in jobs) {
      final jobText = '''
        ${job.title}
        ${job.company}
        ${job.description}
        ${job.type}
      '''.toLowerCase();

      int score = 0;

      for (final skill in userSkills) {
        if (skill.length < 2) continue;

        if (jobText.contains(skill)) {
          score += 3;
        }
      }

      // Common Flutter/mobile-development keywords
      final mobileKeywords = [
        'flutter',
        'dart',
        'mobile',
        'android',
        'ios',
        'app developer',
        'mobile developer',
        'react native',
        'firebase',
      ];

      for (final keyword in mobileKeywords) {
        if (jobText.contains(keyword)) {
          score += 1;
        }
      }

      if (score > 0) {
        scoredJobs.add({
          'job': job,
          'score': score,
        });
      }
    }

    scoredJobs.sort(
          (a, b) => (b['score'] as int)
          .compareTo(a['score'] as int),
    );

    return scoredJobs
        .take(5)
        .map((item) => item['job'] as Job)
        .toList();
  }
}