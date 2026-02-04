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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.folder, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(project, style: const TextStyle(color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _chip("Date: $date", Colors.grey.shade200, Colors.black),
              const SizedBox(width: 6),
              _priorityChip(priority),
              const SizedBox(width: 6),
              _chip(status, Colors.green.shade100, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }

  Widget _priorityChip(String priority) {
    Color bgColor;
    Color textColor;

    switch (priority.toLowerCase()) {
      case 'high':
        bgColor = Colors.red.shade100;
        textColor = Colors.red;
        break;
      case 'medium':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange;
        break;
      case 'low':
        bgColor = Colors.green.shade100;
        textColor = Colors.green;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.black;
    }

    return _chip(priority, bgColor, textColor);
  }
}
