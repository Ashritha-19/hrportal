import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrportal/service/profile/editProfileService.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/constants/approutes.dart';
import 'package:hrportal/service/loginservice.dart';
import 'package:hrportal/service/dashboardservice.dart';
import 'package:hrportal/service/profile/theme.dart';
import 'package:hrportal/service/profile/attendanceService.dart';
import 'package:hrportal/service/profile/leaveReqService.dart';
import 'package:hrportal/service/profile/overTimeService.dart';
import 'package:hrportal/service/profile/payslipsservice.dart';
import 'package:hrportal/service/profile/wfhservice.dart';
import 'package:hrportal/service/tasksService.dart';
import 'package:hrportal/service/report/projectservice.dart';
import 'package:hrportal/service/report/reportservice.dart';
import 'package:hrportal/service/report/submitreportservice.dart';
import 'package:hrportal/service/report/worktypeservice.dart';

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
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],

      /// 👇 IMPORTANT PART
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Parivartan',

            /// 🌗 Theme handling
            themeMode: themeProvider.themeMode,

            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF2F4F8),
              primaryColor: const Color(0xFF4A6CF7),
              cardColor: Colors.white,
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              primaryColor: const Color(0xFF4A6CF7),
            ),

            initialRoute: AppRoutes.login,
            getPages: AppPages.routes,
          );
        },
      ),
    );
  }
}
