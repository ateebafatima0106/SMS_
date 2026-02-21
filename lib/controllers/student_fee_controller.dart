import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:school_management_system/models/student_fee_models.dart';

/// Student Fee Controller
/// API-ready: replace _simulateApi* methods with real API calls
class StudentFeeController extends GetxController {
  // Reactive state
  final RxBool isLoading = false.obs;
  final RxList<FeeRecord> paidFees = <FeeRecord>[].obs;
  final RxList<String> unpaidMonths = <String>[].obs;
  final Rx<FeeSearchFilter> currentFilter = FeeSearchFilter().obs;
  final Rxn<StudentFeeModel> selectedStudent = Rxn<StudentFeeModel>();

  // Form fields (for two-way binding)
  final departmentController = TextEditingController();
  final studentNameController = TextEditingController();
  final receiptNoController = TextEditingController();
  final studentIdController = TextEditingController();
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  final RxBool sendMessage = false.obs;

  // Dropdown values (Rx for reactive dropdowns)
  final RxString selectedDepartment = ''.obs;
  final RxString selectedSessionYear = ''.obs;
  final RxString selectedMonth = ''.obs;
  final RxString selectedYearFee = ''.obs;
  final Rx<FeeType> selectedFeeType = FeeType.monthly.obs;

  // Options for dropdowns (can be loaded from API)
  final RxList<String> departments = <String>[].obs;
  final RxList<String> sessionYears = <String>[].obs;
  final RxList<String> months = <String>[].obs;
  final RxList<String> yearFeeOptions = <String>[].obs;

  // Computed (reactive via Obx on selectedStudent/unpaidMonths)
  double get tuitionFee => selectedStudent.value?.tuitionFee ?? 0.0;
  int get unpaidMonthsCount => unpaidMonths.length;

  void selectStudent(StudentFeeModel? s) => selectedStudent.value = s;

  @override
  void onInit() {
    super.onInit();
    _loadDropdownOptions();
  }

  @override
  void onClose() {
    departmentController.dispose();
    studentNameController.dispose();
    receiptNoController.dispose();
    studentIdController.dispose();
    super.onClose();
  }

  void _loadDropdownOptions() {
    // Replace with API: fetchDepartments(), fetchSessionYears(), etc.
    departments.value = [
      'Computer Science',
      'Mathematics',
      'Physics',
      'Chemistry',
    ];
    sessionYears.value = ['2024-25', '2023-24', '2022-23'];
    months.value = List.generate(12, (i) => _monthName(i + 1));
    yearFeeOptions.value = ['2024', '2023', '2022'];
    if (departments.isNotEmpty) selectedDepartment.value = departments.first;
    if (sessionYears.isNotEmpty) selectedSessionYear.value = sessionYears.first;
    if (months.isNotEmpty)
      selectedMonth.value = months[DateTime.now().month - 1];
    if (yearFeeOptions.isNotEmpty) selectedYearFee.value = yearFeeOptions.first;
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[m - 1];
  }

  /// Fetch fee data based on current filter
  Future<void> fetchFeeData() async {
    try {
      isLoading.value = true;
      if (selectedFeeType.value == FeeType.monthly) {
        await searchByMonth();
      } else {
        await searchByYear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch fee data');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search by month + year (Monthly fees)
  Future<void> searchByMonth() async {
    try {
      isLoading.value = true;
      paidFees.clear();
      unpaidMonths.clear();
      selectedStudent.value = null;

      // Simulate: load student by studentId
      await _simulateLoadStudent();

      final filter = FeeSearchFilter(
        year: selectedSessionYear.value,
        month: selectedMonth.value,
        feeType: FeeType.monthly,
      );
      currentFilter.value = filter;

      // Simulate API response: unpaid months first, then paid records
      final result = await _simulateSearchMonthly(filter);
      unpaidMonths.value = result.$1;
      paidFees.value = result.$2;
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search by year only (Yearly fees)
  Future<void> searchByYear() async {
    try {
      isLoading.value = true;
      paidFees.clear();
      unpaidMonths.clear();
      selectedStudent.value = null;

      await _simulateLoadStudent();

      final filter = FeeSearchFilter(
        year: selectedYearFee.value,
        feeType: FeeType.yearly,
      );
      currentFilter.value = filter;

      final result = await _simulateSearchYearly(filter);
      unpaidMonths.value = result.$1;
      paidFees.value = result.$2;
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search by receipt number
  Future<void> searchByReceiptNo() async {
    final receipt = receiptNoController.text.trim();
    if (receipt.isEmpty) {
      Get.snackbar('Info', 'Please enter Receipt No');
      return;
    }
    try {
      isLoading.value = true;
      paidFees.clear();
      unpaidMonths.clear();

      final result = await _simulateSearchByReceipt(receipt);
      if (result != null) {
        selectedStudent.value = result.$1;
        unpaidMonths.value = result.$2;
        paidFees.value = result.$3;
      } else {
        Get.snackbar('Not Found', 'No record for Receipt: $receipt');
      }
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit fee (API placeholder)
  Future<void> submitFee() async {
    try {
      isLoading.value = true;
      await _simulateSubmitFee();
      Get.snackbar('Success', 'Fee submitted successfully');
      await fetchFeeData();
    } catch (e) {
      Get.snackbar('Error', 'Submit failed');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete fee record (API placeholder)
  Future<void> deleteFeeRecord(FeeRecord record) async {
    try {
      isLoading.value = true;
      await _simulateDeleteFee(record);
      paidFees.removeWhere((e) => e.id == record.id);
      Get.snackbar('Success', 'Record deleted');
    } catch (e) {
      Get.snackbar('Error', 'Delete failed');
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }

  // --- API simulation (replace with real API calls) ---

  Future<void> _simulateLoadStudent() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = studentIdController.text.trim();
    if (id.isEmpty) {
      selectedStudent.value = StudentFeeModel(
        studentId: 'STU001',
        studentName: 'John Doe',
        department: selectedDepartment.value,
        tuitionFee: 5000,
        imageUrl: null,
      );
    } else {
      selectedStudent.value = StudentFeeModel(
        studentId: id,
        studentName: studentNameController.text.trim().isEmpty
            ? 'Student $id'
            : studentNameController.text.trim(),
        department: selectedDepartment.value,
        tuitionFee: 5000,
        imageUrl: null,
      );
    }
  }

  Future<(List<String>, List<FeeRecord>)> _simulateSearchMonthly(
    FeeSearchFilter filter,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final year = filter.year.split('-').first;
    final unpaid = ['January $year', 'February $year', 'March $year'];
    final paid = [
      FeeRecord(
        id: '1',
        year: year,
        month: 'Apr',
        details: 'Monthly',
        amount: 5000,
        feeDate: DateTime(int.parse(year), 4, 15),
        receiptNo: 'RCP001',
      ),
      FeeRecord(
        id: '2',
        year: year,
        month: 'May',
        details: 'Monthly',
        amount: 5000,
        feeDate: DateTime(int.parse(year), 5, 10),
        receiptNo: 'RCP002',
      ),
    ];
    return (unpaid, paid);
  }

  Future<(List<String>, List<FeeRecord>)> _simulateSearchYearly(
    FeeSearchFilter filter,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final year = filter.year;
    final unpaid = ['Annual Fee $year'];
    final paid = [
      FeeRecord(
        id: '3',
        year: year,
        month: '-',
        details: 'Yearly',
        amount: 60000,
        feeDate: DateTime(int.parse(year), 4, 1),
        receiptNo: 'RCP003',
      ),
    ];
    return (unpaid, paid);
  }

  Future<(StudentFeeModel, List<String>, List<FeeRecord>)?>
  _simulateSearchByReceipt(String receipt) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return (
      StudentFeeModel(
        studentId: 'STU001',
        studentName: 'John Doe',
        department: 'Computer Science',
        tuitionFee: 5000,
        imageUrl: null,
      ),
      ['January 2024', 'February 2024'],
      [
        FeeRecord(
          id: '1',
          year: '2024',
          month: 'Mar',
          details: 'Monthly',
          amount: 5000,
          feeDate: DateTime(2024, 3, 15),
          receiptNo: receipt,
        ),
      ],
    );
  }

  Future<void> _simulateSubmitFee() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _simulateDeleteFee(FeeRecord record) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Generate PDF fee receipt/report
  /// Returns PDF bytes for printing or sharing
  Future<Uint8List?> generatePdf() async {
    final student = selectedStudent.value;
    if (student == null) {
      Get.snackbar('Info', 'Select a student first');
      return null;
    }
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader(student),
        footer: (context) => _buildPdfFooter(),
        build: (context) => [
          pw.SizedBox(height: 16),
          _buildPdfStudentInfo(student),
          pw.SizedBox(height: 20),
          if (unpaidMonths.isNotEmpty) ...[
            pw.Text(
              'Unpaid Months',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.red),
                color: PdfColors.red50,
              ),
              child: pw.Text(
                unpaidMonths.join(', '),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 16),
          ],
          pw.Text(
            'Fee Records',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _buildPdfFeeTable(),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _buildPdfHeader(StudentFeeModel student) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
              ),
              child: pw.Center(
                child: pw.Text('Logo', style: pw.TextStyle(fontSize: 8)),
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Text(
                    'School Name',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text('School Address', style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.Container(
              width: 50,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
              ),
              child: pw.Center(
                child: pw.Text('Photo', style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'Fee Receipt / Fee Report',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildPdfStudentInfo(StudentFeeModel student) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
      },
      children: [
        _pdfTableRow('Student ID', student.studentId),
        _pdfTableRow('Student Name', student.studentName),
        _pdfTableRow('Department', student.department),
        _pdfTableRow('Tuition Fee', student.tuitionFee.toStringAsFixed(0)),
      ],
    );
  }

  pw.TableRow _pdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  pw.Widget _buildPdfFeeTable() {
    final headers = [
      'Year',
      'Month',
      'Details',
      'Amount',
      'Fee Date',
      'Receipt No',
    ];
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ...paidFees.map(
          (r) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(r.year, style: const pw.TextStyle(fontSize: 9)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(r.month, style: const pw.TextStyle(fontSize: 9)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  r.details,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  r.amount.toStringAsFixed(0),
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  '${r.feeDate.day}/${r.feeDate.month}/${r.feeDate.year}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  r.receiptNo,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'Powered by KI Software Solutions',
            style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
