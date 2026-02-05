// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

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
    final theme = Theme.of(context);

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.dashboardData == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Session expired. Please login again.",
            style: theme.textTheme.bodyMedium,
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text("Dashboard", style: theme.textTheme.titleMedium),
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileCard(employee, theme),
            const SizedBox(height: 12),

            Row(
              children: [
                _clockCard(provider, theme),
                const SizedBox(width: 12),
                _infoCard(
                  theme,
                  "Shift Timings",
                  "10:30 AM - 7:00 PM",
                  Icons.access_time,
                  sub: "8 hrs 30 mins",
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _infoCard(
                  theme,
                  "First Login Today",
                  attendance["check_in"] ?? "--",
                  Icons.login,
                ),
                const SizedBox(width: 12),
                _infoCard(
                  theme,
                  "Leave Balance",
                  "${data["leave_balance"]} Days",
                  Icons.event_available,
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (holidays.isNotEmpty) _upcomingHolidays(holidays, theme),
            const SizedBox(height: 12),
            if (birthdays.isNotEmpty) _upcomingBirthdays(birthdays, theme),
          ],
        ),
      ),
    );
  }

  /// ⏱ CLOCK CARD
  Widget _clockCard(DashboardProvider provider, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(theme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Work Time", style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              provider.format(provider.workedDuration),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: provider.toggleClock,
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isClockedIn
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              child: const Text("Toggle"),
            ),
          ],
        ),
      ),
    );
  }

  /// 👤 PROFILE CARD
  Widget _profileCard(Map employee, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(theme),
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
              Text(employee["name"], style: theme.textTheme.titleMedium),
              Text(employee["designation"], style: theme.textTheme.bodySmall),
              Text(employee["team_name"], style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎉 UPCOMING HOLIDAYS
  Widget _upcomingHolidays(List holidays, ThemeData theme) {
    return Container(
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              "Upcoming Holidays",
              style: theme.textTheme.titleMedium,
            ),
          ),
          Divider(color: theme.dividerColor),
          ...holidays.map(
            (holiday) => ListTile(
              leading: Icon(
                Icons.beach_access,
                color: theme.colorScheme.primary,
              ),
              title: Text(holiday["title"].trim()),
              subtitle: Text(holiday["holiday_date"]),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎂 UPCOMING BIRTHDAYS
  Widget _upcomingBirthdays(List birthdays, ThemeData theme) {
    return Container(
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              "Upcoming Birthdays",
              style: theme.textTheme.titleMedium,
            ),
          ),
          Divider(color: theme.dividerColor),
          ...birthdays.map(
            (b) => ListTile(
              leading: Icon(Icons.cake, color: theme.colorScheme.primary),
              title: Text(b["empName"]),
              subtitle: Text(b["empDob"]),
            ),
          ),
        ],
      ),
    );
  }

  /// ℹ️ INFO CARD
  Widget _infoCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon, {
    String? sub,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(theme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(title, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: theme.textTheme.titleMedium),
            if (sub != null) Text(sub, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(ThemeData theme) => BoxDecoration(
    color: theme.cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: theme.shadowColor.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}


 