// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/service/profile/editProfileService.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController firstNameCtrl;
  late TextEditingController middleNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController contactCtrl;
  late TextEditingController currentAddrCtrl;
  late TextEditingController permAddrCtrl;

  @override
  void initState() {
    super.initState();
    print('🟡 EditProfileScreen initState');

    final provider = Provider.of<ProfileProvider>(context, listen: false);

    provider.fetchProfile().then((_) {
      firstNameCtrl = TextEditingController(text: provider.firstName);
      middleNameCtrl = TextEditingController(text: provider.middleName);
      lastNameCtrl = TextEditingController(text: provider.lastName);
      emailCtrl = TextEditingController(text: provider.email);
      contactCtrl = TextEditingController(text: provider.contact);
      currentAddrCtrl = TextEditingController(text: provider.currentAddress);
      permAddrCtrl = TextEditingController(text: provider.permanentAddress);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final theme = Theme.of(context);

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text(
          "Edit Profile",
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 👤 First, Middle, Last Name (ONE ROW)
          Row(
            children: [
              Expanded(child: _field(theme, 'First Name', firstNameCtrl)),
              const SizedBox(width: 10),
              Expanded(child: _field(theme, 'Middle Name', middleNameCtrl)),
              const SizedBox(width: 10),
              Expanded(child: _field(theme, 'Last Name', lastNameCtrl)),
            ],
          ),

          /// 📧 Email (READ ONLY)
          _field(theme, 'Email', emailCtrl, readOnly: true),

          _field(theme, 'Contact Number', contactCtrl),

          _field(theme, 'Current Address', currentAddrCtrl, maxLines: 3),

          _field(theme, 'Permanent Address', permAddrCtrl, maxLines: 3),

          const SizedBox(height: 24),

          /// ✅ SAVE BUTTON (GREEN)
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: provider.isUpdating
                  ? null
                  : () async {
                      final success = await provider.updateProfile(
                        firstName: firstNameCtrl.text.trim(),
                        middleName: middleNameCtrl.text.trim(),
                        lastName: lastNameCtrl.text.trim(),
                        contact: contactCtrl.text.trim(),
                        currentAddr: currentAddrCtrl.text.trim(),
                        permanentAddr: permAddrCtrl.text.trim(),
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? '✅ Profile updated successfully'
                                : '❌ Failed to update profile',
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );

                      if (success) Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: provider.isUpdating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INPUT FIELD =================

  Widget _field(
    ThemeData theme,
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        style: theme.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: readOnly
              ? theme.colorScheme.surfaceVariant
              : theme.cardColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
