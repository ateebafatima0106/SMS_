import sys

file_path = "/Users/mac/Desktop/ati_work/SMS/lib/dashboard/Drawer_Screens/admitcardScreen.dart"

with open(file_path, "r") as f:
    lines = f.readlines()

output = []
for line in lines:
    if "// --- PDF PART ---" in line:
        break
    output.append(line)

new_code = """  // --- PDF PART ---

  Future<void> _generatePdf(AdmitCardController controller) async {
    controller.isGeneratingPdf.value = true;
    try {
      final pdf = pw.Document();

      // Use standard built-in fonts for stability and professional look
      final regularFont = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      // Load image from assets for student photo substitution
      pw.MemoryImage? photoImage;
      try {
        final ByteData bytes = await rootBundle.load('assets/benchmark-logo.jpeg');
        photoImage = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {
        debugPrint("Image load error: $e");
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildTranscriptHeader(boldFont, photoImage),
                pw.SizedBox(height: 15),
                _buildTranscriptSummaryTable(boldFont, regularFont),
                pw.SizedBox(height: 15),
                _buildTranscriptGradesTable(boldFont, regularFont),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: "Transcript.pdf",
      );
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  pw.Widget _buildTranscriptHeader(pw.Font boldFont, pw.MemoryImage? photo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title block
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 10),
              pw.Text("TRANSCRIPT", style: pw.TextStyle(font: boldFont, fontSize: 32, color: const PdfColor.fromInt(0xFF1E3A8A))),
              pw.SizedBox(height: 10),
              pw.Text("FOR THE ACADEMIC YEAR 2025 - 2026", style: pw.TextStyle(font: boldFont, fontSize: 18, color: const PdfColor.fromInt(0xFF1E3A8A))),
            ],
          ),
        ),
        // Photo block
        pw.Container(
          width: 80,
          height: 90,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          child: photo != null ? pw.Image(photo, fit: pw.BoxFit.cover) : pw.SizedBox(),
        ),
      ],
    );
  }

  pw.Widget _pdfCell({
    required int flex,
    required String text,
    required pw.Font font,
    double fontSize = 8,
    bool alignCenter = true,
    bool borderR = true,
    PdfColor? bgColor,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: bgColor,
          border: borderR ? const pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1)) : null,
        ),
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        alignment: alignCenter ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          textAlign: alignCenter ? pw.TextAlign.center : pw.TextAlign.left,
          style: pw.TextStyle(font: font, fontSize: fontSize, color: PdfColors.black),
        ),
      ),
    );
  }

  pw.Widget _buildTranscriptSummaryTable(pw.Font boldFont, pw.Font regFont) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
      child: pw.Column(
        children: [
          // Row 1
          pw.Container(
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _pdfCell(flex: 15, text: "Student\'s\\nName", font: boldFont, alignCenter: false),
                _pdfCell(flex: 35, text: "ANAIZA FATIMA", font: regFont, fontSize: 9),
                _pdfCell(flex: 12, text: "Std. Id", font: boldFont),
                _pdfCell(flex: 12, text: "Class", font: boldFont),
                _pdfCell(flex: 26, text: "MONT JUNIOR", font: regFont, borderR: false, fontSize: 9),
              ],
            ),
          ),
          // Row 2
          pw.Container(
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _pdfCell(flex: 15, text: "Father\'s\\nName", font: boldFont, alignCenter: false),
                _pdfCell(flex: 35, text: "MD SUHAIL KHAN", font: regFont, fontSize: 9),
                _pdfCell(flex: 12, text: "506", font: regFont),
                _pdfCell(flex: 12, text: "Roll #", font: boldFont),
                _pdfCell(flex: 26, text: "29", font: regFont, borderR: false, fontSize: 9),
              ],
            ),
          ),
          // Row 3
          pw.Container(
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _pdfCell(flex: 15, text: "Result", font: boldFont, alignCenter: false),
                _pdfCell(flex: 35, text: "TRY AGAIN", font: regFont, fontSize: 9),
                _pdfCell(flex: 12, text: "Max.\\nMarks", font: boldFont),
                _pdfCell(flex: 12, text: "1950", font: regFont, fontSize: 9),
                _pdfCell(flex: 13, text: "Percentage", font: boldFont),
                _pdfCell(flex: 13, text: "66.67 %", font: regFont, borderR: false, fontSize: 9),
              ],
            ),
          ),
          // Row 4
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _pdfCell(flex: 15, text: "Position", font: boldFont, alignCenter: false),
              _pdfCell(flex: 35, text: "", font: regFont),
              _pdfCell(flex: 12, text: "Obt.\\nMarks", font: boldFont),
              _pdfCell(flex: 12, text: "1300", font: regFont, fontSize: 9),
              _pdfCell(flex: 13, text: "Grade", font: boldFont),
              _pdfCell(flex: 13, text: "B", font: regFont, borderR: false, fontSize: 9),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTranscriptGradesTable(pw.Font boldFont, pw.Font regFont) {
    const PdfColor headerColor = PdfColor.fromInt(0xFFCFD8DC); // Grey header 
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
      child: pw.Column(
        children: [
          // Header Row
          pw.Container(
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _pdfCell(flex: 18, text: "Learning Area", font: boldFont, bgColor: headerColor),
                _pdfCell(flex: 15, text: "Subject", font: boldFont, bgColor: headerColor),
                _pdfCell(flex: 25, text: "Assesment Title", font: boldFont, bgColor: headerColor),
                _pdfCell(flex: 8, text: "Max\\nMarks", font: boldFont, bgColor: headerColor),
                _pdfCell(flex: 8, text: "Passing\\nMarks", font: boldFont, bgColor: headerColor),
                _pdfCell(flex: 8, text: "Obt\\nMarks", font: boldFont, bgColor: headerColor),
                _pdfCell(flex: 18, text: "Agg.\\nMarks", font: boldFont, bgColor: headerColor, borderR: false),
              ],
            ),
          ),
          // Groups
          _buildScoreGroup("RELIGION", "ISLAMIAT", "183", [
            ["Mid Term", "100", "40", "96"],
            ["Annual Term", "100", "40", "55"],
            ["Preliminary Test (Fall)", "25", "10", "25"],
            ["Preliminary Test (Spring)", "25", "10", "7"],
          ], boldFont, regFont),
          _buildScoreGroup("NATIVE LANGUAGE", "URDU", "160", [
            ["Mid Term", "100", "40", "78"],
            ["Annual Term", "100", "40", "55"],
            ["Preliminary Test (Fall)", "25", "10", "22"],
            ["Preliminary Test (Spring)", "25", "10", "5"],
          ], boldFont, regFont),
          _buildScoreGroup("INTERNATIONAL LANGUAGE", "ENGLISH", "146", [
            ["Mid Term", "100", "40", "61"],
            ["Annual Term", "100", "40", "55"],
            ["Preliminary Test (Fall)", "25", "10", "22"],
            ["Preliminary Test (Spring)", "25", "10", "8"],
          ], boldFont, regFont),
          _buildScoreGroup("CONCEPT DEVELOPMENT", "MATHEMATICS", "162", [
            ["Mid Term", "100", "40", "73"],
            ["Annual Term", "100", "40", "55"],
            ["Preliminary Test (Fall)", "25", "10", "25"],
            ["Preliminary Test (Spring)", "25", "10", "9"],
          ], boldFont, regFont),
          _buildScoreGroup("INTERNATIONAL LANGUAGE", "ESL", "187", [
            ["Mid Term", "100", "40", "100"],
            ["Annual Term", "100", "40", "55"],
            ["Preliminary Test (Fall)", "25", "10", "25"],
            ["Preliminary Test (Spring)", "25", "10", "7"],
          ], boldFont, regFont),
          _buildScoreGroup("SOCIAL SCIENCES", "GENERAL KNOWLEDGE", "136", [
            ["Mid Term", "75", "30", "55"],
            ["Annual Term", "75", "30", "55"],
            ["Preliminary Test (Fall)", "25", "10", "20"],
            ["Preliminary Test (Spring)", "25", "10", "6"],
          ], boldFont, regFont),
          _buildScoreGroup("CHARACTER BUILDING", "VALUE EDUCATION", "140", [
            ["Mid Term", "75", "30", "62"],
            ["Annual Term", "75", "30", "55"],
            ["Preliminary Test (Fall)", "25", "10", "18"],
            ["Preliminary Test (Spring)", "25", "10", "5"],
          ], boldFont, regFont),
          _buildScoreGroup("DRAWING & SKETCHING", "ART & CRAFT", "154", [
            ["Mid Term", "75", "30", "70"],
            ["Annual Term", "75", "30", "55"],
            ["Preliminary Test (Fall)", "25", "10", "23"],
            ["Preliminary Test (Spring)", "25", "10", "6"],
          ], boldFont, regFont),
          _buildScoreGroup("EXTRACURRICULAR\\nACTIVITY", "ASSIGNMENT &\\nCLASSROOM ACTIVITY", "32", [
            ["Mid Term", "25", "15", "0"],
            ["Annual Term", "25", "0", "0"],
            ["Summer Assignment", "25", "10", "23"],
            ["Winter Assignment", "25", "10", "9"],
          ], boldFont, regFont, borderBottom: false),
        ],
      ),
    );
  }

  pw.Widget _buildScoreGroup(String area, String subject, String agg, List<List<String>> rows, pw.Font boldFont, pw.Font regFont, {bool borderBottom = true}) {
    final List<pw.Widget> innerRows = [];
    for (int i = 0; i < rows.length; i++) {
      final isLast = i == rows.length - 1;
      innerRows.add(
        pw.Container(
          decoration: isLast ? null : const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _pdfCell(flex: 25, text: rows[i][0], font: regFont, alignCenter: false),
              _pdfCell(flex: 8, text: rows[i][1], font: regFont),
              _pdfCell(flex: 8, text: rows[i][2], font: regFont),
              _pdfCell(flex: 8, text: rows[i][3], font: regFont, borderR: false),
            ],
          ),
        ),
      );
    }

    return pw.Container(
      decoration: borderBottom ? const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))) : null,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _pdfCell(flex: 18, text: area, font: boldFont, fontSize: 7),
          _pdfCell(flex: 15, text: subject, font: boldFont, fontSize: 7),
          pw.Expanded(
            flex: 49,
            child: pw.Container(
              decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1))),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: innerRows,
              ),
            ),
          ),
          _pdfCell(flex: 18, text: agg, font: regFont, borderR: false, fontSize: 9),
        ],
      ),
    );
  }
}
"""

with open(file_path, "w") as f:
    f.writelines(output)
    f.write(new_code)
