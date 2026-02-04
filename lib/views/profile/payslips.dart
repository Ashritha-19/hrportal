// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrportal/service/profile/payslipsservice.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayslipsScreen extends StatefulWidget {
  const PayslipsScreen({super.key});

  @override
  State<PayslipsScreen> createState() => _PayslipsScreenState();
}

class _PayslipsScreenState extends State<PayslipsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PayslipProvider>().fetchPayslips();
    });
  }

  String formatMonthYear(String value) {
    final parts = value.split("-");
    return "${_monthName(parts[1])} ${parts[0]}";
  }

  String _monthName(String month) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[int.parse(month)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payslips",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<PayslipProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.payslips.isEmpty) {
            return const Center(child: Text("No payslips available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.payslips.length,
            itemBuilder: (context, index) {
              final payslip = provider.payslips[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatMonthYear(payslip['month_year']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Uploaded on ${payslip['uploaded_at'].split(" ")[0]}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token');

                            final String url = payslip['file_url'];
                            debugPrint("⬇️ DOWNLOAD URL => $url");

                            final response = await http.get(
                              Uri.parse(url),
                              headers: {"Authorization": "Bearer $token"},
                            );

                            debugPrint(
                              "📄 FILE STATUS => ${response.statusCode}",
                            );
                            debugPrint(
                              "📄 FILE BYTES => ${response.bodyBytes.length}",
                            );

                            if (response.statusCode == 200 &&
                                response.bodyBytes.isNotEmpty) {
                              final dir =
                                  await getApplicationDocumentsDirectory();

                              final fileName = Uri.decodeFull(
                                url.split('/').last,
                              ); // IMPORTANT
                              final file = File("${dir.path}/$fileName");

                              await file.writeAsBytes(response.bodyBytes);

                              await OpenFilex.open(file.path);
                            } else {
                              throw "Empty or invalid file";
                            }
                          } catch (e) {
                            debugPrint("❌ DOWNLOAD ERROR => $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Unable to download payslip"),
                              ),
                            );
                          }
                        },

                        icon: const Icon(
                          Icons.download,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Download",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
}
