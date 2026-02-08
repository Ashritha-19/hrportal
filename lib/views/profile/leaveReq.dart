// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/service/profile/leaveReqService.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text(
          "Leave Requests",
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
      body: Consumer<LeaveRequestProvider>(
        builder: (_, provider, __) {
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
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Leave Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                    ? Center(
                        child: Text(
                          'No Leave Requests',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.leaveList.length,
                        itemBuilder: (_, index) {
                          final item = provider.leaveList[index];

                          final bool approved = item['status'] == 'approved';

                          return Card(
                            color: theme.cardColor,
                            elevation: 2,
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
                                        style: theme.textTheme.titleMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: approved
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
                                      Icon(
                                        Icons.date_range,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${item['from_date']} → ${item['to_date']}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    'Days: ${item['total_days']}',
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    'Reason: ${item['reason']}',
                                    style: theme.textTheme.bodyMedium,
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    'Applied On: ${item['submitted_at']}',
                                    style: theme.textTheme.bodySmall,
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
    final parentContext = context;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Consumer<LeaveRequestProvider>(
          builder: (_, provider, __) {
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
                    Text(
                      'Apply Leave',
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedLeaveType,
                      decoration: _inputDecoration(theme, 'Leave Type'),
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
                      theme: theme,
                      label: 'From Date',
                      controller: fromDateController,
                      onPick: (d) => fromDate = d,
                    ),

                    const SizedBox(height: 12),

                    _boxedDateField(
                      theme: theme,
                      label: 'To Date',
                      controller: toDateController,
                      onPick: (d) => toDate = d,
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: _inputDecoration(theme, 'Reason'),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
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
                                  Navigator.pop(sheetContext);

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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
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

  InputDecoration _inputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
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

  Widget _boxedDateField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    required Function(DateTime) onPick,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: _inputDecoration(theme, label).copyWith(
        suffixIcon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
      ),
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
