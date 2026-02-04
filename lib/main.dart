import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrportal/constants/approutes.dart';
import 'package:hrportal/service/dashboardservice.dart';
import 'package:hrportal/service/loginservice.dart';
import 'package:hrportal/service/profile/leaveReqService.dart';
import 'package:hrportal/service/profile/overTimeService.dart';
import 'package:hrportal/service/profile/payslipsservice.dart';
import 'package:hrportal/service/report/projectservice.dart';
import 'package:hrportal/service/report/reportservice.dart';
import 'package:hrportal/service/report/submitreportservice.dart';
import 'package:hrportal/service/tasksService.dart';
import 'package:hrportal/service/profile/wfhservice.dart';
import 'package:hrportal/service/report/worktypeservice.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => ProjectsProvider()),
        ChangeNotifierProvider(create: (_) => WorkTypesProvider()),
        ChangeNotifierProvider(create: (_) => SubmitReportProvider()),
        ChangeNotifierProvider(create: (_) => WfhProvider()),
        ChangeNotifierProvider(create: (_) => PayslipProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => LeaveRequestProvider()),
        ChangeNotifierProvider(create: (_) => OvertimeProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Parivartan',
        theme: ThemeData.light(),

        /// 🔑 IMPORTANT
        initialRoute: AppRoutes.login,
        getPages: AppPages.routes,
      ),
    );
  }
}
