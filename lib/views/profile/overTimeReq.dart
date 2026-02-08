// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/service/profile/overTimeService.dart';
import 'package:hrportal/service/report/projectservice.dart';
import 'package:hrportal/service/report/worktypeservice.dart';

class OvertimeRequestsScreen extends StatefulWidget {
  const OvertimeRequestsScreen({super.key});

  @override
  State<OvertimeRequestsScreen> createState() => _OvertimeRequestsScreenState();
}

class _OvertimeRequestsScreenState extends State<OvertimeRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OvertimeProvider>().fetchOvertime();
      context.read<ProjectsProvider>().fetchProjects();
      context.read<WorkTypesProvider>().fetchWorkTypes();
    });
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
          "Over Time Requests",
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
      body: Consumer<OvertimeProvider>(
        builder: (_, provider, __) {
          return Column(
            children: [
              /// REQUEST BUTTON
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openRequestCard(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Overtime Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              /// LIST
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.overtimeList.isEmpty
                    ? Center(
                        child: Text(
                          'No Overtime Data',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.overtimeList.length,
                        itemBuilder: (_, index) {
                          final item = provider.overtimeList[index];

                          return Card(
                            color: theme.cardColor,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['ot_date'] ?? '-',
                                        style: theme.textTheme.titleMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      _statusChip(item['status']),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _infoRow(theme, 'Type', item['ot_type']),
                                  _infoRow(
                                    theme,
                                    'Project',
                                    item['project_name'],
                                  ),
                                  _infoRow(
                                    theme,
                                    'Hours',
                                    '${item['ot_hours']} hrs',
                                  ),
                                  _infoRow(theme, 'Reason', item['reason']),
                                  _infoRow(
                                    theme,
                                    'Admin Remark',
                                    (item['admin_remarks'] == null ||
                                            item['admin_remarks']
                                                .toString()
                                                .isEmpty)
                                        ? '-'
                                        : item['admin_remarks'],
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

  // ======================================================
  // REQUEST OVERTIME BOTTOM SHEET
  // ======================================================
  void _openRequestCard(BuildContext context) {
    final theme = Theme.of(context);

    String? selectedOtType;
    String? selectedWorkType;
    Map<String, dynamic>? selectedProject;
    DateTime selectedDate = DateTime.now();

    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Request Overtime',
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// DATE
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration(theme, 'Date'),
                        child: Text(
                          selectedDate.toString().split(' ')[0],
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// WORK TYPE
                    Consumer<WorkTypesProvider>(
                      builder: (_, wp, __) {
                        return DropdownButtonFormField<String>(
                          decoration: _inputDecoration(theme, 'Work Type'),
                          items: wp.workTypes
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) => selectedWorkType = val,
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    /// OT TYPE
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration(theme, 'Overtime Category'),
                      items: const [
                        DropdownMenuItem(
                          value: 'weekend',
                          child: Text('Weekend Work'),
                        ),
                        DropdownMenuItem(
                          value: 'holiday',
                          child: Text('Public Holiday Work'),
                        ),
                        DropdownMenuItem(
                          value: 'night',
                          child: Text('Night Work'),
                        ),
                        DropdownMenuItem(
                          value: 'outside_hours',
                          child: Text('Outside Office Hours'),
                        ),
                      ],
                      onChanged: (val) => selectedOtType = val,
                    ),

                    const SizedBox(height: 12),

                    /// PROJECT
                    Consumer<ProjectsProvider>(
                      builder: (_, pp, __) {
                        return DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: _inputDecoration(theme, 'Project'),
                          items: pp.projects
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p['name']),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => selectedProject = val,
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    /// HOURS & MINUTES
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: hoursController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(theme, 'Hours (0–23)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: minutesController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              theme,
                              'Minutes (0–59)',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// REASON
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: _inputDecoration(theme, 'Reason'),
                    ),

                    const SizedBox(height: 16),

                    /// SUBMIT
                    Consumer<OvertimeProvider>(
                      builder: (_, op, __) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: op.isSubmitting
                                ? null
                                : () async {
                                    final hrs =
                                        int.tryParse(hoursController.text) ?? 0;
                                    final mins =
                                        int.tryParse(minutesController.text) ??
                                        0;

                                    final totalHours = hrs + (mins / 60);

                                    final success = await op.submitOvertime(
                                      otDate: selectedDate.toString().split(
                                        ' ',
                                      )[0],
                                      otHours: totalHours.toStringAsFixed(2),
                                      reason: reasonController.text,
                                      projectId: selectedProject!['id'],
                                      otType: selectedOtType!,
                                      workType: selectedWorkType!,
                                    );

                                    if (success) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Overtime request submitted successfully',
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
                            child: op.isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Submit Request'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ======================================================
  // UI HELPERS
  // ======================================================
  Widget _infoRow(ThemeData theme, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label :',
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: theme.textTheme.bodySmall!.copyWith(
                fontStyle: (value == null || value == '-')
                    ? FontStyle.italic
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        (status ?? '').toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
