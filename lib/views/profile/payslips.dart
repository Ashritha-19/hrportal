// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/service/profile/payslipsservice.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text(
          "My Payslips",
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
      body: Consumer<PayslipProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.payslips.isEmpty) {
            return Center(
              child: Text(
                "No payslips available",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.payslips.length,
            itemBuilder: (_, index) {
              final payslip = provider.payslips[index];

              return Card(
                color: theme.cardColor,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// LEFT SIDE
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatMonthYear(payslip['month_year']),
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Uploaded on ${payslip['uploaded_at'].split(" ")[0]}",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),

                      /// DOWNLOAD BUTTON
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
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

                            if (response.statusCode == 200 &&
                                response.bodyBytes.isNotEmpty) {
                              final dir =
                                  await getApplicationDocumentsDirectory();

                              final fileName = Uri.decodeFull(
                                url.split('/').last,
                              );

                              final file = File("${dir.path}/$fileName");

                              await file.writeAsBytes(response.bodyBytes);

                              await OpenFilex.open(file.path);
                            } else {
                              throw "Invalid file";
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
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text(
                          "Download",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
