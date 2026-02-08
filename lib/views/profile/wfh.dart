// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/service/profile/wfhservice.dart';

class WfhScreen extends StatefulWidget {
  const WfhScreen({super.key});

  @override
  State<WfhScreen> createState() => _WfhScreenState();
}

class _WfhScreenState extends State<WfhScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WfhProvider>().fetchWfhRequests();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WfhProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text(
          "Work From Home Requests",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  _resetForm();
                  _openRequestWfhSheet();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Request Work From Home",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.wfhList.isEmpty
                ? Center(
                    child: Text(
                      "No WFH Requests",
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: provider.wfhList.length,
                    itemBuilder: (_, index) {
                      return _wfhCard(theme, provider.wfhList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _wfhCard(ThemeData theme, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            theme,
            "Date Range",
            "${item['from_date']} - ${item['to_date']}",
          ),
          _infoRow(
            theme,
            "Status",
            item['status'],
            valueWidget: _statusChip(item['status']),
          ),
          _infoRow(theme, "Applied On", item['created_at']),
          _infoRow(
            theme,
            "Admin Remarks",
            item['admin_remarks']?.toString().isEmpty ?? true
                ? "-"
                : item['admin_remarks'],
          ),
          _infoRow(theme, "Reason", item['reason'], isLast: true),
        ],
      ),
    );
  }

  Widget _infoRow(
    ThemeData theme,
    String label,
    String value, {
    Widget? valueWidget,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
      child: Row(
        children: [
          SizedBox(
            width: 115,
            child: Text(
              "$label :",
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: valueWidget ?? Text(value, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = status == "approved"
        ? Colors.green
        : status == "rejected"
        ? Colors.red
        : Colors.orange;

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.15),
    );
  }

  void _openRequestWfhSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Consumer<WfhProvider>(
        builder: (_, provider, __) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dateField(theme, "From Date", _fromDate, () async {
                    _fromDate = await _pickDate();
                    setState(() {});
                  }),
                  const SizedBox(height: 10),
                  _dateField(theme, "To Date", _toDate, () async {
                    _toDate = await _pickDate();
                    setState(() {});
                  }),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: _inputDecoration(theme, "Reason"),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isSubmitting
                          ? null
                          : _submitWfhRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: provider.isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Submit Request"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dateField(
    ThemeData theme,
    String label,
    DateTime? value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDecoration(theme, label),
        child: Text(
          value == null
              ? "Select date"
              : "${value.year}-${value.month}-${value.day}",
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
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
    );
  }

  Future<DateTime?> _pickDate() {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  void _submitWfhRequest() async {
    if (_fromDate == null || _toDate == null) {
      _showSnack("Select date range");
      return;
    }

    final success = await context.read<WfhProvider>().submitWfhRequest(
      fromDate:
          "${_fromDate!.year}-${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.day.toString().padLeft(2, '0')}",
      toDate:
          "${_toDate!.year}-${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.day.toString().padLeft(2, '0')}",
      reason: _reasonController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      _showSnack("WFH request submitted");
      _resetForm();
    }
  }

  void _resetForm() {
    _fromDate = null;
    _toDate = null;
    _reasonController.clear();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
