// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:hrportal/service/dashboardservice.dart';
import 'package:hrportal/service/profile/theme.dart';

import 'package:hrportal/views/profile/attendance.dart';
import 'package:hrportal/views/profile/leaveReq.dart';
import 'package:hrportal/views/profile/overTimeReq.dart';
import 'package:hrportal/views/profile/payslips.dart';
import 'package:hrportal/views/profile/wfh.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const double avatarRadius = 65;
  static const double whiteContainerRatio = 0.75;
  static const double curveRadius = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final employee = dashboard.dashboardData?["employee"];

    final screenHeight = MediaQuery.of(context).size.height;
    final double whiteContainerTop = screenHeight * (1 - whiteContainerRatio);

    return SizedBox(
      height: screenHeight,
      child: Stack(
        children: [
          /// ================= GRADIENT =================
          Container(
            height: whiteContainerTop,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4A6CF7),
                  Color(0xFF6C63FF),
                  Color(0xFF9B7CFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// ================= WHITE CONTAINER =================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * whiteContainerRatio,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(curveRadius),
                  topRight: Radius.circular(curveRadius),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                child: Column(
                  children: [
                    /// ================= NAME =================
                    Text(
                      employee?["name"] ?? "—",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// ================= DESIGNATION =================
                    Text(
                      employee?["designation"] ?? "—",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    _InfoRow(
                      Icons.badge_outlined,
                      "Employee ID : ${employee?["code"] ?? "—"}",
                    ),

                    const SizedBox(height: 6),

                    _InfoRow(
                      Icons.phone_android,
                      "Mobile : ${employee?["phone"] ?? "—"}",
                    ),

                    const SizedBox(height: 6),

                    _InfoRow(
                      Icons.email_outlined,
                      "Email : ${employee?["email"] ?? "—"}",
                    ),

                    const SizedBox(height: 30),

                    /// ================= ACTION SECTION =================
                    _sectionCard([
                      _menuTile(
                        Icons.home_work_outlined,
                        "Attendance",
                        const AttendanceScreen(),
                      ),
                      _menuTile(
                        Icons.receipt_long_outlined,
                        "Leave Requests",
                        const LeaveRequestsScreen(),
                      ),
                      _menuTile(
                        Icons.home_work_outlined,
                        "Work From Home",
                        const WfhScreen(),
                      ),
                      _menuTile(
                        Icons.receipt_long_outlined,
                        "Over Time Requests",
                        const OvertimeRequestsScreen(),
                      ),
                      _menuTile(
                        Icons.receipt_long_outlined,
                        "Payslips",
                        const PayslipsScreen(),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    /// ================= LOGOUT =================
                    _logoutCard(),
                  ],
                ),
              ),
            ),
          ),

          /// ================= PROFILE IMAGE =================
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: const Color(0xFFEDE7FF),
                      backgroundImage: employee?["profile_image"] != null
                          ? NetworkImage(employee["profile_image"])
                          : const AssetImage("assets/profile.png")
                              as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Color(0xFF4A6CF7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🌗 ================= THEME TOGGLE BUTTON =================
          Positioned(
            top: 16,
            right: 16,
            child: Consumer<ThemeProvider>(
              builder: (_, theme, __) {
                return IconButton(
                  icon: Icon(
                    theme.isDark ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: theme.toggleTheme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION CARD =================

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _menuTile(IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Get.to(destination),
    );
  }

  Widget _logoutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.power_settings_new, color: Colors.red),
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        onTap: () {},
      ),
    );
  }
}

// ================= REUSABLE =================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}
