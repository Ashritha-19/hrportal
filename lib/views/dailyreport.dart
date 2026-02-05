// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hrportal/service/report/projectservice.dart';
import 'package:hrportal/service/report/worktypeservice.dart';
import 'package:hrportal/service/report/submitreportservice.dart';
import 'package:hrportal/service/report/reportservice.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ReportsProvider>().fetchReports();
      context.read<ProjectsProvider>().fetchProjects();
      context.read<WorkTypesProvider>().fetchWorkTypes();
    });

    minutesController.addListener(() {
      final value = int.tryParse(minutesController.text);
      if (value != null && value > 59) {
        minutesController.text = "59";
        minutesController.selection = const TextSelection.collapsed(offset: 2);
      }
    });
  }

  String selectedProjectId = "";
  String selectedWorkType = "";

  final DateTime currentDate = DateTime.now();

  final TextEditingController hoursController = TextEditingController(
    text: "00",
  );
  final TextEditingController minutesController = TextEditingController(
    text: "00",
  );
  final TextEditingController taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
        title: Text("Reports", style: theme.textTheme.titleMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= SUBMIT REPORT =================
            _card(
              theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Submit New Report", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),

                  _label(theme, "Select Project", Icons.folder),
                  Consumer<ProjectsProvider>(
                    builder: (_, provider, __) {
                      if (provider.isLoading) {
                        return const CircularProgressIndicator();
                      }

                      if (provider.projects.isEmpty) {
                        return const Text("No projects available");
                      }

                      if (selectedProjectId.isEmpty) {
                        selectedProjectId = provider.projects.first["id"]
                            .toString();
                      }

                      return DropdownButtonFormField<String>(
                        value: selectedProjectId,
                        decoration: _inputDecoration(theme),
                        items: provider.projects.map((project) {
                          return DropdownMenuItem(
                            value: project["id"].toString(),
                            child: Text(project["name"]),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedProjectId = val!),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _label(theme, "Select Work Type", Icons.work),
                  Consumer<WorkTypesProvider>(
                    builder: (_, provider, __) {
                      if (provider.isLoading) {
                        return const CircularProgressIndicator();
                      }

                      if (provider.workTypes.isEmpty) {
                        return const Text("No work types available");
                      }

                      if (selectedWorkType.isEmpty) {
                        selectedWorkType = provider.workTypes.first;
                      }

                      return DropdownButtonFormField(
                        value: selectedWorkType,
                        decoration: _inputDecoration(theme),
                        items: provider.workTypes
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedWorkType = val!),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: _staticDate(theme)),
                      const SizedBox(width: 12),
                      _durationPicker(theme),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _label(theme, "Task Description", Icons.description),
                  TextField(
                    controller: taskController,
                    maxLines: 3,
                    decoration: _inputDecoration(theme),
                  ),

                  const SizedBox(height: 20),

                  Consumer<SubmitReportProvider>(
                    builder: (_, provider, __) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: provider.isSubmitting
                              ? null
                              : _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: provider.isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Submit Report"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text("Recent Work Reports", style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            Consumer<ReportsProvider>(
              builder: (_, provider, __) {
                if (provider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (provider.reports.isEmpty) {
                  return Text(
                    "No reports available",
                    style: theme.textTheme.bodySmall,
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.reports.length,
                  itemBuilder: (_, index) {
                    final report = provider.reports[index];

                    return _reportTile(
                      theme,
                      color: _getColorByWorkType(report["work_type"], theme),
                      icon: _getIconByWorkType(report["work_type"]),
                      time: report["report_date"] ?? "",
                      title:
                          "${report["project_name"]} - ${report["work_type"]}",
                      subtitle: report["task_description"] ?? "",
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _staticDate(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(theme, "Date", Icons.calendar_today),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _boxDecoration(theme),
          alignment: Alignment.centerLeft,
          child: Text(
            "${currentDate.day}/${currentDate.month}/${currentDate.year}",
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _durationPicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Duration", style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            _numberBox(theme, controller: hoursController),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(":"),
            ),
            _numberBox(theme, controller: minutesController),
          ],
        ),
      ],
    );
  }

  Widget _numberBox(
    ThemeData theme, {
    required TextEditingController controller,
  }) {
    return SizedBox(
      height: 48,
      width: 48,
      child: Container(
        decoration: _boxDecoration(theme),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          maxLength: 2,
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "",
          ),
        ),
      ),
    );
  }

  Widget _label(ThemeData theme, String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _card(ThemeData theme, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(theme),
      child: child,
    );
  }

  Widget _reportTile(
    ThemeData theme, {
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(theme),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: theme.textTheme.bodySmall),
                Text(title, style: theme.textTheme.bodyMedium),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitReport() async {
    if (taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter task description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int hours = int.tryParse(hoursController.text) ?? 0;
    final int minutes = int.tryParse(minutesController.text) ?? 0;

    final totalHours = hours + (minutes / 60);

    final success = await context.read<SubmitReportProvider>().submitReport(
      projectId: selectedProjectId, // ✅ ID sent
      taskDescription: taskController.text.trim(),
      hoursWorked: totalHours.toStringAsFixed(2),
      reportDate:
          "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}",
      workType: selectedWorkType,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        // clear text fields
        taskController.clear();
        hoursController.text = "00";
        minutesController.text = "00";

        // 🔥 RESET DROPDOWNS
        selectedProjectId = "";
        selectedWorkType = "";
      });

      context.read<ReportsProvider>().fetchReports();
    }
  }

  InputDecoration _inputDecoration(ThemeData theme) {
    return InputDecoration(
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  BoxDecoration _boxDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Color _getColorByWorkType(String? type, ThemeData theme) {
    switch (type) {
      case "Tech":
        return theme.colorScheme.primary;
      case "Social Media":
        return Colors.green;
      case "AMC":
        return Colors.orange;
      default:
        return theme.iconTheme.color ?? Colors.grey;
    }
  }

  IconData _getIconByWorkType(String? type) {
    switch (type) {
      case "Tech":
        return Icons.code;
      case "Social Media":
        return Icons.campaign;
      case "AMC":
        return Icons.build;
      default:
        return Icons.work_outline;
    }
  }
}
