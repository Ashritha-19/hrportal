// ignore_for_file: unnecessary_underscores, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hrportal/service/profile/attendanceService.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchAttendance();
    });
  }

  /// 📅 Date format
  String formatDate(String date) {
    final parsed = DateTime.parse(date);
    return DateFormat('dd MMM, yyyy').format(parsed);
  }

  /// 🧱 Title : Value row
  Widget titleValue(
    ThemeData theme,
    String title,
    String value, {
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$title :",
              style: theme.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: valueColor ?? theme.textTheme.bodySmall!.color,
                fontWeight: valueWeight ?? FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color statusColor(String status) {
    if (status == "Late") return Colors.red;
    if (status == "Grace Period") return Colors.blue;
    return Colors.green;
  }

  // ===============================
  // 🧾 ADD REASON BOTTOM SHEET
  // ===============================
  void showAddReasonBottomSheet({
    required BuildContext context,
    required int attendanceId,
    required String date,
  }) {
    final TextEditingController reasonController = TextEditingController();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Consumer<AttendanceProvider>(
            builder: (_, ap, __) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Late Reason",
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Date",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: _outlinedBox(theme),
                    child: Text(formatDate(date)),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Reason",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      theme,
                      hint: "Enter late reason",
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🟢 GREEN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ap.isSubmitting
                          ? null
                          : () async {
                              final reason = reasonController.text.trim();

                              if (reason.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Reason cannot be empty"),
                                  ),
                                );
                                return;
                              }

                              final success = await ap.submitLateReason(
                                attendanceId: attendanceId,
                                reason: reason,
                              );

                              if (!success) return;

                              reasonController.clear();
                              Navigator.pop(sheetContext);

                              Future.delayed(Duration.zero, () {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Reason submitted successfully",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: ap.isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Submit"),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ===============================
  // 📱 UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text(
          "My Attendance",
          style: theme.textTheme.titleMedium!.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        iconTheme: theme.iconTheme,
      ),
      body: Consumer<AttendanceProvider>(
        builder: (_, ap, __) {
          if (ap.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ap.attendanceList.isEmpty) {
            return Center(
              child: Text(
                "No attendance data",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            itemCount: ap.attendanceList.length,
            itemBuilder: (context, index) {
              final item = ap.attendanceList[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleValue(
                        theme,
                        "Date",
                        formatDate(item['attendance_date']),
                      ),
                      titleValue(
                        theme,
                        "Check-in Time",
                        item['check_in_time'] ?? "-",
                      ),
                      titleValue(
                        theme,
                        "Status",
                        item['status'],
                        valueColor: statusColor(item['status']),
                        valueWeight: FontWeight.w600,
                      ),
                      titleValue(
                        theme,
                        "Late Justification",
                        item['late_reason'] ?? "-",
                      ),
                      titleValue(
                        theme,
                        "Approval",
                        item['approval_status'] ?? "-",
                      ),
                      const SizedBox(height: 10),
                      if (item['is_late'] == "1")
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showAddReasonBottomSheet(
                                context: context,
                                attendanceId: int.parse(item['id'].toString()),
                                date: item['attendance_date'],
                              );
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text("Add Reason"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===============================
  // 🎨 DECORATIONS
  // ===============================

  InputDecoration _inputDecoration(ThemeData theme, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.cardColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }

  BoxDecoration _outlinedBox(ThemeData theme) {
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: theme.dividerColor),
    );
  }
}
