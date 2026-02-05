// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String project;
  final String date;
  final String priority;
  final String status;

  const TaskCard({
    super.key,
    required this.title,
    required this.project,
    required this.date,
    required this.priority,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// PROJECT
          Row(
            children: [
              Icon(
                Icons.folder,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                project,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// CHIPS
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip(
                context,
                "Date: $date",
                theme.colorScheme.surfaceVariant,
                theme.textTheme.bodySmall!.color!,
              ),
              _priorityChip(context, priority),
              _statusChip(context, status),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CHIP HELPERS =================

  Widget _chip(
    BuildContext context,
    String text,
    Color bg,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  Widget _priorityChip(BuildContext context, String priority) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;

    switch (priority.toLowerCase()) {
      case 'high':
        bgColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red;
        break;
      case 'medium':
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        break;
      case 'low':
        bgColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green;
        break;
      default:
        bgColor = theme.colorScheme.surfaceVariant;
        textColor = theme.textTheme.bodySmall!.color!;
    }

    return _chip(context, priority, bgColor, textColor);
  }

  Widget _statusChip(BuildContext context, String status) {
    final theme = Theme.of(context);

    return _chip(
      context,
      status,
      theme.colorScheme.primary.withOpacity(0.15),
      theme.colorScheme.primary,
    );
  }
}
