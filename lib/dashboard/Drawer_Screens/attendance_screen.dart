import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  String selectedMonth = "February";
  bool isFilterExpanded = false;
  bool isGeneratingPdf = false;

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  // Student Info (Dynamic - Replace with actual data from API)
  final Map<String, String> studentInfo = {
    'name': 'EMAN FATIMA',
    'rollNo': '058',
    'fatherName': 'RAFI KHAN',
    'class': 'GRADE I',
  };

  List<Map<String, String>> attendanceRecords = [
    // February 2026 (10 records)
    {"date": "2026-02-01", "month": "February", "status": "Present"},
    {"date": "2026-02-02", "month": "February", "status": "Absent"},
    {"date": "2026-02-03", "month": "February", "status": "Leave"},
    {"date": "2026-02-04", "month": "February", "status": "Leave"},
    {"date": "2026-02-05", "month": "February", "status": "Present"},
    {"date": "2026-02-06", "month": "February", "status": "Absent"},
    {"date": "2026-02-07", "month": "February", "status": "Present"},
    {"date": "2026-02-08", "month": "February", "status": "Present"},
    {"date": "2026-02-09", "month": "February", "status": "Leave"},
    {"date": "2026-02-10", "month": "February", "status": "Present"},

    // March 2026 (10 records)
    {"date": "2026-03-01", "month": "March", "status": "Present"},
    {"date": "2026-03-02", "month": "March", "status": "Absent"},
    {"date": "2026-03-03", "month": "March", "status": "Present"},
    {"date": "2026-03-04", "month": "March", "status": "Leave"},
    {"date": "2026-03-05", "month": "March", "status": "Present"},
    {"date": "2026-03-06", "month": "March", "status": "Present"},
    {"date": "2026-03-07", "month": "March", "status": "Absent"},
    {"date": "2026-03-08", "month": "March", "status": "Present"},
    {"date": "2026-03-09", "month": "March", "status": "Leave"},
    {"date": "2026-03-10", "month": "March", "status": "Present"},

    // April 2026 (10 records)
    {"date": "2026-04-01", "month": "April", "status": "Present"},
    {"date": "2026-04-02", "month": "April", "status": "Absent"},
    {"date": "2026-04-03", "month": "April", "status": "Present"},
    {"date": "2026-04-04", "month": "April", "status": "Leave"},
    {"date": "2026-04-05", "month": "April", "status": "Present"},
    {"date": "2026-04-06", "month": "April", "status": "Present"},
    {"date": "2026-04-07", "month": "April", "status": "Absent"},
    {"date": "2026-04-08", "month": "April", "status": "Present"},
    {"date": "2026-04-09", "month": "April", "status": "Leave"},
    {"date": "2026-04-10", "month": "April", "status": "Present"},

    // May 2026 (10 records)
    {"date": "2026-05-01", "month": "May", "status": "Present"},
    {"date": "2026-05-02", "month": "May", "status": "Absent"},
    {"date": "2026-05-03", "month": "May", "status": "Present"},
    {"date": "2026-05-04", "month": "May", "status": "Leave"},
    {"date": "2026-05-05", "month": "May", "status": "Present"},
    {"date": "2026-05-06", "month": "May", "status": "Present"},
    {"date": "2026-05-07", "month": "May", "status": "Absent"},
    {"date": "2026-05-08", "month": "May", "status": "Present"},
    {"date": "2026-05-09", "month": "May", "status": "Leave"},
    {"date": "2026-05-10", "month": "May", "status": "Present"},

    // June 2026 (10 records)
    {"date": "2026-06-01", "month": "June", "status": "Present"},
    {"date": "2026-06-02", "month": "June", "status": "Absent"},
    {"date": "2026-06-03", "month": "June", "status": "Present"},
    {"date": "2026-06-04", "month": "June", "status": "Leave"},
    {"date": "2026-06-05", "month": "June", "status": "Present"},
    {"date": "2026-06-06", "month": "June", "status": "Present"},
    {"date": "2026-06-07", "month": "June", "status": "Absent"},
    {"date": "2026-06-08", "month": "June", "status": "Present"},
    {"date": "2026-06-09", "month": "June", "status": "Leave"},
    {"date": "2026-06-10", "month": "June", "status": "Present"},

    // July 2026 (10 records)
    {"date": "2026-07-01", "month": "July", "status": "Present"},
    {"date": "2026-07-02", "month": "July", "status": "Absent"},
    {"date": "2026-07-03", "month": "July", "status": "Present"},
    {"date": "2026-07-04", "month": "July", "status": "Leave"},
    {"date": "2026-07-05", "month": "July", "status": "Present"},
    {"date": "2026-07-06", "month": "July", "status": "Present"},
    {"date": "2026-07-07", "month": "July", "status": "Absent"},
    {"date": "2026-07-08", "month": "July", "status": "Present"},
    {"date": "2026-07-09", "month": "July", "status": "Leave"},
    {"date": "2026-07-10", "month": "July", "status": "Present"},

    // August 2026 (10 records)
    {"date": "2026-08-01", "month": "August", "status": "Present"},
    {"date": "2026-08-02", "month": "August", "status": "Absent"},
    {"date": "2026-08-03", "month": "August", "status": "Present"},
    {"date": "2026-08-04", "month": "August", "status": "Leave"},
    {"date": "2026-08-05", "month": "August", "status": "Present"},
    {"date": "2026-08-06", "month": "August", "status": "Present"},
    {"date": "2026-08-07", "month": "August", "status": "Absent"},
    {"date": "2026-08-08", "month": "August", "status": "Present"},
    {"date": "2026-08-09", "month": "August", "status": "Leave"},
    {"date": "2026-08-10", "month": "August", "status": "Present"},

    // September 2026 (10 records)
    {"date": "2026-09-01", "month": "September", "status": "Present"},
    {"date": "2026-09-02", "month": "September", "status": "Absent"},
    {"date": "2026-09-03", "month": "September", "status": "Present"},
    {"date": "2026-09-04", "month": "September", "status": "Leave"},
    {"date": "2026-09-05", "month": "September", "status": "Present"},
    {"date": "2026-09-06", "month": "September", "status": "Present"},
    {"date": "2026-09-07", "month": "September", "status": "Absent"},
    {"date": "2026-09-08", "month": "September", "status": "Present"},
    {"date": "2026-09-09", "month": "September", "status": "Leave"},
    {"date": "2026-09-10", "month": "September", "status": "Present"},

    // October 2026 (10 records)
    {"date": "2026-10-01", "month": "October", "status": "Present"},
    {"date": "2026-10-02", "month": "October", "status": "Absent"},
    {"date": "2026-10-03", "month": "October", "status": "Present"},
    {"date": "2026-10-04", "month": "October", "status": "Leave"},
    {"date": "2026-10-05", "month": "October", "status": "Present"},
    {"date": "2026-10-06", "month": "October", "status": "Present"},
    {"date": "2026-10-07", "month": "October", "status": "Absent"},
    {"date": "2026-10-08", "month": "October", "status": "Present"},
    {"date": "2026-10-09", "month": "October", "status": "Leave"},
    {"date": "2026-10-10", "month": "October", "status": "Present"},

    // November 2026 (10 records)
    {"date": "2026-11-01", "month": "November", "status": "Present"},
    {"date": "2026-11-02", "month": "November", "status": "Absent"},
    {"date": "2026-11-03", "month": "November", "status": "Present"},
    {"date": "2026-11-04", "month": "November", "status": "Leave"},
    {"date": "2026-11-05", "month": "November", "status": "Present"},
    {"date": "2026-11-06", "month": "November", "status": "Present"},
    {"date": "2026-11-07", "month": "November", "status": "Absent"},
    {"date": "2026-11-08", "month": "November", "status": "Present"},
    {"date": "2026-11-09", "month": "November", "status": "Leave"},
    {"date": "2026-11-10", "month": "November", "status": "Present"},

    // December 2026 (10 records)
    {"date": "2026-12-01", "month": "December", "status": "Present"},
    {"date": "2026-12-02", "month": "December", "status": "Absent"},
    {"date": "2026-12-03", "month": "December", "status": "Present"},
    {"date": "2026-12-04", "month": "December", "status": "Leave"},
    {"date": "2026-12-05", "month": "December", "status": "Present"},
    {"date": "2026-12-06", "month": "December", "status": "Present"},
    {"date": "2026-12-07", "month": "December", "status": "Absent"},
    {"date": "2026-12-08", "month": "December", "status": "Present"},
    {"date": "2026-12-09", "month": "December", "status": "Leave"},
    {"date": "2026-12-10", "month": "December", "status": "Present"},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredRecords = attendanceRecords
        .where((record) => record["month"] == selectedMonth)
        .toList();

    int presentCount = filteredRecords
        .where((record) => record["status"] == "Present")
        .length;
    int absentCount = filteredRecords
        .where((record) => record["status"] == "Absent")
        .length;
    int leaveCount = filteredRecords
        .where((record) => record["status"] == "Leave")
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filter and Generate PDF Buttons
            _buildActionButtons(context),

            // Expandable Filter Section
            _buildExpandableFilter(context),

            // Rest of the content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.check_circle,
                          label: "Present",
                          count: presentCount,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.cancel,
                          label: "Absent",
                          count: absentCount,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.event_busy,
                          label: "Leave",
                          count: leaveCount,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Daily Records Header
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Daily Records",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Records List
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: 400,
                      child: filteredRecords.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 48,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No Records for This Month",
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredRecords.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final record = filteredRecords[index];
                                Color statusColor;
                                IconData statusIcon;

                                if (record["status"] == "Present") {
                                  statusColor = const Color(0xFF10B981);
                                  statusIcon = Icons.check_circle;
                                } else if (record["status"] == "Absent") {
                                  statusColor = const Color(0xFFEF4444);
                                  statusIcon = Icons.cancel;
                                } else {
                                  statusColor = const Color(0xFFF59E0B);
                                  statusIcon = Icons.event_busy;
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            record["date"]!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              statusIcon,
                                              size: 14,
                                              color: statusColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              record["status"]!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Action Buttons (Filter and Generate PDF)
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Filter Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  isFilterExpanded = !isFilterExpanded;
                });
              },
              icon: Icon(
                Icons.filter_alt,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Filter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Generate PDF Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isGeneratingPdf ? null : _generatePdf,
              icon: isGeneratingPdf
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      Icons.picture_as_pdf,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              label: Text(
                isGeneratingPdf ? 'Generating...' : 'Generate PDF',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Expandable Filter Section
  Widget _buildExpandableFilter(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isFilterExpanded ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isFilterExpanded ? 1.0 : 0.0,
        child: isFilterExpanded
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Month",
                    filled: true,
                    prefixIcon: Icon(
                      Icons.calendar_month,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  value: selectedMonth,
                  isExpanded: true,
                  items: months.map((month) {
                    return DropdownMenuItem(value: month, child: Text(month));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Build Stat Card
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generate PDF
  Future<void> _generatePdf() async {
    setState(() {
      isGeneratingPdf = true;
    });

    try {
      final pdf = pw.Document();

      // Get filtered records
      final filteredRecords = attendanceRecords
          .where((record) => record["month"] == selectedMonth)
          .toList();

      // Calculate stats
      final presentCount = filteredRecords
          .where((r) => r["status"] == "Present")
          .length;
      final absentCount = filteredRecords
          .where((r) => r["status"] == "Absent")
          .length;
      final leaveCount = filteredRecords
          .where((r) => r["status"] == "Leave")
          .length;
      final totalDays = filteredRecords.length;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildPdfHeader(),
              pw.SizedBox(height: 20),

              // Title
              _buildPdfTitle(),
              pw.SizedBox(height: 20),

              // Student Info
              _buildPdfStudentInfo(),
              pw.SizedBox(height: 20),

              // Month & Summary Side by Side
              _buildPdfMonthAndSummary(
                presentCount,
                absentCount,
                leaveCount,
                totalDays,
              ),
              pw.SizedBox(height: 20),

              // Attendance Table
              _buildPdfAttendanceTable(filteredRecords),
            ],
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Attendance_${studentInfo['name']}_$selectedMonth.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingPdf = false;
        });
      }
    }
  }

  /// Build PDF Header (School Banner)
  pw.Widget _buildPdfHeader() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // School Logo
        pw.Container(
          width: 70,
          height: 70,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(
              color: const PdfColor.fromInt(0xFF1A3A5C),
              width: 2.5,
            ),
            color: PdfColors.white,
          ),
          child: pw.Center(
            child: pw.Icon(
              const pw.IconData(0xe491),
              size: 35,
              color: const PdfColor.fromInt(0xFF1A3A5C),
            ),
          ),
        ),
        pw.SizedBox(width: 16),

        // School Info
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'BENCHMARK',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF1A3A5C),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'School of leadership',
                    style: const pw.TextStyle(
                      fontSize: 18,
                      color: PdfColor.fromInt(0xFF5DADE2),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Container(width: 300, height: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 4),
              pw.Text(
                'PLAY GROUP TO MATRIC',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build PDF Title
  pw.Widget _buildPdfTitle() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            'ATTENDANCE RECORD',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.grey400,
        ),
      ],
    );
  }

  /// Build PDF Student Info
  pw.Widget _buildPdfStudentInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Row 1
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Name: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      studentInfo['name']!,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Roll No: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      studentInfo['rollNo']!,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          // Row 2
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Father Name: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      studentInfo['fatherName']!,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Class: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      studentInfo['class']!,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build PDF Month and Summary (Side by Side)
  pw.Widget _buildPdfMonthAndSummary(
    int present,
    int absent,
    int leave,
    int total,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Month Information
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MONTH INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  height: 1,
                  color: PdfColors.grey400,
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text(
                      'Month: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      selectedMonth,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 16),

        // Attendance Summary
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ATTENDANCE SUMMARY',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  height: 1,
                  color: PdfColors.grey400,
                ),
                pw.SizedBox(height: 8),
                _buildPdfSummaryRow('Total Present:', present.toString()),
                _buildPdfSummaryRow('Total Absent:', absent.toString()),
                _buildPdfSummaryRow('Total Leave:', leave.toString()),
                _buildPdfSummaryRow('Total Days:', total.toString()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build PDF Summary Row
  pw.Widget _buildPdfSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  /// Build PDF Attendance Table
  pw.Widget _buildPdfAttendanceTable(List<Map<String, String>> records) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildPdfTableCell('Sr No', isHeader: true),
            _buildPdfTableCell('Date', isHeader: true),
            _buildPdfTableCell('Status', isHeader: true),
          ],
        ),
        // Data rows
        ...records.asMap().entries.map((entry) {
          return pw.TableRow(
            children: [
              _buildPdfTableCell((entry.key + 1).toString()),
              _buildPdfTableCell(entry.value['date']!),
              _buildPdfTableCell(entry.value['status']!),
            ],
          );
        }),
      ],
    );
  }

  /// Build PDF Table Cell
  pw.Widget _buildPdfTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
