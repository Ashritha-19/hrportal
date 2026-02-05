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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black54,
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  const Text(
                    "Add Late Reason",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // 📅 Date (static)
                  const Text(
                    "Date",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(formatDate(date)),
                  ),

                  const SizedBox(height: 16),

                  // 📝 Reason
                  const Text(
                    "Reason",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter late reason",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔘 Submit
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

                              // ✅ 1. Clear controller
                              reasonController.clear();

                              // ✅ 2. Close bottom sheet
                              Navigator.pop(sheetContext);

                              // ✅ 3. Show SnackBar AFTER sheet closes
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
    return Scaffold(
      appBar: AppBar(title: const Text("My Attendance History")),
      body: Consumer<AttendanceProvider>(
        builder: (_, ap, __) {
          if (ap.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ap.attendanceList.isEmpty) {
            return const Center(child: Text("No attendance data"));
          }

          return ListView.builder(
            itemCount: ap.attendanceList.length,
            itemBuilder: (context, index) {
              final item = ap.attendanceList[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleValue("Date", formatDate(item['attendance_date'])),

                      titleValue("Check-in Time", item['check_in_time'] ?? "-"),

                      titleValue(
                        "Status",
                        item['status'],
                        valueColor: statusColor(item['status']),
                        valueWeight: FontWeight.w600,
                      ),

                      titleValue(
                        "Late Justification",
                        item['late_reason'] ?? "-",
                      ),

                      titleValue("Approval", item['approval_status'] ?? "-"),

                      const SizedBox(height: 10),

                      if (item['is_late'] == "1")
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              print(
                                "✏️ Add Reason clicked for ID => ${item['id']}",
                              );

                              showAddReasonBottomSheet(
                                context: context,
                                attendanceId: int.parse(item['id'].toString()),
                                date: item['attendance_date'],
                              );
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text("Add Reason"),
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
}
