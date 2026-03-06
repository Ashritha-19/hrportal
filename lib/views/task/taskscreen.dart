// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:hrportal/constants/companyLogo.dart';
import 'package:hrportal/views/notifications/notificationIcon.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/service/tasksService.dart';
import 'package:hrportal/views/task/taskcard.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    print('🟢 TasksScreen initState');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('➡️ Calling getTasks() from UI');
      context.read<TaskProvider>().getTasks();
    });
  }

  /// 📅 Date format
  String formatDate(String date) {
    final parsed = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);

    print('🔄 UI BUILD | Loading = ${provider.isLoading}');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar:  AppBar(
          leading: const CompanyLogoIcon(size: 28),
          automaticallyImplyLeading: false,
          backgroundColor: theme.cardColor,
          elevation: 0,
          titleSpacing: 16,
          title: Text(
            "My Tasks",
            style: theme.textTheme.titleMedium!.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: const [NotificationIcon()],
        ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.tasks.isEmpty
          ? Center(
              child: Text('No Tasks Found', style: theme.textTheme.bodyMedium),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];

                print('🧩 TASK $index: $task');

                return TaskCard(
                  title: task['title'] ?? '',
                  project: task['project_name'] ?? '',
                  date: formatDate(task['task_date'] ?? ''),

                  priority:
                      task['priority'] != null && task['priority'].isNotEmpty
                      ? task['priority'][0].toUpperCase() +
                            task['priority'].substring(1)
                      : '',

                  status: task['status'] == 'todo'
                      ? 'To Do'
                      : task['status'] == 'inprogress'
                      ? 'In Progress'
                      : task['status'] == 'done'
                      ? 'Done'
                      : '',
                );
              },
            ),
    );
  }
}
