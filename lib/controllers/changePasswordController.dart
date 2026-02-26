import 'package:get/get.dart';
import 'package:school_management_system/controllers/authController.dart';
import '../services/api_services.dart';


class ChangePasswordController extends GetxController {
  static ChangePasswordController get to => Get.find();

  // Observables
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var successMessage = "".obs;

  // Text field values
  var studentId = "".obs;
  var newPassword = "".obs;
  var confirmPassword = "".obs;

  // Change password function
  Future<void> changePassword() async {
    // Clear previous messages
    errorMessage.value = "";
    successMessage.value = "";

    // Validation
    if (studentId.value.isEmpty ||
        newPassword.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      errorMessage.value = "Please fill all fields";
      return;
    }

    if (newPassword.value != confirmPassword.value) {
      errorMessage.value = "Passwords do not match";
      return;
    }

    isLoading.value = true;

    try {
      // Call POST API
      final response = await ApiService.postRequest(
        endpoint: "Auth/Update-Password",
        body: {
          "studentId": studentId.value,
          "newPassword": newPassword.value,
        },
        token: AuthController.to.token, // optional, include if API requires token
      );

      isLoading.value = false;
      successMessage.value =
          response["message"] ?? "Password updated successfully";
          
      // Clear password fields
      newPassword.value = "";
      confirmPassword.value = "";
      studentId.value = "";

    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }
}