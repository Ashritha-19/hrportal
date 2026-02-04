// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/service/dashboardservice.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.dashboardData == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Session expired. Please login again.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final data = provider.dashboardData!;
    final employee = data["employee"];
    final attendance = data["attendance"];
    final holidays = data["upcoming_holidays"] ?? [];
    final birthdays = data["upcoming_birthdays"] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 👤 PROFILE
            _profileCard(employee),
            const SizedBox(height: 12),

            /// ⏱ CLOCK IN + SHIFT TIMINGS
            Row(
              children: [
                _clockCard(provider),
                const SizedBox(width: 12),
                _infoCard(
                  "Shift Timings",
                  "10:30 AM - 7:00 PM",
                  Icons.access_time,
                  sub: "8 hrs 30 mins",
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 🕘 FIRST LOGIN + LEAVE BALANCE
            Row(
              children: [
                _infoCard(
                  "First Login Today",
                  attendance["check_in"] ?? "--",
                  Icons.login,
                ),
                const SizedBox(width: 12),
                _infoCard(
                  "Leave Balance",
                  "${data["leave_balance"]} Days",
                  Icons.event_available,
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 🎉 UPCOMING HOLIDAYS (LIST – 30 DAYS)
            if (holidays.isNotEmpty) _upcomingHolidays(holidays),

            const SizedBox(height: 12),

            /// 🎂 UPCOMING BIRTHDAYS (LIST – 30 DAYS)
            if (birthdays.isNotEmpty) _upcomingBirthdays(birthdays),
          ],
        ),
      ),
    );
  }

  /// ⏱ CLOCK CARD
  Widget _clockCard(DashboardProvider provider) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Work Time",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              provider.format(provider.workedDuration),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: provider.toggleClock,
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isClockedIn
                    ? Colors.red
                    : Colors.green,
              ),
              child: Text(
                provider.isClockedIn ? "Clock Out" : "Clock In",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 👤 PROFILE CARD
  Widget _profileCard(Map employee) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(employee["profile_image"]),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee["name"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                employee["designation"],
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                employee["team_name"],
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎉 UPCOMING HOLIDAYS LIST
  Widget _upcomingHolidays(List holidays) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              "Upcoming Holidays",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: holidays.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final holiday = holidays[index];
              return ListTile(
                leading: const Icon(Icons.beach_access, color: Colors.blue),
                title: Text(holiday["title"].trim()),
                subtitle: Text(holiday["holiday_date"]),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🎂 UPCOMING BIRTHDAYS LIST
  Widget _upcomingBirthdays(List birthdays) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              "Upcoming Birthdays",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: birthdays.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final birthday = birthdays[index];
              return ListTile(
                leading: const Icon(Icons.cake, color: Colors.blue),
                title: Text(birthday["empName"]),
                subtitle: Text(birthday["empDob"]),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ℹ️ INFO CARD
  Widget _infoCard(String title, String value, IconData icon, {String? sub}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (sub != null)
              Text(
                sub,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
