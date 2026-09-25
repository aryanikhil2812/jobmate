import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/job_model.dart';
import '../models/notification_model.dart';
import '../services/job_service.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../services/recommendation_service.dart';
import '../services/saved_job_service.dart';
import 'applications_screen.dart';
import 'job_details_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'saved_jobs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobService _jobService = JobService();
  final SavedJobService _savedJobService = SavedJobService();
  final ProfileService _profileService = ProfileService();
  final RecommendationService _recommendationService =
  RecommendationService();
  final NotificationService _notificationService =
  NotificationService();

  final TextEditingController _searchController =
  TextEditingController();

  List<Job> allJobs = [];
  List<Job> filteredJobs = [];
  List<Job> recommendedJobs = [];

  Set<String> savedJobIds = {};
  Set<String> savingJobIds = {};

  bool isLoading = true;
  String? errorMessage;

  String selectedLocation = 'All';
  String selectedType = 'All';

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    loadJobs();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    applyFilters();
  }

  Future<void> loadJobs() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final jobs = await _jobService.fetchJobs();

      final savedJobs =
      await _savedJobService.getSavedJobs().first;

      final profile =
      await _profileService.getProfile();

      final skills =
          profile?['skills']?.toString() ?? '';

      final recommendations =
      _recommendationService.getRecommendedJobs(
        jobs: jobs,
        skills: skills,
      );

      if (!mounted) return;

      setState(() {
        allJobs = jobs;

        savedJobIds = savedJobs
            .map((job) => job.id)
            .toSet();

        recommendedJobs = recommendations;

        isLoading = false;
      });

      applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
        'Unable to load jobs. Please try again.';
      });
    }
  }

  void applyFilters() {
    final searchText =
    _searchController.text.trim().toLowerCase();

    List<Job> results = List<Job>.from(allJobs);

    if (searchText.isNotEmpty) {
      results = results.where((job) {
        final jobText = '''
${job.title}
${job.company}
${job.location}
${job.type}
${job.description}
'''
            .toLowerCase();

        return jobText.contains(searchText);
      }).toList();
    }

    if (selectedLocation != 'All') {
      results = results.where((job) {
        final location =
        job.location.toLowerCase();

        return location.contains(
          selectedLocation.toLowerCase(),
        );
      }).toList();
    }

    if (selectedType != 'All') {
      results = results.where((job) {
        final type =
        job.type.toLowerCase();

        return type.contains(
          selectedType.toLowerCase(),
        );
      }).toList();
    }

    if (!mounted) return;

    setState(() {
      filteredJobs = results;
    });
  }

  Future<void> toggleSaveJob(Job job) async {
    if (savingJobIds.contains(job.id)) {
      return;
    }

    setState(() {
      savingJobIds.add(job.id);
    });

    try {
      if (savedJobIds.contains(job.id)) {
        await _savedJobService.removeSavedJob(job.id);

        if (!mounted) return;

        setState(() {
          savedJobIds.remove(job.id);
        });

        showMessage('Job removed from saved jobs');
      } else {
        await _savedJobService.saveJob(job);

        if (!mounted) return;

        setState(() {
          savedJobIds.add(job.id);
        });

        showMessage('Job saved successfully');
      }
    } catch (e) {
      if (!mounted) return;

      showMessage('Unable to update saved job');
    } finally {
      if (!mounted) return;

      setState(() {
        savingJobIds.remove(job.id);
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> openJob(Job job) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            JobDetailsScreen(job: job),
      ),
    );

    if (!mounted) return;

    await loadJobs();
  }

  Future<void> openSavedJobs() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SavedJobsScreen(),
      ),
    );

    if (!mounted) return;

    await loadJobs();
  }

  Future<void> openApplications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ApplicationsScreen(),
      ),
    );

    if (!mounted) return;

    await loadJobs();
  }

  Future<void> openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const NotificationsScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  Future<void> openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const ProfileScreen(),
      ),
    );

    if (!mounted) return;

    await loadJobs();
  }

  Future<void> showFilterSheet() async {
    String tempLocation = selectedLocation;
    String tempType = selectedType;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (
              context,
              setModalState,
              ) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom:
                  MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                      20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter Jobs',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Find jobs that match your preferences',
                        style: TextStyle(
                          color:
                          Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'All',
                          'Remote',
                          'On-site',
                          'Hybrid',
                        ].map((location) {
                          final selected =
                              tempLocation ==
                                  location;

                          return ChoiceChip(
                            label:
                            Text(location),
                            selected: selected,
                            onSelected: (_) {
                              setModalState(() {
                                tempLocation =
                                    location;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Job Type',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'All',
                          'Full-time',
                          'Part-time',
                          'Internship',
                        ].map((type) {
                          final selected =
                              tempType == type;

                          return ChoiceChip(
                            label: Text(type),
                            selected: selected,
                            onSelected: (_) {
                              setModalState(() {
                                tempType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedLocation =
                                  tempLocation;
                              selectedType =
                                  tempType;
                            });

                            applyFilters();

                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.check_rounded,
                          ),
                          label: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                          style:
                          ElevatedButton.styleFrom(
                            minimumSize:
                            const Size(
                              double.infinity,
                              52,
                            ),
                            backgroundColor:
                            Colors.blue,
                            foregroundColor:
                            Colors.white,
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void clearAllFilters() {
    _searchController.clear();

    setState(() {
      selectedLocation = 'All';
      selectedType = 'All';
    });

    applyFilters();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    }

    if (hour < 17) {
      return 'Good Afternoon';
    }

    return 'Good Evening';
  }

  String getUserName() {
    final user =
        FirebaseAuth.instance.currentUser;

    final displayName =
    user?.displayName?.trim();

    if (displayName == null ||
        displayName.isEmpty) {
      return 'there';
    }

    return displayName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F9FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black87,

        title: const Text(
          'JobMate',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 21,
          ),
        ),

        actions: [
          StreamBuilder<
              List<NotificationModel>>(
            stream:
            _notificationService
                .getNotifications(),
            builder: (
                context,
                snapshot,
                ) {
              final notifications =
                  snapshot.data ?? [];

              final unreadCount =
                  notifications
                      .where(
                        (notification) =>
                    !notification.isRead,
                  )
                      .length;

              return Padding(
                padding:
                const EdgeInsets.only(
                  right: 6,
                ),
                child: Stack(
                  children: [
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed:
                      openNotifications,
                      icon: const Icon(
                        Icons
                            .notifications_none_rounded,
                      ),
                    ),

                    if (unreadCount > 0)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          constraints:
                          const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          decoration:
                          const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 9
                                ? '9+'
                                : unreadCount
                                .toString(),
                            textAlign:
                            TextAlign.center,
                            style:
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        color: Colors.blue,
        onRefresh: loadJobs,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildGreeting(),

              const SizedBox(height: 20),

              _buildSearchSection(),

              const SizedBox(height: 12),

              _buildActiveFilters(),

              const SizedBox(height: 24),

              if (isLoading)
                _buildLoadingState()
              else if (errorMessage != null)
                _buildErrorState()
              else ...[
                  if (recommendedJobs.isNotEmpty)
                    _buildRecommendedSection(),

                  if (recommendedJobs.isNotEmpty)
                    const SizedBox(height: 28),

                  _buildLatestJobsSection(),
                ],
            ],
          ),
        ),
      ),

      bottomNavigationBar:
      _buildBottomNavigationBar(),
    );
  }

  Widget _buildGreeting() {
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
        borderRadius:
        BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(
              alpha: 0.18,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '${getGreeting()}, ${getUserName()} 👋',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Find your next opportunity',
                  style: TextStyle(
                    color:
                    Colors.white.withValues(
                      alpha: 0.90,
                    ),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: 0.025),
                  blurRadius: 8,
                  offset:
                  const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller:
              _searchController,
              textInputAction:
              TextInputAction.search,
              decoration: InputDecoration(
                hintText:
                'Search jobs, companies...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                suffixIcon:
                _searchController
                    .text
                    .isNotEmpty
                    ? IconButton(
                  tooltip:
                  'Clear search',
                  onPressed: () {
                    clearAllFilters();
                  },
                  icon: const Icon(
                    Icons.clear_rounded,
                  ),
                )
                    : null,
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets
                    .symmetric(
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius:
            BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue
                    .withValues(alpha: 0.18),
                blurRadius: 10,
                offset:
                const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            tooltip: 'Filter jobs',
            onPressed: showFilterSheet,
            icon: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    final hasLocationFilter =
        selectedLocation != 'All';

    final hasTypeFilter =
        selectedType != 'All';

    if (!hasLocationFilter &&
        !hasTypeFilter) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (hasLocationFilter)
              _buildFilterChip(
                selectedLocation,
                    () {
                  setState(() {
                    selectedLocation =
                    'All';
                  });
                  applyFilters();
                },
              ),

            if (hasLocationFilter &&
                hasTypeFilter)
              const SizedBox(width: 8),

            if (hasTypeFilter)
              _buildFilterChip(
                selectedType,
                    () {
                  setState(() {
                    selectedType = 'All';
                  });
                  applyFilters();
                },
              ),

            const SizedBox(width: 6),

            TextButton.icon(
              onPressed: clearAllFilters,
              icon: const Icon(
                Icons.clear_all_rounded,
                size: 17,
              ),
              label:
              const Text('Clear all'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label,
      VoidCallback onDeleted,
      ) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      deleteIcon: const Icon(
        Icons.close,
        size: 16,
      ),
      onDeleted: onDeleted,
      backgroundColor:
      Colors.blue.withValues(
        alpha: 0.08,
      ),
      side: BorderSide(
        color: Colors.blue.withValues(
          alpha: 0.15,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 50,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 34,
            width: 34,
            child:
            CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Finding opportunities for you...',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.orange
                    .withValues(alpha: 0.10),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.orange,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            const Expanded(
              child: Text(
                'Recommended For You',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 205,
          child: ListView.separated(
            scrollDirection:
            Axis.horizontal,
            itemCount:
            recommendedJobs.length,
            separatorBuilder:
                (context, index) =>
            const SizedBox(width: 12),
            itemBuilder:
                (context, index) {
              final job =
              recommendedJobs[index];

              return _buildRecommendedCard(
                job,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedCard(Job job) {
    final isSaved =
    savedJobIds.contains(job.id);

    return InkWell(
      onTap: () => openJob(job),
      borderRadius:
      BorderRadius.circular(20),
      child: Container(
        width: 290,
        padding:
        const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.04),
              blurRadius: 10,
              offset:
              const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration:
                  BoxDecoration(
                    color: Colors.blue
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .business_center_outlined,
                    color: Colors.blue,
                  ),
                ),

                const Spacer(),

                Icon(
                  isSaved
                      ? Icons.bookmark
                      : Icons
                      .bookmark_border,
                  color: isSaved
                      ? Colors.blue
                      : Colors.grey,
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              job.title.isEmpty
                  ? 'Job Opportunity'
                  : job.title,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              job.company.isEmpty
                  ? 'Company'
                  : job.company,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                color:
                Colors.grey.shade700,
                fontSize: 13,
              ),
            ),

            const Spacer(),

            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location.isEmpty
                        ? 'Remote'
                        : job.location,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors
                          .grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestJobsSection() {
    final jobs = filteredJobs;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Latest Jobs',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),

            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.blue
                    .withValues(alpha: 0.08),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Text(
                '${jobs.length} jobs',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (jobs.isEmpty)
          _buildNoJobsState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            itemCount: jobs.length,
            separatorBuilder:
                (context, index) =>
            const SizedBox(height: 12),
            itemBuilder:
                (context, index) {
              return _buildJobCard(
                jobs[index],
              );
            },
          ),
      ],
    );
  }

  Widget _buildJobCard(Job job) {
    final isSaved =
    savedJobIds.contains(job.id);

    final isSaving =
    savingJobIds.contains(job.id);

    return InkWell(
      onTap: () => openJob(job),
      borderRadius:
      BorderRadius.circular(20),
      child: Container(
        padding:
        const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.025),
              blurRadius: 8,
              offset:
              const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.blue
                    .withValues(
                  alpha: 0.09,
                ),
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              child: const Icon(
                Icons
                    .business_center_rounded,
                color: Colors.blue,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title.isEmpty
                        ? 'Job Opportunity'
                        : job.title,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    job.company.isEmpty
                        ? 'Company'
                        : job.company,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                      Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _buildSmallInfo(
                        Icons
                            .location_on_outlined,
                        job.location.isEmpty
                            ? 'Remote'
                            : job.location,
                      ),
                      _buildSmallInfo(
                        Icons.work_outline,
                        job.type.isEmpty
                            ? 'Job'
                            : job.type,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: isSaving
                    ? null
                    : () =>
                    toggleSaveJob(job),
                tooltip: isSaved
                    ? 'Remove saved job'
                    : 'Save job',
                style: IconButton.styleFrom(
                  backgroundColor: isSaved
                      ? Colors.blue
                      .withValues(
                    alpha: 0.08,
                  )
                      : Colors.transparent,
                ),
                icon: isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Icon(
                  isSaved
                      ? Icons.bookmark
                      : Icons
                      .bookmark_border,
                  color: isSaved
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInfo(
      IconData icon,
      String text,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey,
        ),
        const SizedBox(width: 3),
        ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 120,
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoJobsState() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.blue
                  .withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: Colors.blue,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Try changing your search or filters.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: clearAllFilters,
            icon: const Icon(
              Icons.clear_all_rounded,
              size: 18,
            ),
            label:
            const Text('Clear Filters'),
            style:
            OutlinedButton.styleFrom(
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.redAccent
                  .withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              size: 34,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Unable to load jobs',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            errorMessage ??
                'Something went wrong.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: loadJobs,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label:
            const Text('Try Again'),
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              Colors.blue,
              foregroundColor:
              Colors.white,
              elevation: 0,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: Colors.white,
      elevation: 2,
      indicatorColor:
      Colors.blue.withValues(
        alpha: 0.12,
      ),
      onDestinationSelected:
          (index) async {
        setState(() {
          currentIndex = index;
        });

        if (index == 0) {
          return;
        }

        if (index == 1) {
          await openSavedJobs();
        } else if (index == 2) {
          await openApplications();
        } else if (index == 3) {
          await openProfile();
        }

        if (!mounted) return;

        setState(() {
          currentIndex = 0;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
          ),
          selectedIcon: Icon(
            Icons.home,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.bookmark_border,
          ),
          selectedIcon: Icon(
            Icons.bookmark,
          ),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.assignment_outlined,
          ),
          selectedIcon: Icon(
            Icons.assignment,
          ),
          label: 'Applications',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
          ),
          selectedIcon: Icon(
            Icons.person,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}