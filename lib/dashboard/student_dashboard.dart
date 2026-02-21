import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/NoticesScreen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/admitcardScreen.dart';

import 'package:school_management_system/dashboard/Drawer_Screens/attendance_screen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/compositeMarksheetScreen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/profile_screen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/singleMarksheetScreen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/student_fee_screen.dart';

import 'package:school_management_system/dashboard/sections/dashboard_cards_row/dashboard_cards_row.dart';
import 'package:school_management_system/dashboard/sections/noticesSection.dart';
import 'package:school_management_system/dashboard/sections/userIDSection.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/theme_controller.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> spClear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text('Student Dashboard'),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () {
                themeController.toggleTheme();
              },
              icon: Icon(
                themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              tooltip: themeController.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
          ),
          TextButton(
            onPressed: () async {
              await spClear();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SigninScreen()),
                );
              }
            },
            child: Text(
              "Sign out",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      drawer: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      "S",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Student Name",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "student@email.com",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            _buildDrawerItem(
              context,
              icon: LucideIcons.user,
              title: "Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: LucideIcons.checkCircle,
              title: "Attendance",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendanceScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: LucideIcons.bookOpen,
              title: "Academic Progress",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MarksheetScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: LucideIcons.table,
              title: "Composite Marksheet",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompositeMarksheetScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: LucideIcons.wallet,
              title: "Fee Details",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentFeeScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: LucideIcons.bell,
              title: "Notices",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NoticesScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: LucideIcons.contact,
              title: "Admit Card",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdmitCardScreen()),
                );
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // User ID Section
                UserIDSection(),
                SizedBox(height: 24),

                // Notices Section
                NoticesSection(),
                SizedBox(height: 24),

                // Dashboard Cards Row
                DashboardCardsRow(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}
