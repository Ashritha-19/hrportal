// ignore_for_file: deprecated_member_use, use_build_context_synchronously

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

    // restrict minutes to 0–59
    minutesController.addListener(() {
      final value = int.tryParse(minutesController.text);
      if (value != null && value > 59) {
        minutesController.text = "59";
        minutesController.selection = const TextSelection.collapsed(offset: 2);
      }
    });
  }

  /// store ONLY IDs
  String selectedProjectId = "";
  String selectedWorkType = ""; // name for now (can convert to ID later)

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.black),
        title: const Text("Reports", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= SUBMIT REPORT =================
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Submit New Report",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  /// -------- Project Dropdown (NAME SHOWN, ID STORED) --------
                  _label("Select Project", Icons.folder),
                  Consumer<ProjectsProvider>(
                    builder: (context, provider, _) {
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
                        decoration: _inputDecoration(""),
                        items: provider.projects.map((project) {
                          return DropdownMenuItem<String>(
                            value: project["id"].toString(), // ✅ ID
                            child: Text(project["name"]), // 👀 NAME
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => selectedProjectId = val!);
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// -------- Work Type Dropdown --------
                  _label("Select Work Type", Icons.work),
                  Consumer<WorkTypesProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const CircularProgressIndicator();
                      }

                      if (provider.workTypes.isEmpty) {
                        return const Text("No work types available");
                      }

                      if (selectedWorkType.isEmpty) {
                        selectedWorkType = provider.workTypes.first;
                      }

                      return _dropdown(
                        provider.workTypes,
                        selectedWorkType,
                        (val) => setState(() => selectedWorkType = val),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// -------- Date + Duration --------
                  Row(
                    children: [
                      Expanded(child: _staticDate()),
                      const SizedBox(width: 12),
                      _durationPicker(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// -------- Task Description --------
                  _label("Task Description", Icons.description),
                  TextField(
                    controller: taskController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      "Describe the tasks completed...",
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// -------- Submit Button --------
                  Consumer<SubmitReportProvider>(
                    builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: provider.isSubmitting
                              ? null
                              : _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: provider.isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Submit Report",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= RECENT REPORTS =================
            const Text(
              "Recent Work Reports",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Consumer<ReportsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (provider.reports.isEmpty) {
                  return const Center(
                    child: Text(
                      "No reports available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.reports.length,
                  itemBuilder: (context, index) {
                    final report = provider.reports[index];

                    return _reportTile(
                      color: _getColorByWorkType(report["work_type"]),
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

  // ================= SUBMIT LOGIC =================

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

  // ================= UI HELPERS =================

  Widget _staticDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Date", Icons.calendar_today),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _boxDecoration(),
          alignment: Alignment.centerLeft,
          child: Text(
            "${currentDate.day}/${currentDate.month}/${currentDate.year}",
          ),
        ),
      ],
    );
  }

  Widget _durationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Duration"),
        const SizedBox(height: 6),
        Row(
          children: [
            _numberBox(controller: hoursController),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(":"),
            ),
            _numberBox(controller: minutesController),
          ],
        ),
      ],
    );
  }

  Widget _numberBox({required TextEditingController controller}) {
    return SizedBox(
      height: 48,
      width: 48,
      child: Container(
        decoration: _boxDecoration(),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 2,
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "",
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    List<String> items,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField(
      value: value,
      decoration: _inputDecoration(""),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) => onChanged(val!),
    );
  }

  Widget _label(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(color: Colors.white),
      child: child,
    );
  }

  Widget _reportTile({
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(color: Colors.white),
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
                Text(time, style: const TextStyle(color: Colors.grey)),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  BoxDecoration _boxDecoration({Color color = const Color(0xFFF5F6FA)}) {
    return BoxDecoration(color: color, borderRadius: BorderRadius.circular(12));
  }

  Color _getColorByWorkType(String? type) {
    switch (type) {
      case "Tech":
        return Colors.blue;
      case "Social Media":
        return Colors.green;
      case "AMC":
        return Colors.orange;
      default:
        return Colors.grey;
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
