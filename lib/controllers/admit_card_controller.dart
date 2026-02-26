/* import 'package:get/get.dart';
import 'package:school_management_system/models/admitcardModel.dart';


class AdmitCardController extends GetxController {
  final isLoading = false.obs;
  final isGeneratingPdf = false.obs;
  final admitCard = Rxn<AdmitCardModel>();

  @override
  void onInit() {
    super.onInit();
    loadAdmitCard();
  }

  Future<void> loadAdmitCard() async {
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 400));

    admitCard.value = AdmitCardModel(
      schoolName: "BENCHMARK",
      schoolTagline: "School of Leadership",
      schoolSubTagline: "PLAY GROUP TO MATRIC",
      examTitle: "Preliminary Test (Spring) Examination 2025 - 26",
      studentName: "EMAN FATIMA",
      fatherName: "RAFI KHAN",
      className: "GRADE I",
      section: "A",
      admissionNo: "58",
      grNo: "058",
      seatNo: "1",
      logoUrl: null,
      photoUrl: null,
    );

    isLoading.value = false;
  }
} 

// ignore_for_file: file_names

import 'package:get/get.dart';
import '../models/admitcardModel.dart';
import '../services/api_services.dart';

class AdmitCardController extends GetxController {
  final isLoading = false.obs;

  // List of admit cards for UI
  final admitCards = <AdmitCardApiModel >[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdmitCards();
  }

  /// Fetch admit cards from API
  Future<void> fetchAdmitCards() async {
    try {
      isLoading.value = true;

      final response = await ApiService.getAdmitCards();

      // Filter out empty objects
      final List filtered = response.where((e) => e != null && e.isNotEmpty).toList();

      // Map API → UI Model
      final List<> cards = filtered.map((json) {
        final apiModel = AdmitCardApiModel.fromJson(json);
        return AdmitCardModel(
          schoolName: "BENCHMARK",
          schoolTagline: "School of Leadership",
          schoolSubTagline: "PLAY GROUP TO MATRIC",
          examTitle: apiModel.examTypeDesc,
          studentName: apiModel.name.trim(),
          fatherName: apiModel.fatherName.trim(),
          className: apiModel.className,
          section: apiModel.section ?? "",
          admissionNo: apiModel.rollNo.toString(),
          grNo: apiModel.grNo,
          seatNo: apiModel.seatNo.toString(),
          logoUrl: null,
          photoUrl: apiModel.pic,
        );
      }).toList();

      admitCards.assignAll(cards);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Get admit card by selected task and year
  AdmitCardModel? getCardByTaskAndYear(String taskName, int year) {
    try {
      return admitCards.firstWhere(
        (c) => c.examTitle == taskName && c.examTitle.contains(year.toString()),
        orElse: () => admitCards.isNotEmpty ? admitCards.first : null,
      );
    } catch (_) {
      return null;
    }
  }
}  
// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:school_management_system/models/admitcardModel.dart';
import 'package:school_management_system/services/api_services.dart';

class AdmitCardController extends GetxController {
  // --- Observables ---
  final isLoading = false.obs;
  final isGeneratingPdf = false.obs;

  // All admit cards fetched from API
  final allAdmitCards = <AdmitCardModel>[].obs;

  // Tasks from API
  final tasks = <Map<String, dynamic>>[].obs;

  // Years available in API data
  final years = <int>[].obs;

  // Selected filters
  final selectedTaskId = Rxn<int>();
  final selectedYear = Rxn<int>();

  // Filtered admit card for UI/PDF
  final admitCard = Rxn<AdmitCardModel>();

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
    fetchAdmitCards();
  }

  // ----------------------------
  // Fetch all tasks from API
  // ----------------------------
  Future<void> fetchTasks() async {
    try {
      final result = await ApiService.getTasks();
      tasks.assignAll(result.cast<Map<String, dynamic>>());
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  // ----------------------------
  // Fetch all admit cards from API
  // ----------------------------
  Future<void> fetchAdmitCards() async {
    try {
      isLoading.value = true;
      final result = await ApiService.getAdmitCards();

      // Map API data to AdmitCardModel
      final cards = (result as List<dynamic>)
          .where((element) => element != null && element.isNotEmpty)
          .map((json) => AdmitCardModel.fromJson(json))
          .toList();

      allAdmitCards.assignAll(cards);

      // Populate years dropdown dynamically
      final uniqueYears = cards.map((e) => e.year).toSet().toList();
      uniqueYears.sort();
      years.assignAll(uniqueYears);
    } catch (e) {
      print("Error fetching admit cards: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------
  // Filter admit card by selected year & task
  // ----------------------------
  void filterAdmitCard() {
    if (selectedTaskId.value == null || selectedYear.value == null) {
      admitCard.value = null;
      return;
    }

    final filtered = allAdmitCards.firstWhere(
      (card) =>
          card.year == selectedYear.value &&
          card.examTypeDesc == tasks
              .firstWhere((t) => t['taskId'] == selectedTaskId.value)['taskName'],
      orElse: () => null as AdmitCardModel,
    );

    admitCard.value = filtered;
  }
} 

import 'package:get/get.dart';
import 'package:school_management_system/services/api_services.dart';
import '../models/admitcardModel.dart';

class AdmitCardController extends GetxController {
  final isLoading = false.obs;
  final isGeneratingPdf = false.obs;

  // Data storage
  var allAdmitCards = <AdmitCardModel>[].obs;
  var tasks = <Map<String, dynamic>>[].obs;
  var years = <int>[].obs;

  // Selection states
  var selectedYear = Rxn<int>();
  var selectedTaskId = Rxn<int>();
  
  // The card currently displayed in UI
  final admitCard = Rxn<AdmitCardModel>();

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      // 1. Fetch Tasks for the dropdown
      final taskData = await ApiService.getRequest(endpoint: "Marksheet/tasks");
      tasks.value = List<Map<String, dynamic>>.from(taskData);

      // 2. Fetch All Admit Cards
      final cardData = await ApiService.getRequest(endpoint: "AdmitCard");
      allAdmitCards.value = (cardData as List)
          .map((e) => AdmitCardModel.fromJson(e))
          .toList();

      // 3. Extract unique years and sort them
      years.value = allAdmitCards.map((e) => e.year).toSet().toList()..sort((a, b) => b.compareTo(a));
      
    } catch (e) {
      Get.snackbar("Error", "Failed to load data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterAdmitCard() {
    if (selectedYear.value != null && selectedTaskId.value != null) {
      admitCard.value = allAdmitCards.firstWhereOrNull(
        (card) => card.year == selectedYear.value && card.taskId == selectedTaskId.value
      );
    } else {
      admitCard.value = null;
    }
  }
}  

import 'package:get/get.dart';
import 'package:school_management_system/controllers/authController.dart';
import 'package:school_management_system/models/admitcardModel.dart';
import '../services/api_services.dart';

class AdmitCardController extends GetxController {
  final isLoading = false.obs;
  final isGeneratingPdf = false.obs;

  var allAdmitCards = <AdmitCardModel>[].obs;
  var tasks = <Map<String, dynamic>>[].obs;
  var years = <int>[].obs;

  var selectedYear = Rxn<int>();
  var selectedTaskId = Rxn<int>();
  final admitCard = Rxn<AdmitCardModel>();

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      // Use the token from your AuthController
      String authToken = AuthController.to.token;

      // 1. Fetch Tasks
      final taskData = await ApiService.getRequest(
        endpoint: "Marksheet/tasks", 
        token: authToken
      );
      tasks.assignAll(List<Map<String, dynamic>>.from(taskData));

      // 2. Fetch Admit Cards
      final cardData = await ApiService.getRequest(
        endpoint: "AdmitCard", 
        token: authToken
      );
      allAdmitCards.assignAll((cardData as List).map((e) => AdmitCardModel.fromJson(e)).toList());

      // 3. Extract unique years for dropdown
      years.assignAll(allAdmitCards.map((e) => e.year).toSet().toList()..sort((a, b) => b.compareTo(a)));
      
    } catch (e) {
      Get.snackbar("Error", "Could not load data: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void filterAdmitCard() {
    if (selectedYear.value != null && selectedTaskId.value != null) {
      admitCard.value = allAdmitCards.firstWhereOrNull(
        (card) => card.year == selectedYear.value && card.taskId == selectedTaskId.value
      );
    }
  }
} 

import 'package:get/get.dart';
import 'package:school_management_system/controllers/authController.dart';
import 'package:school_management_system/models/admitcardModel.dart';
import 'package:school_management_system/services/api_services.dart';

class AdmitCardController extends GetxController {
  final isLoading = false.obs;
  final isGeneratingPdf = false.obs;

  var allAdmitCards = <AdmitCardModel>[].obs;
  var tasks = <Map<String, dynamic>>[].obs;
  var years = <int>[].obs;

  var selectedYear = Rxn<int>();
  var selectedTaskId = Rxn<int>();
  final admitCard = Rxn<AdmitCardModel>();

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      String authToken = AuthController.to.token;

      // 1. Fetch and Normalize Tasks
      final taskData = await ApiService.getRequest(endpoint: "Marksheet/tasks", token: authToken);
      tasks.assignAll((taskData as List).map((t) => {
        'taskId': int.tryParse(t['taskId'].toString()) ?? 0,
        'taskName': t['taskName'],
      }).toList());

      // 2. Fetch Admit Cards
      final cardData = await ApiService.getRequest(endpoint: "AdmitCard", token: authToken);
      allAdmitCards.assignAll((cardData as List).map((e) => AdmitCardModel.fromJson(e)).toList());

      // Debug: Check if Annual cards are actually in this list
      print("API returned ${allAdmitCards.length} cards total.");

      // 3. Extract unique years
      years.assignAll(allAdmitCards.map((e) => e.year).toSet().toList()..sort((a, b) => b.compareTo(a)));
      
    } catch (e) {
      Get.snackbar("Error", "Load failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterAdmitCard() {
    if (selectedYear.value != null && selectedTaskId.value != null) {
      // Find matching card using robust string comparison
      admitCard.value = allAdmitCards.firstWhereOrNull(
        (card) => card?.year.toString() == selectedYear.value.toString() && 
                  card?.taskId.toString() == selectedTaskId.value.toString()
      );
      
      if (admitCard.value == null) {
        Get.snackbar("Notice", "No data found for this specific exam type.", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
} 
import 'package:get/get.dart';
import 'package:school_management_system/controllers/authController.dart';
import 'package:school_management_system/models/admit_card_model.dart';
import '../services/api_services.dart';

class AdmitCardController extends GetxController {
  final isLoading = false.obs;
  final isGeneratingPdf = false.obs;

  // Data for Dropdowns
  var tasks = <Map<String, dynamic>>[].obs;
  var years = <int>[].obs;
  var studentClasses = <Map<String, dynamic>>[].obs;

  // Selection state
  var selectedYear = Rxn<int>();
  var selectedTaskId = Rxn<int>();
  var selectedClassId = Rxn<int>(); // Useful if student has history in multiple classes
  
  final admitCard = Rxn<AdmitCardModel>();

  @override
  void onInit() {
    super.onInit();
    loadInitialStudentParameters();
  }

  /// STEP 1 & 2: Get StudentId from Auth and fetch available parameters (Year/Task/Class)
  Future<void> loadInitialStudentParameters() async {
    isLoading.value = true;
    try {
      String token = AuthController.to.token;
      
      // Pulling StudentId initialized from the login (UserId -> Student Profile)
      int studentId = AuthController.to.user.value.studentId;

      // Fetch Tasks (Mid, Annual, etc.)
      final taskData = await ApiService.getRequest(
        endpoint: "Marksheet/tasks", 
        token: token
      );
      tasks.assignAll(List<Map<String, dynamic>>.from(taskData));

      // Fetch available years/classes for THIS specific StudentId
      // Adjust this endpoint name based on your actual API for student history
      final studentInfo = await ApiService.getRequest(
        endpoint: "Student/Parameters/$studentId", 
        token: token
      );

      if (studentInfo != null) {
        // Populate years and classId from the student's specific record
        years.assignAll(List<int>.from(studentInfo['availableYears']));
        selectedClassId.value = studentInfo['currentClassId']; 
      }

    } catch (e) {
      print("Error loading student parameters: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// STEP 3: Fetch the specific Admit Card when dropdowns change
  Future<void> fetchAdmitCard() async {
    // We need Year and Task selected by user, and ClassId/StudentId from the system
    if (selectedYear.value == null || selectedTaskId.value == null) return;

    isLoading.value = true;
    try {
      int studentId = AuthController.to.user.value.studentId;
      int classId = selectedClassId.value ?? AuthController.to.user.value.classId;
      String token = AuthController.to.token;

      // The exact query string from your Swagger screenshot
      final endpoint = "AdmitCard?StudentId=$studentId&TaskId=${selectedTaskId.value}&ClassId=$classId&Year=${selectedYear.value}";

      final response = await ApiService.getRequest(endpoint: endpoint, token: token);

      if (response != null) {
        if (response is List && response.isNotEmpty) {
          admitCard.value = AdmitCardModel.fromJson(response[0]);
        } else if (response is Map<String, dynamic>) {
          admitCard.value = AdmitCardModel.fromJson(response);
        }
      } else {
        admitCard.value = null;
      }
    } catch (e) {
      print("Admit Card API Error: $e");
      admitCard.value = null;
    } finally {
      isLoading.value = false;
    }
  }
} 
import 'package:get/get.dart';
import 'package:school_management_system/controllers/authController.dart';
import 'package:school_management_system/models/admitcardModel.dart';
import '../services/api_services.dart';



class AdmitCardController extends GetxController {
  final isLoading = false.obs;
  
  // Dropdown Lists
  var tasks = <Map<String, dynamic>>[].obs;
  var years = <int>[].obs;

  // Parameters discovered from UserId (792)
  int? realStudentId;
  int? realClassId;

  // Selected Values for the Dropdowns
  var selectedYear = Rxn<int>();
  var selectedTaskId = Rxn<int>();
  
  final admitCard = Rxn<AdmitCardModel>();

  @override
  void onInit() {
    super.onInit();
    performIdentityDiscovery();
  }

  /// 1. Use UserId (792) to find the correct IDs and Year
  Future<void> performIdentityDiscovery() async {
    isLoading.value = true;
    try {
      String token = AuthController.to.token;
      String uId = AuthController.to.studentId; // The 792 from Login

      // Initial probe to see who this user actually is in the database
      final response = await ApiService.getRequest(
        endpoint: "AdmitCard?StudentId=$uId", 
        token: token
      );

      // Extract details from the response
      if (response != null && response is List && response.isNotEmpty) {
        final data = response[0];
        realStudentId = data['studentId'];
        realClassId = data['classId'];
        
        // Pre-select the year found in the record
        selectedYear.value = data['year'];
      }

      // Generate a range for the Year Dropdown (e.g., +/- 2 years from discovered year)
      int baseYear = selectedYear.value ?? DateTime.now().year;
      years.assignAll([baseYear - 1, baseYear, baseYear + 1]);

      // Load Tasks (Mid, Annual, etc.)
      final taskData = await ApiService.getRequest(endpoint: "Marksheet/tasks", token: token);
      tasks.assignAll(List<Map<String, dynamic>>.from(taskData));

    } catch (e) {
      print("Discovery Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 2. Fetch Card based on User Selections
  Future<void> fetchAdmitCard() async {
    if (selectedYear.value == null || selectedTaskId.value == null) return;

    isLoading.value = true;
    try {
      // Use discovered IDs but selected Year/Task
      final String url = "AdmitCard?StudentId=$realStudentId"
          "&TaskId=${selectedTaskId.value}"
          "&ClassId=$realClassId"
          "&Year=${selectedYear.value}";

      final response = await ApiService.getRequest(endpoint: url, token: AuthController.to.token);

      if (response != null) {
        if (response is List && response.isNotEmpty) {
          admitCard.value = AdmitCardModel.fromJson(response[0]);
        } else {
          admitCard.value = AdmitCardModel.fromJson(response);
        }
      }
    } catch (e) {
      admitCard.value = null;
      Get.snackbar("Notice", "No record found for this specific year/term.");
    } finally {
      isLoading.value = false;
    }
  }
} 

// ============================================================
// lib/controllers/admit_card_controller.dart
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:school_management_system/controllers/authController.dart';
import 'package:school_management_system/models/admit_card_model.dart';
import 'package:school_management_system/services/api_services.dart';

class AdmitCardController extends GetxController {
  // ─── Observables ──────────────────────────────────────────────────────────
  final isLoading        = false.obs;
  final isGeneratingPdf  = false.obs;

  /// All cards returned for this student (all years / all tasks)
  final allAdmitCards = <AdmitCardModel>[].obs;

  /// Task list from /Marksheet/tasks
  final tasks = <Map<String, dynamic>>[].obs;

  /// Unique years derived from allAdmitCards
  final years = <int>[].obs;

  /// Currently selected dropdown values
  final selectedYear = Rxn<int>();
  final selectedTask = Rxn<Map<String, dynamic>>();

  /// The single card shown on screen (filtered from allAdmitCards)
  final currentAdmitCard = Rxn<AdmitCardModel>();

  // ─── Private ──────────────────────────────────────────────────────────────
  int? _studentId;
  int? _classId;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  // ─── Step 1 : load all cards + tasks, populate dropdowns ─────────────────
  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      final token  = AuthController.to.token;
      final userId = AuthController.to.studentId;

      // ── 1a. Fetch all admit cards for this user ──────────────────────────
      final rawCards = await ApiService.getRequest(
        endpoint: 'AdmitCard?StudentId=$userId',
        token: token,
      );

      if (rawCards is List && rawCards.isNotEmpty) {
        // Filter out empty maps that the API sometimes returns
        final validRaw = rawCards
            .whereType<Map<String, dynamic>>()
            .where((m) => m.isNotEmpty)
            .toList();

        final cards = validRaw
            .map((m) => AdmitCardModel.fromJson(m))
            .toList();

        allAdmitCards.assignAll(cards);

        // Grab real IDs from the first valid record
        _studentId = cards.first.studentId;
        _classId   = cards.first.classId;

        // Build unique year list (descending)
        final uniqueYears = cards.map((c) => c.year).toSet().toList()
          ..sort((a, b) => b.compareTo(a));
        years.assignAll(uniqueYears);

        // Pre-select the most recent year
        selectedYear.value = uniqueYears.first;
      }

      // ── 1b. Fetch tasks ──────────────────────────────────────────────────
      final rawTasks = await ApiService.getTasks(token: token);
      tasks.assignAll(rawTasks.cast<Map<String, dynamic>>());

      if (tasks.isNotEmpty) {
        selectedTask.value = tasks.first;
      }

      // ── 1c. Show the card that matches the default selections ────────────
      _applyFilter();
    } catch (e) {
      if (kDebugMode) print('AdmitCardController._loadInitialData error: $e');
      Get.snackbar(
        'Error',
        'Failed to load admit card data.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Step 2 : filter from the already-loaded list ────────────────────────
  void _applyFilter() {
    if (selectedYear.value == null || selectedTask.value == null) {
      currentAdmitCard.value = null;
      return;
    }

    final taskId = _taskIdFromSelected();

    final match = allAdmitCards.firstWhereOrNull(
      (c) => c.year == selectedYear.value && c.taskId == taskId,
    );

    currentAdmitCard.value = match;

    if (match == null) {
      Get.snackbar(
        'Notice',
        'No admit card found for the selected year / term.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─── Public: called when user changes a dropdown ─────────────────────────
  void onYearChanged(int? year) {
    selectedYear.value = year;
    _applyFilter();
  }

  void onTaskChanged(Map<String, dynamic>? task) {
    selectedTask.value = task;
    _applyFilter();
  }

  // ─── If the cached list doesn't have the combo, hit the API ──────────────
  Future<void> fetchAdmitCardFromApi() async {
    if (selectedYear.value == null || selectedTask.value == null) return;

    isLoading.value = true;
    try {
      final token  = AuthController.to.token;
      final taskId = _taskIdFromSelected();

      final endpoint = 'AdmitCard'
          '?StudentId=$_studentId'
          '&TaskId=$taskId'
          '&ClassId=$_classId'
          '&Year=${selectedYear.value}';

      final response = await ApiService.getRequest(
        endpoint: endpoint,
        token: token,
      );

      AdmitCardModel? card;
      if (response is List && response.isNotEmpty) {
        final first = (response as List)
            .whereType<Map<String, dynamic>>()
            .where((m) => m.isNotEmpty)
            .firstOrNull;
        if (first != null) card = AdmitCardModel.fromJson(first);
      } else if (response is Map<String, dynamic> && response.isNotEmpty) {
        card = AdmitCardModel.fromJson(response);
      }

      currentAdmitCard.value = card;

      if (card == null) {
        Get.snackbar(
          'Notice',
          'No admit card found for this year / term.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      currentAdmitCard.value = null;
      Get.snackbar(
        'Error',
        'Could not fetch admit card.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Helper ───────────────────────────────────────────────────────────────
  int _taskIdFromSelected() {
    final t = selectedTask.value;
    if (t == null) return 0;
    return (t['taskId'] ?? t['id'] ?? 0) as int;
  }

  String get selectedTaskName =>
      selectedTask.value?['taskName']?.toString() ?? '';
}  */

// ============================================================
// lib/controllers/admit_card_controller.dart
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:school_management_system/controllers/authController.dart';

import 'package:school_management_system/models/admitcardModel.dart';
import 'package:school_management_system/services/api_services.dart';

class AdmitCardController extends GetxController {
  // ─── Observables ──────────────────────────────────────────────────────────
  final isLoading        = false.obs;
  final isGeneratingPdf  = false.obs;

  /// All cards returned for this student (all years / all tasks)
  final allAdmitCards = <AdmitCardModel>[].obs;

  /// Task list from /Marksheet/tasks
  final tasks = <Map<String, dynamic>>[].obs;

  /// Unique years derived from allAdmitCards
  final years = <int>[].obs;

  /// Currently selected dropdown values
  final selectedYear = Rxn<int>();
  final selectedTask = Rxn<Map<String, dynamic>>();

  /// The single card shown on screen (filtered from allAdmitCards)
  final currentAdmitCard = Rxn<AdmitCardModel>();

  // ─── Private ──────────────────────────────────────────────────────────────
  int? _studentId;
  int? _classId;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  // ─── Step 1 : load all cards + tasks, populate dropdowns ─────────────────
  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      final token  = AuthController.to.token;
      final userId = AuthController.to.studentId;

      // ── 1a. Fetch all admit cards for this user ──────────────────────────
      final rawCards = await ApiService.getRequest(
        endpoint: 'AdmitCard?StudentId=$userId',
        token: token,
      );

      if (rawCards is List && rawCards.isNotEmpty) {
        // Filter out empty maps that the API sometimes returns
        final validRaw = rawCards
            .whereType<Map<String, dynamic>>()
            .where((m) => m.isNotEmpty)
            .toList();

        final cards = validRaw
            .map((m) => AdmitCardModel.fromJson(m))
            .toList();

        allAdmitCards.assignAll(cards);

        // Grab real IDs from the first valid record
        _studentId = cards.first.studentId;
        _classId   = cards.first.classId;

        // Build unique year list (descending)
        final uniqueYears = cards.map((c) => c.year).toSet().toList()
          ..sort((a, b) => b.compareTo(a));
        years.assignAll(uniqueYears);

        // Pre-select the most recent year
        selectedYear.value = uniqueYears.first;
      }

      // ── 1b. Fetch tasks ──────────────────────────────────────────────────
      final rawTasks = await ApiService.getTasks(token: token);
      tasks.assignAll(rawTasks.cast<Map<String, dynamic>>());

      if (tasks.isNotEmpty) {
        selectedTask.value = tasks.first;
      }

      // ── 1c. Show the card that matches the default selections ────────────
      _applyFilter();
    } catch (e) {
      if (kDebugMode) print('AdmitCardController._loadInitialData error: $e');
      Get.snackbar(
        'Error',
        'Failed to load admit card data.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Step 2 : filter from the already-loaded list ────────────────────────
  void _applyFilter() {
    if (selectedYear.value == null || selectedTask.value == null) {
      currentAdmitCard.value = null;
      return;
    }

    final taskId = _taskIdFromSelected();

    final match = allAdmitCards.firstWhereOrNull(
      (c) => c.year == selectedYear.value && c.taskId == taskId,
    );

    currentAdmitCard.value = match;

    if (match == null) {
      Get.snackbar(
        'Notice',
        'No admit card found for the selected year / term.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─── Public: called when user changes a dropdown ─────────────────────────
  void onYearChanged(int? year) {
    selectedYear.value = year;
    _applyFilter();
  }

  void onTaskChanged(Map<String, dynamic>? task) {
    selectedTask.value = task;
    _applyFilter();
  }

  // ─── If the cached list doesn't have the combo, hit the API ──────────────
  Future<void> fetchAdmitCardFromApi() async {
    if (selectedYear.value == null || selectedTask.value == null) return;

    isLoading.value = true;
    try {
      final token  = AuthController.to.token;
      final taskId = _taskIdFromSelected();

      final endpoint = 'AdmitCard'
          '?StudentId=$_studentId'
          '&TaskId=$taskId'
          '&ClassId=$_classId'
          '&Year=${selectedYear.value}';

      final response = await ApiService.getRequest(
        endpoint: endpoint,
        token: token,
      );

      AdmitCardModel? card;
      if (response is List && response.isNotEmpty) {
        final first = (response as List)
            .whereType<Map<String, dynamic>>()
            .where((m) => m.isNotEmpty)
            .firstOrNull;
        if (first != null) card = AdmitCardModel.fromJson(first);
      } else if (response is Map<String, dynamic> && response.isNotEmpty) {
        card = AdmitCardModel.fromJson(response);
      }

      currentAdmitCard.value = card;

      if (card == null) {
        Get.snackbar(
          'Notice',
          'No admit card found for this year / term.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      currentAdmitCard.value = null;
      Get.snackbar(
        'Error',
        'Could not fetch admit card.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Helper ───────────────────────────────────────────────────────────────
  int _taskIdFromSelected() {
    final t = selectedTask.value;
    if (t == null) return 0;
    return (t['taskId'] ?? t['id'] ?? 0) as int;
  }

  String get selectedTaskName =>
      selectedTask.value?['taskName']?.toString() ?? '';
}