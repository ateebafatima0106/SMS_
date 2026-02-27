import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/controllers/attendanceController.dart';
import 'package:school_management_system/controllers/authController.dart';
import 'package:school_management_system/controllers/compositeMarksheetController.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/controllers/singleMarksheetController.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/singleMarksheetScreen.dart';
import 'controllers/theme_controller.dart';
import 'package:school_management_system/splashscreen.dart';
import 'theme/app_theme.dart';

void main() {
  Get.put(AdmitCardController());
  Get.put(CompositeMarksheetController());
  //Get.put(MarksheetController());
  Get.put(ThemeController());
  Get.put(NoticesController());
  Get.put(StudentFeeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'School Management System',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        home: const SplashScreen(),
      ),
    );
  }
}
