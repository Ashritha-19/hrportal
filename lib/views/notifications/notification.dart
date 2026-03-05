// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/constants/approutes.dart';
import 'package:hrportal/service/notificationservice.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
          ? const Center(child: Text("No notifications"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final n = provider.notifications[index];
                final bool isUnread = n["is_read"] == 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? theme.colorScheme.primary.withOpacity(0.10)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUnread
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await provider.readNotification(index);

                            _handleRedirect(n["redirect_url"] as String?);
                          },
                          child: Text(
                            n["message"],
                            style: theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),

                      /// 🗑 DELETE ICON
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () async {
                          final success = await provider.deleteNotification(
                            index,
                          );

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Notification deleted successfully",
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to delete notification"),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _handleRedirect(String? redirectUrl) {
    if (redirectUrl == null) return;

    switch (redirectUrl) {
      case 'employee/leaves':
        Get.toNamed(AppRoutes.leaves);
        break;
      case 'employee/wfh':
        Get.toNamed(AppRoutes.wfh);
        break;
      case 'employee/reports':
        Get.toNamed(AppRoutes.reports);
        break;
      case 'employee/tasks':
        Get.toNamed(AppRoutes.tasks);
        break;
    }
  }
}
