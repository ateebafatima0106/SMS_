import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:school_management_system/controllers/attendanceController.dart';


class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AttendanceController.to;

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        if (controller.attendanceData.isEmpty) {
          return const Center(child: Text("No attendance records found"));
        }

        final record = controller.attendanceData.first;
        final present = record['present'] ?? 0;
        final absent = record['absent'] ?? 0;
        final total = record['total'] ?? 0;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Present: $present"),
              Text("Absent: $absent"),
              Text("Total: $total"),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _generatePdf(present, absent, total),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Generate PDF"),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _generatePdf(int present, int absent, int total) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "Attendance Record",
                  style:
                       pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Student: EMAN FATIMA"),
              pw.Text("Class: GRADE I"),
              pw.SizedBox(height: 16),
              pw.Text("Total Days: $total"),
              pw.Text("Present: $present"),
              pw.Text("Absent: $absent"),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Attendance_EMAN_FATIMA.pdf',
    );
  }
}