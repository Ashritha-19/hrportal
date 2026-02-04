// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hrportal/constants/colors.dart';
import 'package:hrportal/service/profile/leaveReqService.dart';
import 'package:provider/provider.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  /// Controllers
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;

  String selectedLeaveType = 'Sick Leave';

  final List<String> leaveTypes = [
    'Sick Leave',
    'Casual Leave',
    'Emergency Leave',
    'Earned Leave',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LeaveRequestProvider>().fetchLeaveRequests();
    });
  }

  void clearForm() {
    reasonController.clear();
    fromDateController.clear();
    toDateController.clear();
    fromDate = null;
    toDate = null;
    selectedLeaveType = 'Sick Leave';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: Consumer<LeaveRequestProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              /// ===== SUBMIT REQUEST BUTTON =====
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openApplyLeaveSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Leave Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              /// ===== LEAVE LIST =====
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.leaveList.isEmpty
                    ? const Center(child: Text('No Leave Requests'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.leaveList.length,
                        itemBuilder: (context, index) {
                          final item = provider.leaveList[index];

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['leave_type'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: item['status'] == 'approved'
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          item['status']
                                              .toString()
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.date_range,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${item['from_date']} → ${item['to_date']}',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    'Days: ${item['total_days']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    'Reason: ${item['reason']}',
                                    style: const TextStyle(
                                      color: AppColors.blackPanther,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    'Applied On: ${item['submitted_at']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ================= BOTTOM SHEET =================
  void _openApplyLeaveSheet(BuildContext context) {
    final parentContext = context; // ✅ screen context

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        // ✅ bottom sheet context
        return Consumer<LeaveRequestProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Apply Leave',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedLeaveType,
                      decoration: _boxDecoration('Leave Type'),
                      items: leaveTypes
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedLeaveType = val!),
                    ),

                    const SizedBox(height: 12),

                    _boxedDateField(
                      label: 'From Date',
                      controller: fromDateController,
                      onPick: (d) => fromDate = d,
                    ),

                    const SizedBox(height: 12),

                    _boxedDateField(
                      label: 'To Date',
                      controller: toDateController,
                      onPick: (d) => toDate = d,
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: _boxDecoration('Reason'),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      child: ElevatedButton(
                        onPressed: provider.isSubmitting
                            ? null
                            : () async {
                                if (fromDate == null || toDate == null) {
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select From and To dates',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final success = await provider.applyLeave(
                                  leaveType: selectedLeaveType,
                                  fromDate: fromDate!
                                      .toIso8601String()
                                      .substring(0, 10),
                                  toDate: toDate!.toIso8601String().substring(
                                    0,
                                    10,
                                  ),
                                  reason: reasonController.text,
                                );

                                if (success) {
                                  clearForm();

                                  // ✅ CLOSE BOTTOM SHEET
                                  Navigator.pop(sheetContext);

                                  // ✅ SHOW MESSAGE ON SCREEN
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Leave request submitted successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                        child: provider.isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Submit Request'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ================= HELPERS =================
  InputDecoration _boxDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }

  Widget _boxedDateField({
    required String label,
    required TextEditingController controller,
    required Function(DateTime) onPick,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: _boxDecoration(
        label,
      ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          controller.text = picked.toIso8601String().substring(0, 10);
          onPick(picked);
        }
      },
    );
  }
}
