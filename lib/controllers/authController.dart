import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import '../services/api_services.dart';

class AuthController extends GetxController {
  // 🔥 Allows AuthController.to
  static AuthController get to => Get.find();

  // ============================
  // Observables
  // ============================
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var rememberMe = false.obs;

  // ============================
  // In-memory variables
  // ============================
  String token = "";
  String studentId = "";

  // ============================
  // Secure Storage
  // ============================
  final storage = const FlutterSecureStorage();

  // ============================
  // Save token and decode studentId
  // ============================
  Future<void> saveToken(String newToken) async {
    token = newToken;
    await storage.write(key: "token", value: newToken);

    // Decode token to get studentId
    Map<String, dynamic> decoded = JwtDecoder.decode(newToken);
    studentId = decoded["UserId"] ?? "";
    print("STUDENT ID FROM TOKEN → $studentId");
  }

  Future<void> loadToken() async {
    final storedToken = await storage.read(key: "token");
    if (storedToken != null && storedToken.isNotEmpty) {
      token = storedToken;
      Map<String, dynamic> decoded = JwtDecoder.decode(storedToken);
      studentId = decoded["UserId"] ?? "";
    }
  }

  // ============================
  // Save/Get UserID (Remember Me)
  // ============================
  Future<void> saveUserID(String userID) async {
    await storage.write(key: "userID", value: userID);
  }

  Future<String?> getSavedUserID() async {
    return await storage.read(key: "userID");
  }

  // ============================
  // Check login status
  // ============================
  Future<bool> checkLoginStatus() async {
    await loadToken();
    return token.isNotEmpty;
  }

  // ============================
  // LOGIN
  // ============================
  Future<bool> login(String userName, String password) async {
  isLoading.value = true;
  errorMessage.value = "";

  try {
    final body = {"userName": userName, "password": password};
    final response = await ApiService.postRequest(
      endpoint: "Auth/Login",
      body: body,
    );

    isLoading.value = false;

    String? extractedToken;

    // Check all possible places where token might be
    if (response["token"] != null) {
      extractedToken = response["token"];
    } else if (response["data"] != null &&
        response["data"]["token"] != null) {
      extractedToken = response["data"]["token"];
    } else if (response["student"] != null &&
        response["student"]["res"] != null &&
        response["student"]["res"]["token"] != null) {
      extractedToken = response["student"]["res"]["token"];
    }

    if (extractedToken == null || extractedToken.isEmpty) {
      errorMessage.value = "Login failed. Token not found.";
      return false;
    }

    // 🔹 Save token first
    await saveToken(extractedToken);

    // Save userID if Remember Me
    if (rememberMe.value) {
      await saveUserID(userName);
    }
    
    return true;
  } catch (e) {
    isLoading.value = false;
    errorMessage.value = e.toString();
    return false;
  }
}
  // ============================
  // REGISTER
  // ============================
  

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    token = "";
    studentId = "";
    await storage.delete(key: "token");
    await storage.delete(key: "userID");

    Get.offAllNamed("/login");
  }
}