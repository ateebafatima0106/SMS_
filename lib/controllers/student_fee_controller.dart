import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:school_management_system/models/student_fee_models.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart';

/// Student Fee Controller — fetches data from 3 real APIs:
///   1. GET /StudentFee/Get-StudentFees?Year=...
///   2. GET /StudentFee/Get-StudentFeeAdditionals?Year=...
///   3. GET /PendingFee/Get-PendingFee-Tasks?StudentId=...&Year=...
class StudentFeeController extends GetxController {
  // ─── State ──────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Fee data
  final RxList<FeeRecord> regularFees = <FeeRecord>[].obs;
  final RxList<FeeRecord> additionalFees = <FeeRecord>[].obs;
  final RxString pendingFeeMessage = ''.obs;

  // Student info (extracted from fee records)
  final RxString studentName = ''.obs;
  final RxString studentId = ''.obs;

  // Year filter
  final RxString selectedYear = ''.obs;
  static final List<String> yearOptions = [
    DateTime.now().year.toString(),
    (DateTime.now().year - 1).toString(),
    (DateTime.now().year - 2).toString(),
  ];

  final _api = ApiService();
  final _auth = AuthService();

  // ─── Computed ───────────────────────────────────────────
  double get totalRegularFees => regularFees.fold(0.0, (sum, r) => sum + r.fee);
  double get totalAdditionalFees =>
      additionalFees.fold(0.0, (sum, r) => sum + r.fee);
  double get grandTotal => totalRegularFees + totalAdditionalFees;

  // ─── Lifecycle ──────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    selectedYear.value = yearOptions.first;
    _loadStudentInfo();
    fetchAllFeeData();
  }

  Future<void> _loadStudentInfo() async {
    studentId.value = await _auth.getStudentId() ?? '';
    studentName.value = await _auth.getStudentName() ?? '';
  }

  // ─── Fetch All 3 APIs ──────────────────────────────────
  Future<void> fetchAllFeeData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (studentId.value.isEmpty) {
        await _loadStudentInfo();
      }

      await Future.wait([
        _fetchRegularFees(),
        _fetchAdditionalFees(),
        _fetchPendingFees(),
      ]);
    } catch (e) {
      errorMessage.value = 'Failed to load fee data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// 1. GET /StudentFee/Get-StudentFees?Year=...
  Future<void> _fetchRegularFees() async {
    try {
      final response = await _api.get(
        '/StudentFee/Get-StudentFees',
        queryParams: {'Year': selectedYear.value},
      );

      if (response is Map<String, dynamic> &&
          response['success'] == true &&
          response['data'] is List) {
        final data = (response['data'] as List)
            .cast<Map<String, dynamic>>()
            .map((json) => FeeRecord.fromJson(json))
            .toList();

        // Filter for current student
        final sid = studentId.value;
        if (sid.isNotEmpty) {
          regularFees.value = data
              .where((r) => r.studentId.toString() == sid)
              .toList();
        } else {
          regularFees.value = data;
        }
      } else if (response is String) {
        // "No Record Found" or similar
        regularFees.clear();
      } else {
        regularFees.clear();
      }
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        errorMessage.value = e.message;
      }
      regularFees.clear();
    }
  }

  /// 2. GET /StudentFee/Get-StudentFeeAdditionals?Year=...
  Future<void> _fetchAdditionalFees() async {
    try {
      final response = await _api.get(
        '/StudentFee/Get-StudentFeeAdditionals',
        queryParams: {'Year': selectedYear.value},
      );

      if (response is Map<String, dynamic> &&
          response['success'] == true &&
          response['data'] is List) {
        final data = (response['data'] as List)
            .cast<Map<String, dynamic>>()
            .map((json) => FeeRecord.fromJson(json))
            .toList();

        final sid = studentId.value;
        if (sid.isNotEmpty) {
          additionalFees.value = data
              .where((r) => r.studentId.toString() == sid)
              .toList();
        } else {
          additionalFees.value = data;
        }
      } else if (response is String) {
        additionalFees.clear();
      } else {
        additionalFees.clear();
      }
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        errorMessage.value = e.message;
      }
      additionalFees.clear();
    }
  }

  /// 3. GET /PendingFee/Get-PendingFee-Tasks?StudentId=...&Year=...
  Future<void> _fetchPendingFees() async {
    try {
      final sid = studentId.value;
      if (sid.isEmpty) {
        pendingFeeMessage.value = 'Failed to load student ID';
        return;
      }

      final response = await _api.get(
        '/PendingFee/Get-PendingFee-Tasks',
        queryParams: {'StudentId': sid, 'Year': selectedYear.value},
      );

      if (response is String) {
        // "No Pending Fee" or similar message
        pendingFeeMessage.value = response.trim().replaceAll('"', '');
      } else if (response is List) {
        // TODO: Parse pending fee list if API returns structured data
        pendingFeeMessage.value = response.map((e) => e.toString()).join(', ');
      } else {
        pendingFeeMessage.value = 'No Pending Fee';
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404 ||
          e.message.toLowerCase().contains('no pending')) {
        pendingFeeMessage.value = 'No Pending Fee';
      } else {
        pendingFeeMessage.value = 'Error checking pending fees: ${e.message}';
      }
    } catch (e) {
      pendingFeeMessage.value = 'Error checking pending fees';
    }
  }

  // ─── Year change ────────────────────────────────────────
  void onYearChanged(String year) {
    selectedYear.value = year;
    fetchAllFeeData();
  }

  // ─── PDF Generation ────────────────────────────────────
  Future<Uint8List?> generatePdf() async {
    if (regularFees.isEmpty && additionalFees.isEmpty) {
      Get.snackbar('Info', 'No fee records to generate PDF.');
      return null;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _pdfHeader(),
        footer: (_) => _pdfFooter(),
        build: (_) => [
          pw.SizedBox(height: 16),
          _pdfStudentInfo(),
          pw.SizedBox(height: 20),
          if (regularFees.isNotEmpty) ...[
            pw.Text(
              'Monthly / Regular Fees',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _pdfFeeTable(regularFees),
            pw.SizedBox(height: 8),
            _pdfTotalRow('Total Regular Fees', totalRegularFees),
            pw.SizedBox(height: 20),
          ],
          if (additionalFees.isNotEmpty) ...[
            pw.Text(
              'Additional Fees',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _pdfFeeTable(additionalFees),
            pw.SizedBox(height: 8),
            _pdfTotalRow('Total Additional Fees', totalAdditionalFees),
            pw.SizedBox(height: 20),
          ],
          pw.Divider(),
          _pdfTotalRow('Grand Total', grandTotal),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _pdfHeader() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            'BENCHMARK School of Leadership',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'Fee Statement — Year ${selectedYear.value}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _pdfStudentInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Text(
                  'Student: ',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  studentName.value,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Text(
                  'ID: ',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  studentId.value,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfFeeTable(List<FeeRecord> records) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: ['Year', 'Month', 'Details', 'Fee Date', 'Amount', 'Slip #']
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
        ...records.map(
          (r) => pw.TableRow(
            children:
                [
                      r.year,
                      r.month,
                      r.details,
                      r.feeDate,
                      r.fee.toStringAsFixed(0),
                      r.slipNo.toString(),
                    ]
                    .map(
                      (v) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          v,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfTotalRow(String label, double total) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Rs. ${total.toStringAsFixed(0)}',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _pdfFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
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
