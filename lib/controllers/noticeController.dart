/* import 'package:get/get.dart';
import 'package:school_management_system/models/noticesModel.dart';
import 'package:school_management_system/services/api_services.dart';
import 'package:school_management_system/controllers/authController.dart';

class NoticesController extends GetxController {
  var notices = <NoticeModel>[].obs;
  var isLoading = false.obs;

  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    fetchNoticesApi();
  }

  Future<void> fetchNoticesApi() async {
    isLoading.value = true;

    try {
      final token = AuthController.to.token;

      if (token.isEmpty) {
        Get.snackbar("Error", "You are not logged in",
            snackPosition: SnackPosition.BOTTOM);
        notices.value = [];
        return;
      }

      final response = await ApiService.getRequest(
        endpoint: "Notice/Get-Notices",
        token: token,
      );

      List<NoticeModel> apiData = [];

      if (response is List) {
        apiData =
            response.map((json) => NoticeModel.fromJson(json)).toList();
      } else if (response is Map && response["data"] != null) {
        apiData =
            (response["data"] as List)
                .map((json) => NoticeModel.fromJson(json))
                .toList();
      }

      // ============================
      // 1️⃣ SORT DESCENDING (Latest First)
      // ============================
      apiData.sort((a, b) => b.date.compareTo(a.date));

      // ============================
      // 2️⃣ MARK AS NEW IF WITHIN LAST 7 DAYS
      // ============================
      final now = DateTime.now();

      for (var notice in apiData) {
        final difference = now.difference(notice.date).inDays;
        notice.isNew = difference <= 7;
      }

      notices.value = apiData;

    } catch (e) {
      notices.value = [];
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotices() async {
    await fetchNoticesApi();
  }
} */ 
import 'package:get/get.dart';
import 'package:school_management_system/models/noticesModel.dart';
import 'package:school_management_system/services/api_services.dart';
import 'package:school_management_system/controllers/authController.dart';

class NoticesController extends GetxController {
  // Observable list of notices
  var notices = <NoticeModel>[].obs;
  var isLoading = false.obs;

  final AuthController authController = Get.find<AuthController>();

 @override
void onInit() async {
  super.onInit();
  // Ensure we have a token before fetching
  if (authController.token.isEmpty) {
    await authController.loadToken(); 
  }
  fetchNoticesApi();
}

  Future<void> fetchNoticesApi() async {
  isLoading.value = true;

  try {
    // 1. Double check token from storage if memory is empty
    if (authController.token.isEmpty) {
      await authController.loadToken();
    }

    final token = authController.token;

    if (token.isEmpty) {
      print("❌ Error: Token is still empty after loading attempt");
      isLoading.value = false;
      return;
    }

    // 2. Fetch data
    final response = await ApiService.getRequest(
      endpoint: "Notice/Get-Notices",
      token: token,
    );

      print("🔹 Raw API response → $response");

      List<NoticeModel> apiData = [];

      // Handle response if it's a List
      if (response is List) {
        apiData =
            response.map((json) => NoticeModel.fromJson(json)).toList();
      }
      // Handle response if it's a Map with 'data'
      else if (response is Map && response["data"] != null) {
        apiData =
            (response["data"] as List)
                .map((json) => NoticeModel.fromJson(json))
                .toList();
      }

      print("🔹 Parsed notices → ${apiData.map((e) => e.title).toList()}");

      // Sort descending by date (latest first)
      apiData.sort((a, b) => b.date.compareTo(a.date));

      // Mark as NEW if within last 7 days
      final now = DateTime.now();
      for (var notice in apiData) {
        final difference = now.difference(notice.date).inDays;
        notice.isNew = difference <= 7;
      }

      notices.value = apiData;
    } catch (e) {
      notices.value = [];
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pull-to-refresh
  Future<void> refreshNotices() async {
    await fetchNoticesApi();
  }
}