import 'package:flutter/material.dart';

import '../services/application_service.dart';

class ApplicationsScreen extends StatelessWidget {
  ApplicationsScreen({super.key});

  final ApplicationService applicationService =
  ApplicationService();

  final List<String> statuses = [
    'Applied',
    'Shortlisted',
    'Interview',
    'Selected',
    'Rejected',
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case 'Selected':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Interview':
        return Colors.orange;
      case 'Shortlisted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Applications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: applicationService.getApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 55,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Unable to load applications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Applications Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jobs you apply for will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];

              final String applicationId =
                  application['id']?.toString() ?? '';

              final String title =
                  application['title']?.toString() ??
                      'Unknown Job';

              final String company =
                  application['company']?.toString() ??
                      'Unknown Company';

              final String location =
                  application['location']?.toString() ??
                      'Remote';

              final String type =
                  application['type']?.toString() ??
                      'Job';

              final String status =
                  application['status']?.toString() ??
                      'Applied';

              final statusColor =
              getStatusColor(status);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons
                                  .business_center_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  company,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                    Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color:
                            Colors.grey.shade600,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                color:
                                Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 17,
                            color:
                            Colors.grey.shade600,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            type,
                            style: TextStyle(
                              color:
                              Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      const Divider(),

                      const SizedBox(height: 10),

                      const Text(
                        'Application Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Status dropdown
                      DropdownButtonFormField<String>(
                        value: statuses.contains(status)
                            ? status
                            : 'Applied',
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.track_changes,
                            color: statusColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        items: statuses.map((statusItem) {
                          return DropdownMenuItem<String>(
                            value: statusItem,
                            child: Text(statusItem),
                          );
                        }).toList(),
                        onChanged: (newStatus) async {
                          if (newStatus == null) return;

                          try {
                            await applicationService
                                .updateApplicationStatus(
                              applicationId:
                              applicationId,
                              status: newStatus,
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Status updated to $newStatus',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Something went wrong: $e',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
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