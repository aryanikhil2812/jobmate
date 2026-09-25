import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  final NotificationService _notificationService =
  NotificationService();

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All notifications marked as read',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update notifications',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> markAsRead(
      NotificationModel notification,
      ) async {
    if (notification.isRead) return;

    try {
      await _notificationService.markAsRead(
        notification.id,
      );
    } catch (e) {
      // Ignore update error.
    }
  }

  Future<void> deleteNotification(
      NotificationModel notification,
      ) async {
    try {
      await _notificationService.deleteNotification(
        notification.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification deleted',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to delete notification',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  IconData getNotificationIcon(String type) {
    switch (type) {
      case 'application':
        return Icons.work_outline;

      case 'shortlisted':
        return Icons.star_outline;

      case 'interview':
        return Icons.event_outlined;

      case 'selected':
        return Icons.celebration_outlined;

      case 'rejected':
        return Icons.info_outline;

      default:
        return Icons.notifications_none;
    }
  }

  Color getNotificationColor(String type) {
    switch (type) {
      case 'application':
        return Colors.blue;

      case 'shortlisted':
        return Colors.orange;

      case 'interview':
        return Colors.purple;

      case 'selected':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      default:
        return Colors.blue;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,

        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          TextButton(
            onPressed: markAllAsRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder<List<NotificationModel>>(
        stream:
        _notificationService.getNotifications(),

        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final notifications =
              snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,

            separatorBuilder:
                (context, index) =>
            const SizedBox(height: 10),

            itemBuilder: (
                context,
                index,
                ) {
              final notification =
              notifications[index];

              return Dismissible(
                key: Key(notification.id),

                direction:
                DismissDirection.endToStart,

                background: Container(
                  alignment:
                  Alignment.centerRight,
                  padding:
                  const EdgeInsets.only(
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ),

                confirmDismiss:
                    (direction) async {
                  await deleteNotification(
                    notification,
                  );

                  return false;
                },

                child: _buildNotificationCard(
                  notification,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      NotificationModel notification,
      ) {
    final color =
    getNotificationColor(
      notification.type,
    );

    return InkWell(
      onTap: () =>
          markAsRead(notification),

      borderRadius:
      BorderRadius.circular(18),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : Colors.blue.withValues(
            alpha: 0.06,
          ),

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade200
                : Colors.blue.withValues(
              alpha: 0.20,
            ),
          ),
        ),

        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Container(
              height: 48,
              width: 48,

              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),

              child: Icon(
                getNotificationIcon(
                  notification.type,
                ),
                color: color,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                          ),
                        ),
                      ),

                      if (!notification.isRead)
                        Container(
                          height: 8,
                          width: 8,
                          decoration:
                          const BoxDecoration(
                            color: Colors.blue,
                            shape:
                            BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    notification.message,
                    style: TextStyle(
                      color:
                      Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    formatDate(
                      notification.createdAt,
                    ),
                    style: TextStyle(
                      color:
                      Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Container(
              height: 90,
              width: 90,

              decoration: BoxDecoration(
                color: Colors.blue.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.notifications_none_rounded,
                size: 45,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You are all caught up!\n'
                  'New job and application updates '
                  'will appear here.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 16),

            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Unable to load notifications.',
              style: TextStyle(
                color:
                Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}