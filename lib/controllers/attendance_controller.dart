import 'package:get/get.dart';
import 'package:school_management_system/models/attendance_model.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart';

/// Controller for Attendance screen.
/// Handles month filtering, API data fetching, and PDF generation state.
class AttendanceController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isGeneratingPdf = false.obs;
  final RxBool isFilterExpanded = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedMonth = 'January'.obs;
  final Rxn<AttendanceResponse> attendanceData = Rxn<AttendanceResponse>();
  final RxList<AttendanceRecord> filteredRecords = <AttendanceRecord>[].obs;

  // Student info for PDF generation
  final RxMap<String, String> studentInfo = <String, String>{}.obs;

  final _api = ApiService();
  final _auth = AuthService();

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = months[DateTime.now().month - 1];
    _loadStudentInfo();
    fetchAttendance();
  }

  Future<void> _loadStudentInfo() async {
    final name = await _auth.getStudentName() ?? '';
    final userData = await _auth.getUserData();
    studentInfo.value = {
      'name': name,
      'rollNo': userData?['rollNo']?.toString() ?? '',
      'fatherName': userData?['father_Name']?.toString() ?? '',
      'class': userData?['classDesc']?.toString() ?? '',
    };
  }

  void toggleFilter() {
    isFilterExpanded.value = !isFilterExpanded.value;
  }

  void setMonth(String month) {
    selectedMonth.value = month;
    fetchAttendance();
  }

  int get presentCount => filteredRecords
      .where((r) => r.status.toUpperCase().startsWith('P'))
      .length;

  int get absentCount => filteredRecords
      .where((r) => r.status.toUpperCase().startsWith('A'))
      .length;

  int get leaveCount => filteredRecords
      .where(
        (r) =>
            r.status.toUpperCase().startsWith('L') ||
            r.status.toUpperCase() == 'LEAVE',
      )
      .length;

  /// Fetch attendance from API for the selected month.
  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final studentId = await _auth.getStudentId();
      if (studentId == null || studentId.isEmpty) {
        errorMessage.value = 'Student ID not found. Please login again.';
        return;
      }

      final monthIndex = months.indexOf(selectedMonth.value) + 1;
      final monthStr = monthIndex.toString().padLeft(2, '0');

      final response = await _api.post(
        '/Attendance/GetAttendance',
        body: {'studentId': studentId, 'month': monthStr},
      );

      if (response is Map<String, dynamic>) {
        if (response.containsKey('message')) {
          errorMessage.value = response['message'];
          attendanceData.value = null;
          filteredRecords.clear();
        } else {
          attendanceData.value = AttendanceResponse.fromJson(response);
          filteredRecords.value = attendanceData.value?.records ?? [];
        }
      } else if (response is List && response.isNotEmpty) {
        final data = AttendanceResponse.fromJson(
          response.first as Map<String, dynamic>,
        );
        attendanceData.value = data;
        filteredRecords.value = data.records;
      } else if (response is String) {
        errorMessage.value = response;
        attendanceData.value = null;
        filteredRecords.clear();
      } else {
        errorMessage.value = 'No attendance records found.';
        attendanceData.value = null;
        filteredRecords.clear();
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      attendanceData.value = null;
      filteredRecords.clear();
    } catch (e) {
      errorMessage.value = 'Failed to load attendance: ${e.toString()}';
      attendanceData.value = null;
      filteredRecords.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get status display string (normalize API codes)
  String normalizeStatus(String rawStatus) {
    switch (rawStatus.toUpperCase().trim()) {
      case 'P':
      case 'PRESENT':
        return 'Present';
      case 'A':
      case 'ABSENT':
        return 'Absent';
      case 'L':
      case 'LATE':
      case 'LEAVE':
        return 'Leave';
      default:
        return rawStatus;
    }
  }
}
