import 'package:get/get.dart';
import 'package:hrportal/constants/bottomnavigation.dart';
import 'package:hrportal/views/authentication/login.dart';
import 'package:hrportal/views/dailyreport.dart';
import 'package:hrportal/views/dashboard.dart';
import 'package:hrportal/views/profile/profile.dart';
import 'package:hrportal/views/profile/wfh.dart';
import 'package:hrportal/views/task/taskscreen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String reports = '/reports';
  static const String tasks = '/tasks';
  static const String bottomNavigation = '/bottomnavigation';
  static const String profile = '/profile';
  static const String wfh = '/wfh';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsScreen(),
    ),
    GetPage(
      name: AppRoutes.tasks,
      page: () => const TasksScreen(),
    ),
    GetPage(
      name: AppRoutes.bottomNavigation,
      page: () => const BottomNavigation(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.wfh,
      page: () => const WfhScreen(),
    ),
  ];
}