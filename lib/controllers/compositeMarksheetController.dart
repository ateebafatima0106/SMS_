// ignore_for_file: file_names, avoid_print, unnecessary_overrides

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:school_management_system/models/compositeMarksheetModel.dart';

class CompositeMarksheetController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final isFilterExpanded = false.obs;
  final errorMessage = ''.obs;
  final yearlyMarks = <CompositeMarksheetModel>[].obs;
  final selectedMarksheet = Rx<CompositeMarksheetModel?>(null);
  final marksheetData = Rxn<CompositeMarksheetModel>();
  final isGeneratingPdf = false.obs;

  // Filters
  final selectedYear = Rx<String?>(null);
  final availableYears = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadYearlyData();
  }

  /// Load yearly composite marksheet data
  Future<void> loadYearlyData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // final response = await apiService.getCompositeMarksheets();
      // yearlyMarks.value = response.map((json) => CompositeMarksheetModel.fromJson(json)).toList();

      // Using dummy data for now
      yearlyMarks.value = _getDummyData();

      // Extract available years
      availableYears.value =
          yearlyMarks.map((m) => m.academicYear).toSet().toList()
            ..sort((a, b) => b.compareTo(a)); // Latest first

      if (availableYears.isNotEmpty) {
        selectedYear.value = availableYears.first;
        _setCurrentMarksheetForSelectedYear();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load marksheets: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a marksheet to view details
  void selectMarksheet(CompositeMarksheetModel marksheet) {
    selectedMarksheet.value = marksheet;
    marksheetData.value = marksheet;
  }

  /// Filter by year
  void filterByYear(String year) {
    selectedYear.value = year;
    _setCurrentMarksheetForSelectedYear();
  }

  /// Get filtered marksheets
  List<CompositeMarksheetModel> get filteredMarksheets {
    if (selectedYear.value == null) return yearlyMarks;
    return yearlyMarks
        .where((m) => m.academicYear == selectedYear.value)
        .toList();
  }

  void _setCurrentMarksheetForSelectedYear() {
    final year = selectedYear.value;
    if (year == null) return;

    final byYear = yearlyMarks.where((m) => m.academicYear == year).toList();
    if (byYear.isEmpty) {
      selectedMarksheet.value = null;
      marksheetData.value = null;
      return;
    }

    // If multiple exist for a year, prefer most recent.
    byYear.sort((a, b) {
      final aTs = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTs = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bTs.compareTo(aTs);
    });

    selectMarksheet(byYear.first);
  }

  void toggleFilter() {
    isFilterExpanded.value = !isFilterExpanded.value;
  }

  /// Generate PDF for selected marksheet
  Future<void> generatePdf() async {
    if (selectedMarksheet.value == null) {
      Get.snackbar(
        'Error',
        'No marksheet selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isGeneratingPdf.value = true;

      final pdf = pw.Document();
      final marksheet = selectedMarksheet.value!;

      // Load robust fonts that support Unicode and don't cause parser errors
      final robotoRegular = await PdfGoogleFonts.robotoRegular();
      final robotoBold = await PdfGoogleFonts.robotoBold();

      // Load student photo if available
      pw.ImageProvider? studentPhoto;
      if (marksheet.studentInfo.photoUrl != null &&
          marksheet.studentInfo.photoUrl!.isNotEmpty) {
        try {
          studentPhoto = await networkImage(marksheet.studentInfo.photoUrl!);
        } catch (e) {
          print('Failed to load photo: $e');
        }
      }

      // Add single page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => pw.Column(
            children: [
              _buildPdfHeader(marksheet, studentPhoto, robotoBold),
              pw.SizedBox(height: 16),
              _buildPdfStudentInfo(
                marksheet.studentInfo,
                robotoRegular,
                robotoBold,
              ),
              pw.SizedBox(height: 16),
              _buildPdfTable(marksheet, robotoRegular, robotoBold),
              pw.SizedBox(height: 30),
              _buildPdfFooter(robotoRegular),
            ],
          ),
        ),
      );

      // Save and share PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'Transcript_${marksheet.studentInfo.studentName.replaceAll(' ', '_')}_${marksheet.academicYear}.pdf',
      );

      Get.snackbar(
        'Success',
        'PDF generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  /// Build PDF header perfectly matched to image
  pw.Widget _buildPdfHeader(
    CompositeMarksheetModel marksheet,
    pw.ImageProvider? photo,
    pw.Font boldFont,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 1, child: pw.SizedBox()),
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'TRANSCRIPT',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 26,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'FOR THE ACADEMIC YEAR ${marksheet.academicYear}',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Align(
            alignment: pw.Alignment.topRight,
            child: pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1.5),
              ),
              child: photo != null
                  ? pw.Image(photo, fit: pw.BoxFit.cover)
                  : pw.SizedBox(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build PDF Student Info explicitly matching cells
  pw.Widget _buildPdfStudentInfo(
    StudentInfo info,
    pw.Font regFont,
    pw.Font boldFont,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
      child: pw.Column(
        children: [
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 1)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _infoCell(
                  'Student\'s\nName',
                  16,
                  isLabel: true,
                  alignLeft: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  info.studentName.toUpperCase(),
                  34,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  'Std. Id',
                  10,
                  isLabel: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  'Class',
                  15,
                  isLabel: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  info.className.toUpperCase(),
                  25,
                  hideRightBorder: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
              ],
            ),
          ),
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 1)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _infoCell(
                  'Father\'s\nName',
                  16,
                  isLabel: true,
                  alignLeft: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  info.fatherName.toUpperCase(),
                  34,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  info.studentId,
                  10,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  'Roll #',
                  15,
                  isLabel: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  info.rollNo,
                  25,
                  hideRightBorder: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
              ],
            ),
          ),
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 1)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _infoCell(
                  'Result',
                  16,
                  isLabel: true,
                  alignLeft: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  info.result.toUpperCase(),
                  34,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  'Max.\nMarks',
                  10,
                  isLabel: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  info.totalMaxMarks.toStringAsFixed(0),
                  15,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  'Percentage',
                  15,
                  isLabel: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
                _infoCell(
                  '${info.percentage.toStringAsFixed(2)} %',
                  10,
                  hideRightBorder: true,
                  boldFont: boldFont,
                  regFont: regFont,
                ),
              ],
            ),
          ),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _infoCell(
                'Position',
                16,
                isLabel: true,
                alignLeft: true,
                boldFont: boldFont,
                regFont: regFont,
              ),
              _infoCell(
                (info.position.isEmpty) ? " " : info.position.toUpperCase(),
                34,
                boldFont: boldFont,
                regFont: regFont,
              ),
              _infoCell(
                'Obt.\nMarks',
                10,
                isLabel: true,
                boldFont: boldFont,
                regFont: regFont,
              ),
              _infoCell(
                info.totalObtainedMarks.toStringAsFixed(0),
                15,
                boldFont: boldFont,
                regFont: regFont,
              ),
              _infoCell(
                'Grade',
                15,
                isLabel: true,
                boldFont: boldFont,
                regFont: regFont,
              ),
              _infoCell(
                info.grade.toUpperCase(),
                10,
                hideRightBorder: true,
                boldFont: boldFont,
                regFont: regFont,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _infoCell(
    String text,
    int flex, {
    bool isLabel = false,
    bool hideRightBorder = false,
    bool alignLeft = false,
    required pw.Font boldFont,
    required pw.Font regFont,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: hideRightBorder
              ? null
              : const pw.Border(right: pw.BorderSide(width: 1)),
        ),
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: alignLeft
            ? pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  text,
                  style: pw.TextStyle(
                    font: isLabel ? boldFont : regFont,
                    fontSize: 8.5,
                  ),
                ),
              )
            : pw.Center(
                child: pw.Text(
                  text,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: isLabel ? boldFont : regFont,
                    fontSize: 8.5,
                  ),
                ),
              ),
      ),
    );
  }

  /// Build Custom Assessment Table
  pw.Widget _buildPdfTable(
    CompositeMarksheetModel marksheet,
    pw.Font regFont,
    pw.Font boldFont,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
      child: pw.Column(
        children: [
          // Header Row
          pw.Container(
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border(bottom: pw.BorderSide(width: 1.5)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _headerCell('Learning Area', 18, boldFont),
                _headerCell('Subject', 18, boldFont),
                _headerCell('Assessment Title', 28, boldFont),
                _headerCell('Max\nMarks', 8, boldFont),
                _headerCell('Passing\nMarks', 8, boldFont),
                _headerCell('Obt\nMarks', 8, boldFont),
                _headerCell('Agg.\nMarks', 12, boldFont, hideRightBorder: true),
              ],
            ),
          ),
          // Subject Rows
          ...marksheet.subjectAssessments.map((sa) {
            bool isLastSubject = sa == marksheet.subjectAssessments.last;
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: isLastSubject
                    ? null
                    : const pw.Border(bottom: pw.BorderSide(width: 1)),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _bodyCell(
                    sa.learningArea.toUpperCase(),
                    18,
                    boldFont,
                    regFont,
                    bold: true,
                  ),
                  _bodyCell(
                    sa.subject.toUpperCase(),
                    18,
                    boldFont,
                    regFont,
                    bold: true,
                  ),
                  pw.Expanded(
                    flex: 52,
                    child: pw.Column(
                      children: sa.assessments.map((a) {
                        bool isLastAssessment = a == sa.assessments.last;
                        return pw.Container(
                          decoration: pw.BoxDecoration(
                            border: isLastAssessment
                                ? null
                                : const pw.Border(
                                    bottom: pw.BorderSide(width: 1),
                                  ),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              _bodyCell(
                                a.assessmentTitle,
                                28,
                                boldFont,
                                regFont,
                              ),
                              _bodyCell(
                                a.maxMarks.toStringAsFixed(0),
                                8,
                                boldFont,
                                regFont,
                              ),
                              _bodyCell(
                                a.passingMarks.toStringAsFixed(0),
                                8,
                                boldFont,
                                regFont,
                              ),
                              _bodyCell(
                                a.obtainedMarks.toStringAsFixed(0),
                                8,
                                boldFont,
                                regFont,
                                hideRightBorder: true,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _bodyCell(
                    sa.aggregateObtainedMarks.toStringAsFixed(0),
                    12,
                    boldFont,
                    regFont,
                    hideRightBorder: true,
                    drawLeftBorder: true,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  pw.Widget _headerCell(
    String text,
    int flex,
    pw.Font boldFont, {
    bool hideRightBorder = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: hideRightBorder
              ? null
              : const pw.Border(right: pw.BorderSide(width: 1)),
        ),
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: pw.Center(
          child: pw.Text(
            text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: boldFont, fontSize: 8.5),
          ),
        ),
      ),
    );
  }

  pw.Widget _bodyCell(
    String text,
    int flex,
    pw.Font boldFont,
    pw.Font regFont, {
    bool bold = false,
    bool hideRightBorder = false,
    bool drawLeftBorder = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: hideRightBorder
                ? pw.BorderSide.none
                : const pw.BorderSide(width: 1),
            left: drawLeftBorder
                ? const pw.BorderSide(width: 1)
                : pw.BorderSide.none,
          ),
        ),
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: pw.Center(
          child: pw.Text(
            text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: bold ? boldFont : regFont, fontSize: 8),
          ),
        ),
      ),
    );
  }

  /// Build PDF footer with signature space
  pw.Widget _buildPdfFooter(pw.Font regFont) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 40),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSignature('Class Teacher', regFont),
            _buildSignature('Principal', regFont),
            _buildSignature('Parent/Guardian', regFont),
          ],
        ),
      ],
    );
  }

  /// Build signature line
  pw.Widget _buildSignature(String label, pw.Font regFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 120, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(font: regFont, fontSize: 9)),
      ],
    );
  }

  /// Get dummy data matching the image structure
  List<CompositeMarksheetModel> _getDummyData() {
    return [
      CompositeMarksheetModel(
        academicYear: '2025-2026',
        studentInfo: StudentInfo(
          studentId: '506',
          studentName: 'ANAIZA FATIMA',
          fatherName: 'MD SUHAIL KHAN',
          rollNo: '29',
          className: 'MONT JUNIOR',
          position: '',
          result: 'TRY AGAIN',
          grade: 'B',
          totalMaxMarks: 1950,
          totalObtainedMarks: 1300,
          percentage: 66.67,
        ),
        subjectAssessments: [
          SubjectAssessment(
            learningArea: 'RELIGION',
            subject: 'ISLAMIAT',
            assessments: [
              Assessment(
                assessmentId: '1',
                assessmentTitle: 'Mid Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 96,
              ),
              Assessment(
                assessmentId: '2',
                assessmentTitle: 'Annual Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 55,
              ),
              Assessment(
                assessmentId: '3',
                assessmentTitle: 'Preliminary Test (Fall)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 25,
              ),
              Assessment(
                assessmentId: '4',
                assessmentTitle: 'Preliminary Test (Spring)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 7,
              ),
            ],
            aggregateMaxMarks: 250,
            aggregateObtainedMarks: 183,
          ),
          SubjectAssessment(
            learningArea: 'NATIVE LANGUAGE',
            subject: 'URDU',
            assessments: [
              Assessment(
                assessmentId: '5',
                assessmentTitle: 'Mid Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 78,
              ),
              Assessment(
                assessmentId: '6',
                assessmentTitle: 'Annual Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 55,
              ),
              Assessment(
                assessmentId: '7',
                assessmentTitle: 'Preliminary Test (Fall)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 22,
              ),
              Assessment(
                assessmentId: '8',
                assessmentTitle: 'Preliminary Test (Spring)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 5,
              ),
            ],
            aggregateMaxMarks: 250,
            aggregateObtainedMarks: 160,
          ),
          SubjectAssessment(
            learningArea: 'INTERNATIONAL LANGUAGE',
            subject: 'ENGLISH',
            assessments: [
              Assessment(
                assessmentId: '9',
                assessmentTitle: 'Mid Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 61,
              ),
              Assessment(
                assessmentId: '10',
                assessmentTitle: 'Annual Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 55,
              ),
              Assessment(
                assessmentId: '11',
                assessmentTitle: 'Preliminary Test (Fall)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 22,
              ),
              Assessment(
                assessmentId: '12',
                assessmentTitle: 'Preliminary Test (Spring)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 8,
              ),
            ],
            aggregateMaxMarks: 250,
            aggregateObtainedMarks: 146,
          ),
          SubjectAssessment(
            learningArea: 'CONCEPT DEVELOPMENT',
            subject: 'MATHEMATICS',
            assessments: [
              Assessment(
                assessmentId: '13',
                assessmentTitle: 'Mid Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 73,
              ),
              Assessment(
                assessmentId: '14',
                assessmentTitle: 'Annual Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 55,
              ),
              Assessment(
                assessmentId: '15',
                assessmentTitle: 'Preliminary Test (Fall)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 25,
              ),
              Assessment(
                assessmentId: '16',
                assessmentTitle: 'Preliminary Test (Spring)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 9,
              ),
            ],
            aggregateMaxMarks: 250,
            aggregateObtainedMarks: 162,
          ),
        ],
      ),
    ];
  }

  @override
  void onClose() {
    super.onClose();
  }
}
