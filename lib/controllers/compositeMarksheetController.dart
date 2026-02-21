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

      // Load fonts
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

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => [
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

  /// Build PDF header
  pw.Widget _buildPdfHeader(
    CompositeMarksheetModel marksheet,
    pw.ImageProvider? photo,
    pw.Font boldFont,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
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
              height: 100,
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

  /// Build PDF student info section using pw.Table for stability
  pw.Widget _buildPdfStudentInfo(
    StudentInfo info,
    pw.Font regFont,
    pw.Font boldFont,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(0.8),
        3: const pw.FlexColumnWidth(0.8),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          children: [
            _tableInfoCell('Student\'s\nName', boldFont, alignLeft: true),
            _tableInfoCell(info.studentName.toUpperCase(), regFont),
            _tableInfoCell('Std. Id', boldFont),
            _tableInfoCell('Class', boldFont),
            _tableInfoCell(info.className.toUpperCase(), regFont),
          ],
        ),
        pw.TableRow(
          children: [
            _tableInfoCell('Father\'s\nName', boldFont, alignLeft: true),
            _tableInfoCell(info.fatherName.toUpperCase(), regFont),
            _tableInfoCell(info.studentId, regFont),
            _tableInfoCell('Roll #', boldFont),
            _tableInfoCell(info.rollNo, regFont),
          ],
        ),
        pw.TableRow(
          children: [
            _tableInfoCell('Result', boldFont, alignLeft: true),
            _tableInfoCell(info.result.toUpperCase(), regFont),
            _tableInfoCell('Max.\nMarks', boldFont),
            _tableInfoCell(info.totalMaxMarks.toStringAsFixed(0), regFont),
            _tableInfoCell('Percentage', boldFont),
            _tableInfoCell('${info.percentage.toStringAsFixed(2)} %', regFont),
          ],
        ),
        pw.TableRow(
          children: [
            _tableInfoCell('Position', boldFont, alignLeft: true),
            _tableInfoCell(
              info.position.isEmpty ? " " : info.position.toUpperCase(),
              regFont,
            ),
            _tableInfoCell('Obt.\nMarks', boldFont),
            _tableInfoCell(info.totalObtainedMarks.toStringAsFixed(0), regFont),
            _tableInfoCell('Grade', boldFont),
            _tableInfoCell(info.grade.toUpperCase(), regFont),
          ],
        ),
      ],
    );
  }

  pw.Widget _tableInfoCell(
    String text,
    pw.Font font, {
    bool alignLeft = false,
  }) {
    return pw.Container(
      alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 8.5),
      ),
    );
  }

  /// Build PDF table with all assessments using nested tables for perfect cross-row look
  pw.Widget _buildPdfTable(
    CompositeMarksheetModel marksheet,
    pw.Font regFont,
    pw.Font boldFont,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.8), // Learning Area
        1: const pw.FlexColumnWidth(1.8), // Subject
        2: const pw.FlexColumnWidth(4.9), // Assessment Title + Marks
        3: const pw.FlexColumnWidth(1.2), // Agg. Marks
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _headerCell('Learning Area', boldFont),
            _headerCell('Subject', boldFont),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5), // Title
                1: const pw.FlexColumnWidth(0.8), // Max
                2: const pw.FlexColumnWidth(0.8), // Passing
                3: const pw.FlexColumnWidth(0.8), // Obt
              },
              children: [
                pw.TableRow(
                  children: [
                    _headerCell('Assessment Title', boldFont),
                    _headerCell('Max\nMarks', boldFont),
                    _headerCell('Passing\nMarks', boldFont),
                    _headerCell('Obt\nMarks', boldFont),
                  ],
                ),
              ],
            ),
            _headerCell('Agg.\nMarks', boldFont),
          ],
        ),
        // Data Rows
        ...marksheet.subjectAssessments.map((sa) {
          return pw.TableRow(
            children: [
              _dataCell(sa.learningArea.toUpperCase(), regFont),
              _dataCell(sa.subject.toUpperCase(), boldFont),
              // Nested table for assessments
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(0.8),
                  2: const pw.FlexColumnWidth(0.8),
                  3: const pw.FlexColumnWidth(0.8),
                },
                children: sa.assessments.map((a) {
                  return pw.TableRow(
                    children: [
                      _dataCell(a.assessmentTitle, regFont, alignLeft: true),
                      _dataCell(a.maxMarks.toStringAsFixed(0), regFont),
                      _dataCell(a.passingMarks.toStringAsFixed(0), regFont),
                      _dataCell(a.obtainedMarks.toStringAsFixed(0), regFont),
                    ],
                  );
                }).toList(),
              ),
              _dataCell(
                sa.aggregateObtainedMarks.toStringAsFixed(0),
                boldFont,
                background: PdfColors.blue50,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _headerCell(String text, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 9),
      ),
    );
  }

  pw.Widget _dataCell(
    String text,
    pw.Font font, {
    bool alignLeft = false,
    PdfColor? background,
  }) {
    return pw.Container(
      color: background,
      alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 8.5),
      ),
    );
  }

  /// Build PDF footer
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
        pw.Container(width: 120, height: 1.5, color: PdfColors.black),
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
          SubjectAssessment(
            learningArea: 'INTERNATIONAL LANGUAGE',
            subject: 'ESL',
            assessments: [
              Assessment(
                assessmentId: '17',
                assessmentTitle: 'Mid Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 100,
              ),
              Assessment(
                assessmentId: '18',
                assessmentTitle: 'Annual Term',
                maxMarks: 100,
                passingMarks: 40,
                obtainedMarks: 55,
              ),
              Assessment(
                assessmentId: '19',
                assessmentTitle: 'Preliminary Test (Fall)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 25,
              ),
              Assessment(
                assessmentId: '20',
                assessmentTitle: 'Preliminary Test (Spring)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 7,
              ),
            ],
            aggregateMaxMarks: 250,
            aggregateObtainedMarks: 187,
          ),
          SubjectAssessment(
            learningArea: 'SOCIAL SCIENCES',
            subject: 'GENERAL KNOWLEDGE',
            assessments: [
              Assessment(
                assessmentId: '21',
                assessmentTitle: 'Mid Term',
                maxMarks: 75,
                passingMarks: 30,
                obtainedMarks: 55,
              ),
              Assessment(
                assessmentId: '22',
                assessmentTitle: 'Annual Term',
                maxMarks: 75,
                passingMarks: 30,
                obtainedMarks: 55,
              ),
              Assessment(
                assessmentId: '23',
                assessmentTitle: 'Preliminary Test (Fall)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 20,
              ),
              Assessment(
                assessmentId: '24',
                assessmentTitle: 'Preliminary Test (Spring)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 6,
              ),
            ],
            aggregateMaxMarks: 200,
            aggregateObtainedMarks: 136,
          ),
          SubjectAssessment(
            learningArea: 'CHARACTER BUILDING',
            subject: 'VALUE EDUCATION',
            assessments: [
              Assessment(
                assessmentId: '25',
                assessmentTitle: 'Mid Term',
                maxMarks: 75,
                passingMarks: 30,
                obtainedMarks: 62,
              ),
              Assessment(
                assessmentId: '26',
                assessmentTitle: 'Annual Term',
                maxMarks: 75,
                passingMarks: 30,
                obtainedMarks: 55,
              ),
              Assessment(
                assessmentId: '27',
                assessmentTitle: 'Preliminary Test (Fall)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 18,
              ),
              Assessment(
                assessmentId: '28',
                assessmentTitle: 'Preliminary Test (Spring)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 5,
              ),
            ],
            aggregateMaxMarks: 200,
            aggregateObtainedMarks: 140,
          ),
          SubjectAssessment(
            learningArea: 'DRAWING & SKETCHING',
            subject: 'ART & CRAFT',
            assessments: [
              Assessment(
                assessmentId: '29',
                assessmentTitle: 'Mid Term',
                maxMarks: 75,
                passingMarks: 30,
                obtainedMarks: 70,
              ),
              Assessment(
                assessmentId: '30',
                assessmentTitle: 'Annual Term',
                maxMarks: 75,
                passingMarks: 30,
                obtainedMarks: 55,
              ),
              Assessment(
                assessmentId: '31',
                assessmentTitle: 'Preliminary Test (Fall)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 23,
              ),
              Assessment(
                assessmentId: '32',
                assessmentTitle: 'Preliminary Test (Spring)',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 6,
              ),
            ],
            aggregateMaxMarks: 200,
            aggregateObtainedMarks: 154,
          ),
          SubjectAssessment(
            learningArea: 'EXTRACURRICULAR ACTIVITY',
            subject: 'ASSIGNMENT & CLASSROOM ACTIVITY',
            assessments: [
              Assessment(
                assessmentId: '33',
                assessmentTitle: 'Mid Term',
                maxMarks: 25,
                passingMarks: 15,
                obtainedMarks: 0,
              ),
              Assessment(
                assessmentId: '34',
                assessmentTitle: 'Annual Term',
                maxMarks: 25,
                passingMarks: 0,
                obtainedMarks: 0,
              ),
              Assessment(
                assessmentId: '35',
                assessmentTitle: 'Summer Assignment',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 23,
              ),
              Assessment(
                assessmentId: '36',
                assessmentTitle: 'Winter Assignment',
                maxMarks: 25,
                passingMarks: 10,
                obtainedMarks: 9,
              ),
            ],
            aggregateMaxMarks: 100,
            aggregateObtainedMarks: 32,
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
