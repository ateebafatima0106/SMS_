// ============================================================
// lib/utils/admit_card_pdf_generator.dart
// ============================================================

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:school_management_system/models/admitcardModel.dart';

class AdmitCardPdfGenerator {
  // ── Public entry point ────────────────────────────────────────────────────
  static Future<void> generate(AdmitCardModel data) async {
    final pdf = pw.Document();

    // Fonts
    final boldFont      = pw.Font.helveticaBold();
    final regularFont   = pw.Font.helvetica();
    final titleFont     = pw.Font.timesBold();
    final subTitleFont  = pw.Font.timesBoldItalic();

    // Logo
    pw.MemoryImage? logoImage;
    try {
      final bytes = await rootBundle.load('assets/benchmark-logo.jpeg');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context ctx) => pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border.all(color: PdfColors.black, width: 2),
          ),
          padding: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Column(
            children: [
              _header(data, logoImage, titleFont, subTitleFont, boldFont),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                child: _table(data, boldFont, regularFont, logoImage),
              ),
              pw.SizedBox(height: 60),
              _signatures(boldFont),
            ],
          ),
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'AdmitCard_${data.studentName.trim().replaceAll(' ', '_')}.pdf',
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  static pw.Widget _header(
    AdmitCardModel data,
    pw.MemoryImage? logo,
    pw.Font titleFont,
    pw.Font subTitleFont,
    pw.Font boldFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo circle
              pw.Container(
                width: 90,
                height: 90,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.black, width: 2),
                ),
                child: logo != null
                    ? pw.ClipOval(
                        child: pw.Image(logo, fit: pw.BoxFit.cover))
                    : pw.SizedBox(),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'BENCHMARK',
                      style: pw.TextStyle(
                        font: titleFont,
                        fontSize: 24,
                        color: const PdfColor.fromInt(0xFF1E3A8A),
                      ),
                    ),
                    pw.Text(
                      'School of Leadership',
                      style: pw.TextStyle(
                        font: subTitleFont,
                        fontSize: 18,
                        color: const PdfColor.fromInt(0xFF0284C7),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF1E293B),
                        borderRadius:
                            pw.BorderRadius.all(pw.Radius.circular(30)),
                      ),
                      child: pw.Text(
                        'PLAY GROUP TO MATRIC',
                        style: pw.TextStyle(
                          font: boldFont,
                          color: PdfColors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 110), // balance the logo on the left
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'ADMIT CARD',
            style: pw.TextStyle(
                font: boldFont, fontSize: 15, color: PdfColors.black),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            data.examTitle,
            style: pw.TextStyle(
                font: boldFont, fontSize: 13, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  // ── Info Table ────────────────────────────────────────────────────────────
  static pw.Widget _table(
    AdmitCardModel data,
    pw.Font boldFont,
    pw.Font regFont,
    pw.MemoryImage? logo,
  ) {
    return pw.Container(
      decoration:
          pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1.5)),
      child: pw.Column(
        children: [
          // ── Top 3 rows + photo ───────────────────────────────────────────
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 18,
                child: pw.Column(
                  children: [
                    _pdfRow([
                      _pdfCell(6,  "Student's Name", boldFont, isBold: true),
                      _pdfCell(12, data.studentName,  regFont,
                          isCenter: true, borderRight: false),
                    ]),
                    _pdfRow([
                      _pdfCell(6,  "Father's Name", boldFont, isBold: true),
                      _pdfCell(12, data.fatherName,  regFont,
                          isCenter: true, borderRight: false),
                    ]),
                    _pdfRow([
                      _pdfCell(6, 'Class',        boldFont, isBold: true),
                      _pdfCell(6, data.className, regFont,  isCenter: true),
                      _pdfCell(3, 'Section',      boldFont, isBold: true),
                      _pdfCell(3, data.section,   regFont,
                          isCenter: true, borderRight: false),
                    ], borderBottom: false),
                  ],
                ),
              ),
              // Photo placeholder
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  height: 93,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        left: pw.BorderSide(color: PdfColors.black, width: 1)),
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
          // ── Divider ─────────────────────────────────────────────────────
          pw.Container(height: 1, color: PdfColors.black),
          // ── Bottom row ──────────────────────────────────────────────────
          pw.Row(
            children: [
              _pdfCell(4, 'G.R No.',            boldFont, isBold: true),
              _pdfCell(4, data.grNo,            regFont,  isCenter: true),
              _pdfCell(3, 'Seat No.',           boldFont, isBold: true),
              _pdfCell(3, data.seatNo.toString(), regFont,
                  isCenter: true, borderRight: false),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfRow(List<pw.Widget> cells,
      {bool borderBottom = true}) {
    return pw.Container(
      decoration: borderBottom
          ? const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1)))
          : null,
      child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: cells),
    );
  }

  static pw.Widget _pdfCell(
    int flex,
    String text,
    pw.Font font, {
    bool borderRight = true,
    bool isCenter    = false,
    bool isBold      = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: borderRight
            ? const pw.BoxDecoration(
                border: pw.Border(
                    right:
                        pw.BorderSide(color: PdfColors.black, width: 1)))
            : null,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: isCenter ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(
              font: font, fontSize: 11, color: PdfColors.black),
        ),
      ),
    );
  }

  // ── Signature row ─────────────────────────────────────────────────────────
  static pw.Widget _signatures(pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _sigBox('Signature of Controller',    font),
          _sigBox('Signature of Class Teacher', font),
        ],
      ),
    );
  }

  static pw.Widget _sigBox(String label, pw.Font font) {
    return pw.Column(
      children: [
        pw.Container(width: 160, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 8),
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 11)),
      ],
    );
  }
}