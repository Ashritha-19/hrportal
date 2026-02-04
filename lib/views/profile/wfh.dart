// ignore_for_file: deprecated_member_use, use_build_context_synchronously

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

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Work From Home Requests",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
                ? const Center(child: Text("No WFH Requests"))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: provider.wfhList.length,
                    itemBuilder: (context, index) {
                      return _wfhCard(provider.wfhList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _wfhCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Date Range", "${item['from_date']} - ${item['to_date']}"),
          _infoRow(
            "Status",
            item['status'],
            valueWidget: _statusChip(item['status']),
          ),
          _infoRow("Applied On", item['created_at']),
          _infoRow(
            "Admin Remarks",
            item['admin_remarks']?.toString().isEmpty ?? true
                ? "-"
                : item['admin_remarks'],
          ),
          _infoRow("Reason", item['reason'], isLast: true),
        ],
      ),
    );
  }

  Widget _infoRow(
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(child: valueWidget ?? Text(value)),
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
      backgroundColor: color.withOpacity(0.1),
    );
  }

  void _openRequestWfhSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Consumer<WfhProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dateField("From Date", _fromDate, () async {
                    _fromDate = await _pickDate();
                    setState(() {});
                  }),
                  const SizedBox(height: 10),
                  _dateField("To Date", _toDate, () async {
                    _toDate = await _pickDate();
                    setState(() {});
                  }),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Reason",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: provider.isSubmitting ? null : _submitWfhRequest,
                    child: provider.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit Request"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dateField(String label, DateTime? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value == null
              ? "Select date"
              : "${value.year}-${value.month}-${value.day}",
        ),
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
