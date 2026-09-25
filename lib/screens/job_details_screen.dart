import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/job_model.dart';
import '../services/application_service.dart';
import '../services/saved_job_service.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final SavedJobService _savedJobService = SavedJobService();
  final ApplicationService _applicationService =
  ApplicationService();

  bool isSaved = false;
  bool isApplied = false;

  bool isSaving = false;
  bool isApplying = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJobStatus();
  }

  Future<void> loadJobStatus() async {
    try {
      final saved = await _savedJobService.isJobSaved(
        widget.job.id,
      );

      final applied = await _applicationService.isJobApplied(
        widget.job.id,
      );

      if (!mounted) return;

      setState(() {
        isSaved = saved;
        isApplied = applied;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleSave() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      if (isSaved) {
        await _savedJobService.removeSavedJob(
          widget.job.id,
        );

        if (!mounted) return;

        setState(() {
          isSaved = false;
        });

        showMessage('Job removed from saved jobs');
      } else {
        await _savedJobService.saveJob(
          widget.job,
        );

        if (!mounted) return;

        setState(() {
          isSaved = true;
        });

        showMessage('Job saved successfully');
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> applyForJob() async {
    if (isApplying || isApplied) return;

    setState(() {
      isApplying = true;
    });

    try {
      await _applicationService.applyForJob(
        widget.job,
      );

      if (!mounted) return;

      setState(() {
        isApplied = true;
      });

      showMessage(
        'Application added to your tracker',
      );

      await openApplicationWebsite();
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to apply. Please try again.',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isApplying = false;
      });
    }
  }

  Future<void> openApplicationWebsite() async {
    final url = widget.job.applyUrl.trim();

    if (url.isEmpty) {
      if (!mounted) return;

      showMessage(
        'Application website is not available',
      );

      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        !(uri.scheme == 'http' ||
            uri.scheme == 'https')) {
      if (!mounted) return;

      showMessage(
        'Invalid application link',
      );

      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        showMessage(
          'Could not open application website',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Could not open application website',
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Job Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isSaving ? null : toggleSave,
            tooltip: isSaved ? 'Unsave job' : 'Save job',
            icon: isSaving
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : Icon(
              isSaved
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: isSaved
                  ? Colors.blue
                  : Colors.black87,
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          120,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildJobHeader(job),

            const SizedBox(height: 20),

            _buildJobInfo(job),

            const SizedBox(height: 20),

            _buildDescription(job),

            const SizedBox(height: 20),

            _buildApplicationStatus(),

            const SizedBox(height: 20),

            _buildApplicationWebsiteButton(),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildJobHeader(Job job) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1565C0),
            Color(0xFF42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.business_center_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            job.title.isEmpty
                ? 'Job Opportunity'
                : job.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            job.company.isEmpty
                ? 'Company'
                : job.company,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  job.location.isEmpty
                      ? 'Location not specified'
                      : job.location,
                  style: TextStyle(
                    color:
                    Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfo(Job job) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.work_outline,
            title: 'Job Type',
            value: job.type.isEmpty
                ? 'Not specified'
                : job.type,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildInfoCard(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: job.location.isEmpty
                ? 'Not specified'
                : job.location,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 24,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Job job) {
    final description = job.description.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Text(
                'Job Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            description.isEmpty
                ? 'No job description available.'
                : description,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isApplied
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApplied
              ? Colors.green.withValues(alpha: 0.25)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: isApplied
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.blue.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isApplied
                  ? Icons.check_circle_outline
                  : Icons.track_changes,
              color:
              isApplied ? Colors.green : Colors.blue,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  isApplied
                      ? 'Application Tracked'
                      : 'Application Status',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  isApplied
                      ? 'This job is added to your application tracker.'
                      : 'Apply to add this job to your tracker.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationWebsiteButton() {
    final hasUrl =
        widget.job.applyUrl.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed:
        hasUrl ? openApplicationWebsite : null,
        icon: const Icon(
          Icons.open_in_new,
          size: 20,
        ),
        label: const Text(
          'Open Application Website',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            double.infinity,
            52,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                isSaving ? null : toggleSave,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                label: Text(
                  isSaved ? 'Saved' : 'Save',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed:
                isApplied || isApplying
                    ? null
                    : applyForJob,
                icon: isApplying
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Icon(
                  isApplied
                      ? Icons.check_circle_outline
                      : Icons.send_outlined,
                ),
                label: Text(
                  isApplied
                      ? 'Applied'
                      : 'Apply Now',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  Colors.green,
                  disabledForegroundColor:
                  Colors.white,
                  minimumSize: const Size(0, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}