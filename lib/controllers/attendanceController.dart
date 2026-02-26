import 'package:get/get.dart';
import 'package:school_management_system/controllers/authController.dart';
import '../services/api_services.dart';

class AttendanceController extends GetxController {
  static AttendanceController get to => Get.find();

  var isLoading = false.obs;
  var attendanceData = <Map<String, dynamic>>[].obs;
  var errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      // Get token and studentId from AuthController
      final token = AuthController.to.token;
      final studentId = AuthController.to.studentId; // ✅ This is the key

      // Make sure studentId is not empty
      if (studentId.isEmpty) {
        throw Exception("Student ID not found. Please login again.");
      }

      // Call API with studentId as query parameter
      final response = await ApiService.getRequest(
        endpoint: "Attendance/dashboard?student_id=$studentId",
        token: token,
      );

      // API returns a list
      attendanceData.value =
          (response as List).map((e) => e as Map<String, dynamic>).toList();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }
}