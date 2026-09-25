class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final String description;
  final String applyUrl;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    required this.applyUrl,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      applyUrl: json['applyUrl']?.toString() ?? '',
    );
  }
}