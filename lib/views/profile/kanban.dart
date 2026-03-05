// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../service/profile/kanbanService.dart';

class KanbanBoardScreen extends StatefulWidget {
  const KanbanBoardScreen({super.key});

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<KanbanProvider>().fetchKanbanTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kanban Board")),
      body: Consumer<KanbanProvider>(
        builder: (context, provider, _) {

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSection("Upcoming", provider.upcoming),
                _buildSection("In Progress", provider.inProgress),
                _buildSection("Completed", provider.completed),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= SECTION =================
  Widget _buildSection(
      String title,
      List<Map<String, dynamic>> tasks,
      ) {

    String statusKey =
    title == "Upcoming"
        ? "todo"
        : title == "In Progress"
        ? "progress"
        : "done";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: DragTarget<Map<String, dynamic>>(
        onAcceptWithDetails: (details) {

          final task = details.data;

          print("🎯 Dropped into $statusKey");

          context.read<KanbanProvider>().moveTask(
            task: task,
            newStatus: statusKey,
            newIndex: tasks.length,
          );
        },
        builder: (context, candidateData, rejectedData) {

          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "$title (${tasks.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    onReorder: (oldIndex, newIndex) {

                      if (newIndex > oldIndex) newIndex--;

                      final task = tasks.removeAt(oldIndex);
                      tasks.insert(newIndex, task);

                      context.read<KanbanProvider>().moveTask(
                        task: task,
                        newStatus: statusKey,
                        newIndex: newIndex,
                      );
                    },
                    itemBuilder: (context, index) {

                      final task = tasks[index];

                      return LongPressDraggable<Map<String, dynamic>>(
                        key: ValueKey(task['id']),
                        data: task,
                        feedback: Material(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: _taskRowCard(task),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: _taskRowCard(task),
                        ),
                        child: _taskRowCard(task),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ================= TASK CARD =================
  Widget _taskRowCard(Map<String, dynamic> task) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: 6,
              height: 60,
              decoration: BoxDecoration(
                color: _getPriorityColor(task['priority']),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'] ?? "",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    task['project_name'] ?? "",
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Date: ${task['task_date']}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const Icon(Icons.drag_indicator),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}