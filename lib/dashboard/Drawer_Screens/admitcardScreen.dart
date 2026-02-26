import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/admitCardPDF.dart';
import 'package:school_management_system/models/admitcardModel.dart';
/*
class AdmitCardScreen extends StatelessWidget {
  const AdmitCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmitCardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admit Card"),
        actions: [
          Obx(
            () => controller.admitCard.value == null
                ? const SizedBox()
                : IconButton(
                    icon: controller.isGeneratingPdf.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    onPressed: controller.isGeneratingPdf.value
                        ? null
                        : () => _generatePdf(controller),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.admitCard.value;
        if (data == null) {
          return const Center(child: Text("No Data"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _buildAdmitCardUI(data),
            ),
          ),
        );
      }),
    );
  }

  // --- UI PART ---

  Widget _buildAdmitCardUI(AdmitCardModel data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildHeader(data),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTable(data),
          ),
          const SizedBox(height: 40),
          _buildSignatures(),
        ],
      ),
    );
  }

  Widget _buildHeader(AdmitCardModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Logo
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/benchmark-logo.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school, size: 50),
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              children: [
                Text(
                  "BENCHMARK",
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "School of Leadership",
                  style: GoogleFonts.dancingScript(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "PLAY GROUP TO MATRIC",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "ADMIT CARD",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.examTitle,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Balance right side empty space for centering
        ],
      ),
    );
  }

  Widget _buildTable(AdmitCardModel data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        children: [
          // Top Part: Rows 1-3 (left) + Photo (right)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 18,
                  child: Column(
                    children: [
                      _gridRow([
                        _gridCell(6, "Student's Name", isBold: true),
                        _gridCell(
                          12,
                          data.studentName,
                          isCenter: true,
                          borderRight: false,
                        ),
                      ]),
                      _gridRow([
                        _gridCell(6, "Father's Name", isBold: true),
                        _gridCell(
                          12,
                          data.fatherName,
                          isCenter: true,
                          borderRight: false,
                        ),
                      ]),
                      _gridRow([
                        _gridCell(6, "Class", isBold: true),
                        _gridCell(6, data.className, isCenter: true),
                        _gridCell(3, "Section", isBold: true),
                        _gridCell(
                          3,
                          data.section,
                          isCenter: true,
                          borderRight: false,
                        ),
                      ], borderBottom: false),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Center(
                      child: data.photoUrl != null && data.photoUrl!.isNotEmpty
                          ? Image.asset(
                              'assets/benchmark-logo.jpeg', // Using fallback for now
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Part: Row 4
          Container(height: 1, color: Colors.black),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _gridCell(7, "Admission No.", isBold: true),
                _gridCell(6, data.admissionNo, isCenter: true),
                _gridCell(4, "G.R No.", isBold: true),
                _gridCell(4, data.grNo, isCenter: true),
                _gridCell(3, "Seat No.", isBold: true),
                _gridCell(3, data.seatNo, isCenter: true, borderRight: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridRow(List<Widget> cells, {bool borderBottom = true}) {
    return Container(
      decoration: borderBottom
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
            )
          : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ),
    );
  }

  Widget _gridCell(
    int flex,
    String text, {
    bool borderRight = true,
    bool isCenter = false,
    bool isBold = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: borderRight
            ? const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.black, width: 1),
                ),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        alignment: isCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 7,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSignatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _signatureBox("Signature of Controller"),
          _signatureBox("Signature of Class Teacher"),
        ],
      ),
    );
  }

  Widget _signatureBox(String title) {
    return Column(
      children: [
        Container(width: 60, height: 1, color: Colors.black),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 6,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // --- PDF PART ---

  Future<void> _generatePdf(AdmitCardController controller) async {
    controller.isGeneratingPdf.value = true;
    try {
      final data = controller.admitCard.value!;
      final pdf = pw.Document();

      // Load fonts using PdfGoogleFonts from printing package
      final interRegular = pw.Font.helvetica();
      final interBold = pw.Font.helveticaBold();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();

      // Load image from assets
      pw.MemoryImage? logoImage;
      try {
        final ByteData bytes = await rootBundle.load(
          'assets/benchmark-logo.jpeg',
        );
        logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {
        debugPrint("Image load error: $e");
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.black, width: 2),
              ),
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                children: [
                  _buildPdfHeader(
                    data,
                    logoImage,
                    merriweatherBold,
                    dancingScriptBold,
                    interBold,
                    interRegular,
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: _buildPdfTable(
                      data,
                      interBold,
                      interRegular,
                      logoImage,
                    ),
                  ),
                  pw.SizedBox(height: 60),
                  _buildPdfSignatures(interBold),
                ],
              ),
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: "AdmitCard.pdf",
      );
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  pw.Widget _buildPdfHeader(
    AdmitCardModel data,
    pw.MemoryImage? logo,
    pw.Font titleFont,
    pw.Font subTitleFont,
    pw.Font boldFont,
    pw.Font regFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 100,
                height: 100,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.black, width: 2),
                ),
                child: logo != null
                    ? pw.ClipOval(child: pw.Image(logo, fit: pw.BoxFit.cover))
                    : pw.SizedBox(),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "BENCHMARK",
                      style: pw.TextStyle(
                        font: titleFont,
                        fontSize: 25,
                        color: const PdfColor.fromInt(0xFF1E3A8A),
                      ),
                    ),
                    pw.Text(
                      "School of Leadership",
                      style: pw.TextStyle(
                        font: subTitleFont,
                        fontSize: 22,
                        color: const PdfColor.fromInt(0xFF0284C7),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFF1E293B),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(30),
                        ),
                      ),
                      child: pw.Text(
                        "PLAY GROUP TO MATRIC",
                        style: pw.TextStyle(
                          font: boldFont,
                          color: PdfColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 110),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "ADMIT CARD",
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            data.examTitle,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 14,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTable(
    AdmitCardModel data,
    pw.Font boldFont,
    pw.Font regFont,
    pw.MemoryImage? logo,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw
                .CrossAxisAlignment
                .start, // Top aligned to allow height matches
            children: [
              pw.Expanded(
                flex: 18,
                child: pw.Column(
                  children: [
                    _pdfGridRow([
                      _pdfGridCell(6, "Student's Name", boldFont, isBold: true),
                      _pdfGridCell(
                        12,
                        data.studentName,
                        boldFont,
                        isCenter: true,
                        borderRight: false,
                      ),
                    ]),
                    _pdfGridRow([
                      _pdfGridCell(6, "Father's Name", boldFont, isBold: true),
                      _pdfGridCell(
                        12,
                        data.fatherName,
                        boldFont,
                        isCenter: true,
                        borderRight: false,
                      ),
                    ]),
                    _pdfGridRow([
                      _pdfGridCell(6, "Class", boldFont, isBold: true),
                      _pdfGridCell(6, data.className, boldFont, isCenter: true),
                      _pdfGridCell(3, "Section", boldFont, isBold: true),
                      _pdfGridCell(
                        3,
                        data.section,
                        boldFont,
                        isCenter: true,
                        borderRight: false,
                      ),
                    ], borderBottom: false),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  height:
                      93, // (31 * 3) roughly to match 3 rows of height 31 each
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.black, width: 1),
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Center(
                    child: logo != null
                        ? pw.Image(logo, fit: pw.BoxFit.fill)
                        : pw.SizedBox(),
                  ),
                ),
              ),
            ],
          ),
          pw.Container(height: 1, color: PdfColors.black),
          pw.Row(
            children: [
              _pdfGridCell(7, "Admission No.", boldFont, isBold: true),
              _pdfGridCell(6, data.admissionNo, boldFont, isCenter: true),
              _pdfGridCell(4, "G.R No.", boldFont, isBold: true),
              _pdfGridCell(4, data.grNo, boldFont, isCenter: true),
              _pdfGridCell(3, "Seat No.", boldFont, isBold: true),
              _pdfGridCell(
                3,
                data.seatNo,
                boldFont,
                isCenter: true,
                borderRight: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfGridRow(List<pw.Widget> cells, {bool borderBottom = true}) {
    return pw.Container(
      decoration: borderBottom
          ? const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            )
          : null,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: cells,
      ),
    );
  }

  pw.Widget _pdfGridCell(
    int flex,
    String text,
    pw.Font font, {
    bool borderRight = true,
    bool isCenter = false,
    bool isBold = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: borderRight
            ? const pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              )
            : null,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: isCenter ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black),
        ),
      ),
    );
  }

  pw.Widget _buildPdfSignatures(pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _pdfSignatureBox("Signature of Controller", font),
          _pdfSignatureBox("Signature of Class Teacher", font),
        ],
      ),
    );
  }

  pw.Widget _pdfSignatureBox(String title, pw.Font font) {
    return pw.Column(
      children: [
        pw.Container(width: 160, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 8),
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 11)),
      ],
    );
  }
} */

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/models/admitcardModel.dart';
/*
class AdmitCardScreen extends StatelessWidget {
  const AdmitCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmitCardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Admit Card"),
        actions: [
          Obx(() => controller.admitCard.value != null
              ? IconButton(
                  icon: controller.isGeneratingPdf.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.picture_as_pdf),
                  onPressed: () => _generatePdf(controller),
                )
              : const SizedBox()),
        ],
      ),
      body: Column(
        children: [
          _buildDropdownFilters(controller),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.admitCard.value == null) {
                return const Center(child: Text("Please select Year and Exam Type"));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildAdmitCardUI(controller.admitCard.value!),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilters(AdmitCardController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButtonFormField<int>(
              value: controller.selectedYear.value,
              decoration: const InputDecoration(labelText: "Year"),
              items: controller.years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
              onChanged: (val) {
                controller.selectedYear.value = val;
                controller.filterAdmitCard();
              },
            )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() => DropdownButtonFormField<int>(
              value: controller.selectedTaskId.value,
              decoration: const InputDecoration(labelText: "Exam Type"),
              items:controller.tasks.map<DropdownMenuItem<int>>((t) {
  return DropdownMenuItem<int>(
    value: t['taskId'] as int, // Explicitly cast the ID
    child: Text(t['taskName'].toString()),
  );
}).toList(),
              onChanged: (val) {
                controller.selectedTaskId.value = val;
                controller.filterAdmitCard();
              },
            )),
          ),
        ],
      ),
    );
  }

  // --- UI Card Rendering (Flutter) ---
  Widget _buildAdmitCardUI(AdmitCardModel data) {
     return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildHeader(data),
          _buildTable(data),
          const SizedBox(height: 30),
          _buildSignatures(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildHeader(AdmitCardModel data) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text("BENCHMARK", style: GoogleFonts.merriweather(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
          Text("School of Leadership", style: GoogleFonts.dancingScript(fontSize: 14, color: Colors.blue)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
            child: const Text("PLAY GROUP TO MATRIC", style: TextStyle(color: Colors.white, fontSize: 8)),
          ),
          const SizedBox(height: 10),
          Text("ADMIT CARD", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(data.examTitle, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTable(AdmitCardModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Table(
        border: TableBorder.all(color: Colors.black),
        columnWidths: const {4: FixedColumnWidth(80)}, // Space for Photo
        children: [
          TableRow(children: [
            _cell("Name", isBold: true),
            _cell(data.studentName, flex: 2),
            _cell("Photo", isBold: true, rowSpan: 3),
          ]),
          TableRow(children: [
             _cell("Father Name", isBold: true),
             _cell(data.fatherName),
             _photoCell(data.photoUrl), // The Dynamic Image Cell
          ]),
          // ... Add remaining rows similarly
        ],
      ),
    );
  }

  Widget _cell(String text, {bool isBold = false, int flex = 1, int rowSpan = 1}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 10)),
    );
  }

  Widget _photoCell(String? url) {
    return Container(
      height: 80,
      child: url != null 
        ? Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 50))
        : const Icon(Icons.person, size: 50),
    );
  }

  Widget _buildSignatures() {
     return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("__________________\nController", textAlign: TextAlign.center, style: TextStyle(fontSize: 8)),
          Text("__________________\nTeacher", textAlign: TextAlign.center, style: TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  // --- PDF Logic ---
  Future<void> _generatePdf(AdmitCardController controller) async {
  controller.isGeneratingPdf.value = true;
  try {
    final data = controller.admitCard.value!;
    final pdf = pw.Document();

    // 1. Download image bytes if photo exists
    pw.MemoryImage? studentPhoto;
    if (data.photoUrl != null && data.photoUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(data.photoUrl!));
        if (response.statusCode == 200) {
          studentPhoto = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        debugPrint("Image download failed: $e");
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            child: pw.Column(
              children: [
                // Header
                pw.Text("BENCHMARK", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Text(data.examTitle, style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 20),
                
                // Content Table
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Name: ${data.studentName}")),
                      pw.Container(
                        width: 70, height: 70,
                        child: studentPhoto != null ? pw.Image(studentPhoto) : pw.SizedBox()
                      ),
                    ]),
                  ],
                ),
                pw.SizedBox(height: 40),
                // Signatures
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("________________\nController"),
                    pw.Text("________________\nTeacher"),
                  ]
                )
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  } finally {
    controller.isGeneratingPdf.value = false;
  }
}
} 
// --- PDF GENERATION PART ---

  Future<void> _generatePdf(AdmitCardController controller) async {
    controller.isGeneratingPdf.value = true;
    try {
      final data = controller.admitCard.value!;
      final pdf = pw.Document();

      // 1. Load Fonts
      final interRegular = pw.Font.helvetica();
      final interBold = pw.Font.helveticaBold();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();

      // 2. Load School Logo (from Assets)
      pw.MemoryImage? logoImage;
      try {
        final ByteData bytes = await rootBundle.load('assets/benchmark-logo.jpeg');
        logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {
        debugPrint("Logo load error: $e");
      }

      // 3. Load Student Photo (from Network API)
      pw.MemoryImage? studentPhoto;
      if (data.photoUrl != null && data.photoUrl!.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(data.photoUrl!));
          if (response.statusCode == 200) {
            studentPhoto = pw.MemoryImage(response.bodyBytes);
          }
        } catch (e) {
          debugPrint("Student photo download error: $e");
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape, // Keeping landscape as requested
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.black, width: 2),
              ),
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                children: [
                  _buildPdfHeader(
                    data,
                    logoImage,
                    merriweatherBold,
                    dancingScriptBold,
                    interBold,
                    interRegular,
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: _buildPdfTable(
                      data,
                      interBold,
                      interRegular,
                      studentPhoto, // Passing the downloaded student photo
                    ),
                  ),
                  pw.SizedBox(height: 60),
                  _buildPdfSignatures(interBold),
                ],
              ),
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: "AdmitCard_${data.studentName}.pdf",
      );
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  pw.Widget _buildPdfHeader(
    AdmitCardModel data,
    pw.MemoryImage? logo,
    pw.Font titleFont,
    pw.Font subTitleFont,
    pw.Font boldFont,
    pw.Font regFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 100,
                height: 100,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.black, width: 2),
                ),
                child: logo != null
                    ? pw.ClipOval(child: pw.Image(logo, fit: pw.BoxFit.cover))
                    : pw.SizedBox(),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "BENCHMARK",
                      style: pw.TextStyle(
                        font: titleFont,
                        fontSize: 25,
                        color: const PdfColor.fromInt(0xFF1E3A8A),
                      ),
                    ),
                    pw.Text(
                      "School of Leadership",
                      style: pw.TextStyle(
                        font: subTitleFont,
                        fontSize: 22,
                        color: const PdfColor.fromInt(0xFF0284C7),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF1E293B),
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(30)),
                      ),
                      child: pw.Text(
                        "PLAY GROUP TO MATRIC",
                        style: pw.TextStyle(font: boldFont, color: PdfColors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 110),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text("ADMIT CARD", style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.black)),
          pw.SizedBox(height: 8),
          pw.Text(data.examTitle, style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.black)),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTable(AdmitCardModel data, pw.Font boldFont, pw.Font regFont, pw.MemoryImage? photo) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1.5)),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 18,
                child: pw.Column(
                  children: [
                    _pdfGridRow([
                      _pdfGridCell(6, "Student's Name", boldFont, isBold: true),
                      _pdfGridCell(12, data.studentName, boldFont, isCenter: true, borderRight: false),
                    ]),
                    _pdfGridRow([
                      _pdfGridCell(6, "Father's Name", boldFont, isBold: true),
                      _pdfGridCell(12, data.fatherName, boldFont, isCenter: true, borderRight: false),
                    ]),
                    _pdfGridRow([
                      _pdfGridCell(6, "Class", boldFont, isBold: true),
                      _pdfGridCell(6, data.className, boldFont, isCenter: true),
                      _pdfGridCell(3, "Section", boldFont, isBold: true),
                      _pdfGridCell(3, data.section, boldFont, isCenter: true, borderRight: false),
                    ], borderBottom: false),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  height: 93, // Matches 3 rows of content
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(color: PdfColors.black, width: 1)),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Center(
                    child: photo != null
                        ? pw.Image(photo, fit: pw.BoxFit.fill)
                        : pw.Icon(const pw.IconData(0xe7fd), size: 40), // Generic person icon
                  ),
                ),
              ),
            ],
          ),
          pw.Container(height: 1, color: PdfColors.black),
          pw.Row(
            children: [
              _pdfGridCell(7, "Admission No.", boldFont, isBold: true),
              _pdfGridCell(6, data.admissionNo, boldFont, isCenter: true),
              _pdfGridCell(4, "G.R No.", boldFont, isBold: true),
              _pdfGridCell(4, data.grNo, boldFont, isCenter: true),
              _pdfGridCell(3, "Seat No.", boldFont, isBold: true),
              _pdfGridCell(3, data.seatNo, boldFont, isCenter: true, borderRight: false),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfGridRow(List<pw.Widget> cells, {bool borderBottom = true}) {
    return pw.Container(
      decoration: borderBottom
          ? const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)))
          : null,
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: cells),
    );
  }

  pw.Widget _pdfGridCell(int flex, String text, pw.Font font, {bool borderRight = true, bool isCenter = false, bool isBold = false}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: borderRight
            ? const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1)))
            : null,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: isCenter ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black)),
      ),
    );
  }

  pw.Widget _buildPdfSignatures(pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _pdfSignatureBox("Signature of Controller", font),
          _pdfSignatureBox("Signature of Class Teacher", font),
        ],
      ),
    );
  }

  pw.Widget _pdfSignatureBox(String title, pw.Font font) {
    return pw.Column(
      children: [
        pw.Container(width: 160, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 8),
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 11)),
      ],
    );
  } 



class AdmitCardScreen extends StatelessWidget {
  const AdmitCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmitCardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admit Card"),
        actions: [
          Obx(() => controller.admitCard.value == null
              ? const SizedBox()
              : IconButton(
                  icon: controller.isGeneratingPdf.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  onPressed: controller.isGeneratingPdf.value
                      ? null
                      : () => _generatePdf(controller),
                )),
        ],
      ),
      body: Column(
        children: [
          _buildResponsiveFilters(context, controller),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = controller.admitCard.value;
              if (data == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Please select Year and Exam Type to view Admit Card",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  // This allows the card to be scrollable and zoomable on small screens
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 2.5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 850),
                          child: _buildAdmitCardUI(context, data),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- RESPONSIVE FILTERS ---

  Widget _buildResponsiveFilters(
      BuildContext context, AdmitCardController controller) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isMobile
          ? Column(
              children: [
                _yearDropdown(controller),
                const SizedBox(height: 12),
                _taskDropdown(controller),
              ],
            )
          : Row(
              children: [
                Expanded(child: _yearDropdown(controller)),
                const SizedBox(width: 12),
                Expanded(child: _taskDropdown(controller)),
              ],
            ),
    );
  }

  Widget _yearDropdown(AdmitCardController controller) {
    return Obx(() => DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: "Select Year",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: controller.selectedYear.value,
          items: controller.years.map((y) {
            return DropdownMenuItem<int>(value: y, child: Text(y.toString()));
          }).toList(),
          onChanged: (val) {
            controller.selectedYear.value = val;
            controller.filterAdmitCard();
          },
        ));
  }

  Widget _taskDropdown(AdmitCardController controller) {
    return Obx(() => DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: "Exam Type",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: controller.selectedTaskId.value,
          items: controller.tasks.map<DropdownMenuItem<int>>((t) {
            return DropdownMenuItem<int>(
              value: t['taskId'] as int,
              child: Text(t['taskName'].toString()),
            );
          }).toList(),
          onChanged: (val) {
            controller.selectedTaskId.value = val;
            controller.filterAdmitCard();
          },
        ));
  }

  // --- SCREEN UI (ADAPTIVE DESIGN) ---

  Widget _buildAdmitCardUI(BuildContext context, AdmitCardModel data) {
    // Dynamic scaling based on width to prevent overflow
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth < 500 ? (screenWidth / 500) : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: EdgeInsets.only(bottom: 20 * scale),
      child: Column(
        children: [
          _buildHeader(data, scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale),
            child: _buildTable(data, scale),
          ),
          SizedBox(height: 40 * scale),
          _buildSignatures(scale),
        ],
      ),
    );
  }

  Widget _buildHeader(AdmitCardModel data, double scale) {
    return Padding(
      padding: EdgeInsets.all(15 * scale),
      child: Row(
        children: [
          Container(
            width: 70 * scale,
            height: 70 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2 * scale),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/benchmark-logo.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.school, size: 40 * scale),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text("BENCHMARK",
                    style: GoogleFonts.merriweather(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E3A8A))),
                Text("School of Leadership",
                    style: GoogleFonts.dancingScript(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0284C7))),
                SizedBox(height: 5 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text("PLAY GROUP TO MATRIC",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8 * scale,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 8 * scale),
                Text("ADMIT CARD",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 10 * scale)),
                Text(data.examTitle,
                    style: TextStyle(
                        fontSize: 8 * scale, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(width: 70 * scale), // Spacing for symmetry
        ],
      ),
    );
  }

  Widget _buildTable(AdmitCardModel data, double scale) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 1.5)),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 18,
                  child: Column(
                    children: [
                      _gridRow([
                        _gridCell(6, "Student's Name", scale, isBold: true),
                        _gridCell(12, data.studentName, scale,
                            isCenter: true, borderRight: false)
                      ]),
                      _gridRow([
                        _gridCell(6, "Father's Name", scale, isBold: true),
                        _gridCell(12, data.fatherName, scale,
                            isCenter: true, borderRight: false)
                      ]),
                      _gridRow([
                        _gridCell(6, "Class", scale, isBold: true),
                        _gridCell(6, data.className, scale, isCenter: true),
                        _gridCell(3, "Section", scale, isBold: true),
                        _gridCell(3, data.section, scale,
                            isCenter: true, borderRight: false),
                      ], borderBottom: false),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 1))),
                    padding: const EdgeInsets.all(4),
                    child: data.photoUrl != null
                        ? Image.network(data.photoUrl!, fit: BoxFit.contain,
                            errorBuilder: (c, e, s) =>
                                Icon(Icons.person, size: 40 * scale))
                        : Icon(Icons.person, size: 40 * scale),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black),
          IntrinsicHeight(
            child: Row(
              children: [
                _gridCell(7, "Admission No.", scale, isBold: true),
                _gridCell(6, data.admissionNo, scale, isCenter: true),
                _gridCell(4, "G.R No.", scale, isBold: true),
                _gridCell(4, data.grNo, scale, isCenter: true),
                _gridCell(3, "Seat No.", scale, isBold: true),
                _gridCell(3, data.seatNo, scale, isCenter: true, borderRight: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridRow(List<Widget> cells, {bool borderBottom = true}) {
    return Container(
      decoration: borderBottom
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 1)))
          : null,
      child: IntrinsicHeight(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
      ),
    );
  }

  Widget _gridCell(int flex, String text, double scale,
      {bool borderRight = true, bool isCenter = false, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: borderRight
            ? const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black, width: 1)))
            : null,
        padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 8 * scale),
        alignment: isCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(text,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: 8 * scale)),
      ),
    );
  }

  Widget _buildSignatures(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sigCol("Signature of Controller", scale),
          _sigCol("Signature of Class Teacher", scale),
        ],
      ),
    );
  }

  Widget _sigCol(String label, double scale) {
    return Column(
      children: [
        SizedBox(width: 120 * scale, child: const Divider(color: Colors.black)),
        Text(label,
            style: TextStyle(
                fontSize: 7 * scale, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- PDF GENERATION PART (LANDSCAPE A4) ---

  Future<void> _generatePdf(AdmitCardController controller) async {
    controller.isGeneratingPdf.value = true;
    try {
      final data = controller.admitCard.value!;
      final pdf = pw.Document();

      final fontBold = pw.Font.helveticaBold();
      final fontReg = pw.Font.helvetica();

      // Load Assets
      pw.MemoryImage? logoImage;
      try {
        final ByteData bytes =
            await rootBundle.load('assets/benchmark-logo.jpeg');
        logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {
        debugPrint("Logo error: $e");
      }

      // Load Student Photo
      pw.MemoryImage? studentPhoto;
      if (data.photoUrl != null && data.photoUrl!.isNotEmpty) {
        try {
          final res = await http.get(Uri.parse(data.photoUrl!));
          if (res.statusCode == 200) studentPhoto = pw.MemoryImage(res.bodyBytes);
        } catch (e) {
          debugPrint("Photo fetch error: $e");
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 2),
              ),
              child: pw.Column(
                children: [
                  _pdfHeader(data, logoImage, fontBold),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: _pdfTable(data, fontBold, studentPhoto),
                  ),
                  pw.SizedBox(height: 60),
                  _pdfSignatures(fontBold),
                ],
              ),
            );
          },
        ),
      );

      await Printing.sharePdf(
          bytes: await pdf.save(), filename: "AdmitCard_${data.studentName}.pdf");
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  pw.Widget _pdfHeader(AdmitCardModel data, pw.MemoryImage? logo, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Row(children: [
        pw.Container(
          width: 80, height: 80,
          decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(width: 2)),
          child: logo != null ? pw.ClipOval(child: pw.Image(logo, fit: pw.BoxFit.cover)) : pw.SizedBox(),
        ),
        pw.Expanded(child: pw.Column(children: [
          pw.Text("BENCHMARK", style: pw.TextStyle(font: bold, fontSize: 22, color: PdfColor.fromInt(0xFF1E3A8A))),
          pw.Text("School of Leadership", style: pw.TextStyle(fontSize: 18, color: PdfColor.fromInt(0xFF0284C7))),
          pw.SizedBox(height: 10),
          pw.Text("ADMIT CARD", style: pw.TextStyle(font: bold, fontSize: 14)),
          pw.Text(data.examTitle, style: const pw.TextStyle(fontSize: 12)),
        ])),
        pw.SizedBox(width: 80),
      ]),
    );
  }

  pw.Widget _pdfTable(AdmitCardModel data, pw.Font bold, pw.MemoryImage? photo) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
      child: pw.Column(children: [
        pw.Row(children: [
          pw.Expanded(flex: 18, child: pw.Column(children: [
            _pdfGridRow([_pdfGridCell(6, "Student's Name", bold), _pdfGridCell(12, data.studentName, bold, center: true, noBorder: true)]),
            _pdfGridRow([_pdfGridCell(6, "Father's Name", bold), _pdfGridCell(12, data.fatherName, bold, center: true, noBorder: true)]),
            _pdfGridRow([
              _pdfGridCell(6, "Class", bold), _pdfGridCell(6, data.className, bold, center: true),
              _pdfGridCell(3, "Section", bold), _pdfGridCell(3, data.section, bold, center: true, noBorder: true),
            ], last: true),
          ])),
          pw.Expanded(flex: 5, child: pw.Container(
            height: 82, decoration: const pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(width: 1))),
            padding: const pw.EdgeInsets.all(5),
            child: photo != null ? pw.Image(photo, fit: pw.BoxFit.contain) : pw.SizedBox(),
          )),
        ]),
        pw.Container(height: 1, color: PdfColors.black),
        pw.Row(children: [
          _pdfGridCell(7, "Admission No.", bold), _pdfGridCell(6, data.admissionNo, bold, center: true),
          _pdfGridCell(4, "G.R No.", bold), _pdfGridCell(4, data.grNo, bold, center: true),
          _pdfGridCell(3, "Seat No.", bold), _pdfGridCell(3, data.seatNo, bold, center: true, noBorder: true),
        ]),
      ]),
    );
  }

  pw.Widget _pdfGridRow(List<pw.Widget> cells, {bool last = false}) {
    return pw.Container(
      decoration: last ? null : const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 1))),
      child: pw.Row(children: cells),
    );
  }

  pw.Widget _pdfGridCell(int flex, String text, pw.Font font, {bool center = false, bool noBorder = false}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: noBorder ? null : const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 1))),
        padding: const pw.EdgeInsets.all(8),
        alignment: center ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10)),
      ),
    );
  }

  pw.Widget _pdfSignatures(pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 50),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        _pdfSigBox("Signature of Controller", bold),
        _pdfSigBox("Signature of Class Teacher", bold),
      ]),
    );
  }

  pw.Widget _pdfSigBox(String label, pw.Font bold) {
    return pw.Column(children: [
      pw.Container(width: 150, height: 1, color: PdfColors.black),
      pw.SizedBox(height: 5),
      pw.Text(label, style: pw.TextStyle(font: bold, fontSize: 10)),
    ]);
  }
} */
  /*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// Prefixing PDF to avoid Red Screen CrossAxisAlignment error
import 'package:pdf/widgets.dart' as pw hide Column, Row, Center, Text, CrossAxisAlignment, Container, Padding, Widget, Expanded, SizedBox, Divider, IntrinsicHeight, Table, Border, BorderSide, Alignment, BoxDecoration, TextStyle, FontWeight, Color, EdgeInsets, BoxConstraints, ConstrainedBox, LayoutBuilder, SingleChildScrollView, InteractiveViewer, Image, ClipOval, Icon, Icons;


class AdmitCardScreen extends StatelessWidget {
  const AdmitCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmitCardController());

    return Scaffold(
      appBar: AppBar(title: const Text("Admit Card")),
      body: Column(
        children: [
          _buildFilters(context, controller),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              
              final data = controller.admitCard.value;
              if (data == null) {
                return const Center(child: Text("Please select Year and Exam Type"));
              }

              return InteractiveViewer(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: _buildCardUI(context, data),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, AdmitCardController controller) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: isMobile 
        ? Column(children: _filterDropdowns(controller))
        : Row(children: _filterDropdowns(controller).map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: w))).toList()),
    );
  }

  List<Widget> _filterDropdowns(AdmitCardController controller) {
    return [
      Obx(() => DropdownButtonFormField<int>(
        decoration: const InputDecoration(labelText: "Select Year", border: OutlineInputBorder()),
        value: controller.selectedYear.value,
        items: controller.years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
        onChanged: (val) {
          controller.selectedYear.value = val;
          controller.fetchAdmitCard();
        },
      )),
      const SizedBox(height: 12),
      Obx(() => DropdownButtonFormField<int>(
        decoration: const InputDecoration(labelText: "Exam Type", border: OutlineInputBorder()),
        value: controller.selectedTaskId.value,
        items: controller.tasks.map((t) => DropdownMenuItem(
          value: t['taskId'] as int, 
          child: Text(t['taskName'])
        )).toList(),
        onChanged: (val) {
          controller.selectedTaskId.value = val;
          controller.fetchAdmitCard();
        },
      )),
    ];
  }

  Widget _buildCardUI(BuildContext context, AdmitCardModel data) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth < 550 ? (screenWidth / 550) : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: EdgeInsets.all(20 * scale),
      child: Column(
        children: [
          Text("BENCHMARK SCHOOL SYSTEM", 
              style: GoogleFonts.merriweather(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
          Text("ADMIT CARD", 
              style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 5),
          Text(data.examTitle.toUpperCase(), style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _infoTable(data, scale),
          SizedBox(height: 40 * scale),
          _signatures(scale),
        ],
      ),
    );
  }

  Widget _infoTable(AdmitCardModel data, double scale) {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 1.2),
      columnWidths: const {4: IntrinsicColumnWidth()},
      children: [
        TableRow(children: [
          _cell("Student Name", scale, isBold: true),
          _cell(data.studentName, scale, span: 3),
          _photoCell(data.photoUrl, scale),
        ]),
        TableRow(children: [
          _cell("Father Name", scale, isBold: true),
          _cell(data.fatherName, scale, span: 3),
          _emptyCell(),
        ]),
        TableRow(children: [
          _cell("Class / Sec", scale, isBold: true),
          _cell("${data.className} - ${data.section}", scale),
          _cell("GR No.", scale, isBold: true),
          _cell(data.grNo, scale),
          _emptyCell(),
        ]),
      ],
    );
  }

  Widget _cell(String text, double scale, {bool isBold = false, int span = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 12 * scale),
      child: Text(text, style: TextStyle(fontSize: 10 * scale, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _photoCell(String? url, double scale) {
    return Container(
      height: 110 * scale,
      padding: const EdgeInsets.all(4),
      child: url != null && url.isNotEmpty 
        ? Image.network(url, fit: BoxFit.contain) 
        : const Icon(Icons.account_box, size: 60),
    );
  }

  Widget _emptyCell() => const SizedBox.shrink();

  Widget _signatures(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sigLine("Controller of Exams", scale),
          _sigLine("Principal / Teacher", scale),
        ],
      ),
    );
  }

  Widget _sigLine(String label, double scale) {
    return Column(
      children: [
        Container(width: 130 * scale, height: 1, color: Colors.black),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 8 * scale, fontWeight: FontWeight.bold)),
      ],
    );
  }
}  */
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AdmitCardScreen extends StatelessWidget {
  const AdmitCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmitCardController());

    return Scaffold(
      appBar: AppBar(title: const Text("Admit Card")),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // YEAR DROPDOWN
                Expanded(
                  child: Obx(() => DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder()),
                    value: controller.selectedYear.value,
                    items: controller.years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                    onChanged: (val) {
                      controller.selectedYear.value = val;
                      controller.fetchAdmitCard();
                    },
                  )),
                ),
                const SizedBox(width: 10),
                // TASK DROPDOWN
                Expanded(
                  child: Obx(() => DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Term", border: OutlineInputBorder()),
                    value: controller.selectedTaskId.value,
                    items: controller.tasks.map((t) => DropdownMenuItem(
                      value: t['taskId'] as int, 
                      child: Text(t['taskName'])
                    )).toList(),
                    onChanged: (val) {
                      controller.selectedTaskId.value = val;
                      controller.fetchAdmitCard();
                    },
                  )),
                ),
              ],
            ),
          ),
          
          const Divider(),

          // RESULT SECTION
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              
              final data = controller.admitCard.value;
              if (data == null) return const Center(child: Text("Select Term and Year to view card"));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCardUI(data),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildCardUI(dynamic data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(width: 2)),
      child: Column(
        children: [
          const Text("BENCHMARK SCHOOL SYSTEM", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("ADMIT CARD", style: TextStyle(letterSpacing: 2)),
          const SizedBox(height: 20),
          _row("Student Name", data.studentName),
          _row("Father Name", data.fatherName),
          _row("Class", data.className),
          _row("GR No.", data.grNo),
          const Divider(height: 30),
          Text(data.examTitle, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ]),
    );
  }
}  */

// ============================================================
// lib/screens/admit_card_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';

class AdmitCardScreen extends StatelessWidget {
  const AdmitCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmitCardController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Admit Card'),
        actions: [
          Obx(() {
            if (controller.currentAdmitCard.value == null) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: 'Generate PDF',
              icon: controller.isGeneratingPdf.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf),
              onPressed: controller.isGeneratingPdf.value
                  ? null
                  : () => _onGeneratePdf(controller),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            // ── Dropdowns ──────────────────────────────────────────────
            _DropdownRow(controller: controller),
            // ── Admit Card / Empty State ────────────────────────────────
            Expanded(
              child: controller.currentAdmitCard.value == null
                  ? _EmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: _AdmitCardWidget(
                              data: controller.currentAdmitCard.value!),
                        ),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _onGeneratePdf(AdmitCardController controller) async {
    controller.isGeneratingPdf.value = true;
    try {
      await AdmitCardPdfGenerator.generate(controller.currentAdmitCard.value!);
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Dropdown Row
// ══════════════════════════════════════════════════════════════════════════════
class _DropdownRow extends StatelessWidget {
  const _DropdownRow({required this.controller});
  final AdmitCardController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(
        () => Row(
          children: [
            // ── Year Dropdown ───────────────────────────────────────────
            Expanded(
              child: _StyledDropdown<int>(
                label: 'Year',
                value: controller.selectedYear.value,
                items: controller.years,
                itemLabel: (y) => y.toString(),
                onChanged: controller.onYearChanged,
              ),
            ),
            const SizedBox(width: 12),
            // ── Task Dropdown ───────────────────────────────────────────
            Expanded(
              child: _StyledDropdown<Map<String, dynamic>>(
                label: 'Term',
                value: controller.selectedTask.value,
                items: controller.tasks,
                itemLabel: (t) => t['taskName']?.toString() ?? '',
                onChanged: controller.onTaskChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: GoogleFonts.inter(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Empty State
// ══════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No Admit Card Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try selecting a different year or term.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Admit Card Visual Widget  (unchanged from original design)
// ══════════════════════════════════════════════════════════════════════════════
class _AdmitCardWidget extends StatelessWidget {
  const _AdmitCardWidget({required this.data});
  final AdmitCardModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTable(),
          ),
          const SizedBox(height: 40),
          _buildSignatures(),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Logo
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/benchmark-logo.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.school, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Text(
                  'BENCHMARK',
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'School of Leadership',
                  style: GoogleFonts.dancingScript(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PLAY GROUP TO MATRIC',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'ADMIT CARD',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.examTitle,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Table ─────────────────────────────────────────────────────────────
  Widget _buildTable() {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 1.5)),
      child: Column(
        children: [
          // Top 3 rows + photo
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 18,
                  child: Column(
                    children: [
                      _gridRow([
                        _gridCell(6, "Student's Name", isBold: true),
                        _gridCell(12, data.studentName,
                            isCenter: true, borderRight: false),
                      ]),
                      _gridRow([
                        _gridCell(6, "Father's Name", isBold: true),
                        _gridCell(12, data.fatherName,
                            isCenter: true, borderRight: false),
                      ]),
                      _gridRow([
                        _gridCell(6, 'Class',        isBold: true),
                        _gridCell(6, data.className, isCenter: true),
                        _gridCell(3, 'Section',      isBold: true),
                        _gridCell(3, data.section,
                            isCenter: true, borderRight: false),
                      ], borderBottom: false),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          left: BorderSide(color: Colors.black, width: 1)),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Center(
                      child: (data.photoUrl != null &&
                              data.photoUrl!.isNotEmpty)
                          ? Image.network(data.photoUrl!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  ))
                          : const Icon(Icons.person,
                              size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(height: 1, color: Colors.black),
          // Bottom row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _gridCell(4, 'G.R No.',   isBold: true),
                _gridCell(4, data.grNo,   isCenter: true),
                _gridCell(3, 'Seat No.',  isBold: true),
                _gridCell(3, data.seatNo.toString(),
                    isCenter: true, borderRight: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridRow(List<Widget> cells, {bool borderBottom = true}) {
    return Container(
      decoration: borderBottom
          ? const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.black, width: 1)))
          : null,
      child: IntrinsicHeight(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells),
      ),
    );
  }

  Widget _gridCell(
    int flex,
    String text, {
    bool borderRight = true,
    bool isCenter    = false,
    bool isBold      = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: borderRight
            ? const BoxDecoration(
                border: Border(
                    right: BorderSide(color: Colors.black, width: 1)))
            : null,
        padding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        alignment: isCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 7,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ── Signatures ─────────────────────────────────────────────────────────────
  Widget _buildSignatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _signatureBox('Signature of Controller'),
          _signatureBox('Signature of Class Teacher'),
        ],
      ),
    );
  }

  Widget _signatureBox(String title) {
    return Column(
      children: [
        Container(width: 60, height: 1, color: Colors.black),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 6,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}