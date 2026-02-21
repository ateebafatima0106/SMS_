// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/singleMarksheetController.dart';
import 'package:school_management_system/models/singleMarksheetModel.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MarksheetScreen extends StatelessWidget {
  const MarksheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarksheetController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Marksheet'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: controller.refreshMarksheet,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshMarksheet,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Buttons Row
              _buildActionButtons(context, controller),
              const SizedBox(height: 16),
              // Expandable Filter Section
              _buildExpandableFilters(context, controller),
              const SizedBox(height: 20),
              // Content
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.marksheet.value == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No marksheet data available'),
                    ),
                  );
                }

                final marksheet = controller.marksheet.value!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Info Card
                    _buildStudentInfoCard(context, marksheet.studentInfo),
                    const SizedBox(height: 20),
                    // Subject Marks Table
                    _buildSubjectMarksTable(context, marksheet.subjects),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Build action buttons row
  Widget _buildActionButtons(
    BuildContext context,
    MarksheetController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.toggleFilter,
                icon: Obx(
                  () => Icon(
                    controller.isFilterExpanded.value
                        ? LucideIcons.filter
                        : LucideIcons.filter,
                  ),
                ),
                label: const Text('Filter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isGeneratingPdf.value
                      ? null
                      : controller.generatePdf,
                  icon: controller.isGeneratingPdf.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDarkMode ? Colors.white : Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.fileText),
                  label: Text(
                    controller.isGeneratingPdf.value
                        ? 'Generating...'
                        : 'Generate PDF',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build expandable filters section
  Widget _buildExpandableFilters(
    BuildContext context,
    MarksheetController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: controller.isFilterExpanded.value
            ? Card(
                elevation: 2,
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => _buildDropdown(
                          label: 'Year',
                          value: controller.selectedYear.value,
                          items: controller.yearOptions,
                          onChanged: controller.onYearChanged,
                          icon: LucideIcons.calendar,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => _buildDropdown(
                          label: 'Task Name',
                          value: controller.selectedTask.value,
                          items: controller.taskOptions,
                          onChanged: controller.onTaskChanged,
                          icon: LucideIcons.fileCode,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => _buildDropdown(
                          label: 'Subject',
                          value: controller.selectedSubject.value,
                          items: controller.subjectOptions,
                          onChanged: controller.onSubjectChanged,
                          icon: LucideIcons.bookOpen,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Build dropdown filter
  Widget _buildDropdown({
    required String label,
    required FilterOption? value,
    required List<FilterOption> items,
    required Function(FilterOption?) onChanged,
    required IconData icon,
  }) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: DropdownButtonFormField<FilterOption>(
                value: value,
                dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    size: 20,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                isExpanded: true,
                items: items.map((option) {
                  return DropdownMenuItem<FilterOption>(
                    value: option,
                    child: Text(
                      option.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build student info card
  Widget _buildStudentInfoCard(BuildContext context, StudentInfo info) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Card(
          elevation: 2,
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem('Student Name', info.name),
                      const SizedBox(height: 12),
                      _buildInfoItem('Father Name', info.fatherName),
                      const SizedBox(height: 12),
                      _buildInfoItem('Student ID', info.studentId),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Percentage',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  info.percentage,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Grade',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    info.remarksGrade,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoItem('Student Name', info.name),
                            const SizedBox(height: 12),
                            _buildInfoItem('Father Name', info.fatherName),
                            const SizedBox(height: 12),
                            _buildInfoItem('Student ID', info.studentId),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Percentage',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              info.percentage,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Grade',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                info.remarksGrade,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
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
      },
    );
  }

  /// Build info item for student card
  Widget _buildInfoItem(String label, String value) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build subject marks table
  Widget _buildSubjectMarksTable(
    BuildContext context,
    List<SubjectMark> subjects,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Subject Marks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final columnSpacing = isMobile ? 10.0 : 24.0;
              final horizontalMargin = isMobile ? 8.0 : 24.0;

              final borderColor = isDarkMode
                  ? Colors.grey[700]!
                  : Colors.grey[300]!;
              final availableTableWidth = (constraints.maxWidth - 24).clamp(
                0.0,
                double.infinity,
              );

              return Padding(
                // Extra horizontal padding prevents the last column
                // from visually clipping against card edges on narrow widths.
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    // Ensures a stable viewport width while still allowing
                    // the table to grow and become horizontally scrollable.
                    constraints: BoxConstraints(minWidth: availableTableWidth),
                    child: DataTable(
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: borderColor,
                          width: 1,
                        ),
                        bottom: BorderSide(color: borderColor, width: 1),
                      ),
                      headingRowColor: MaterialStateProperty.all(
                        isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      ),
                      horizontalMargin: horizontalMargin,
                      columnSpacing: columnSpacing,
                      dataRowMinHeight: isMobile ? 44 : 48,
                      dataRowMaxHeight: isMobile ? 56 : 64,
                      columns: [
                        DataColumn(
                          label: Text(
                            'Subject',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            isMobile ? 'Max' : 'Maximum Marks',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            isMobile ? 'Pass' : 'Passing Marks',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            isMobile ? 'Obt.' : 'Obtained Marks',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                      rows: subjects.map((subject) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                subject.subjectName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                subject.maximumMarks.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                subject.passingMarks.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                subject.obtainedMarks.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: subject.isPassed
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
