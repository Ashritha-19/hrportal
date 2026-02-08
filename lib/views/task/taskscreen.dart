// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);

    print('🔄 UI BUILD | Loading = ${provider.isLoading}');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text(
          "My Tasks",
          style: theme.textTheme.titleMedium!.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
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
                  date: task['task_date'] ?? '',
                  priority: task['priority'] ?? '',
                  status: task['status'] ?? '',
                );
              },
            ),
    );
  }
}
