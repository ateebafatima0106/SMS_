// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'package:school_management_system/models/student_fee_models.dart';

/// Student Fee Screen
/// - GetX Controller + View pattern
/// - Responsive layout (2-col on tablet/desktop, stacked on mobile)
/// - Search section + Fee history table + PDF generation
class StudentFeeScreen extends GetView<StudentFeeController> {
  const StudentFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Fee')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 900
                      ? 900
                      : constraints.maxWidth * 0.98,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSearchCard(context, isWide),
                    const SizedBox(height: 24),
                    _buildUnpaidMonthsSection(context),
                    const SizedBox(height: 16),
                    _buildFeeHistoryTable(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, bool isWide) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          final student = controller.selectedStudent.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: form + student image
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildLeftForm(context)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildRightForm(context)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    _buildStudentImage(context, student?.imageUrl),
                  ],
                )
              else
                Column(
                  children: [
                    Center(
                      child: _buildStudentImage(context, student?.imageUrl),
                    ),
                    const SizedBox(height: 24),
                    _buildLeftForm(context),
                    const SizedBox(height: 16),
                    _buildRightForm(context),
                  ],
                ),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLeftForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropdown(
          label: 'Department',
          value: controller.selectedDepartment.value,
          items: controller.departments,
          onChanged: (v) => controller.selectedDepartment.value = v ?? '',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.studentNameController,
          label: 'Student Name',
          hint: 'Search student',
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildReadOnlyField(
            label: 'Tuition Fee',
            value: controller.tuitionFee.toStringAsFixed(0),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.receiptNoController,
          label: 'Receipt No',
          hint: 'Enter receipt number',
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildReadOnlyField(
            label: 'Unpaid Months',
            value: controller.unpaidMonthsCount.toString(),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildDropdown(
            label: 'Fee Type',
            value: controller.selectedFeeType.value.displayName,
            items: FeeType.values.map((e) => e.displayName).toList(),
            onChanged: (v) {
              if (v == 'Monthly')
                controller.selectedFeeType.value = FeeType.monthly;
              if (v == 'Yearly')
                controller.selectedFeeType.value = FeeType.yearly;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRightForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => _buildDropdown(
            label: 'Session Year',
            value: controller.selectedSessionYear.value,
            items: controller.sessionYears,
            onChanged: (v) => controller.selectedSessionYear.value = v ?? '',
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.studentIdController,
          label: 'Student ID',
          hint: 'Search by ID',
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildDropdown(
            label: 'Month',
            value: controller.selectedMonth.value,
            items: controller.months,
            onChanged: (v) => controller.selectedMonth.value = v ?? '',
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildDatePickerField(
            label: 'Date',
            date: controller.selectedDate.value,
            onTap: () => _showDatePicker(context),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildDropdown(
            label: 'Year Fee',
            value: controller.selectedYearFee.value,
            items: controller.yearFeeOptions,
            onChanged: (v) => controller.selectedYearFee.value = v ?? '',
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => CheckboxListTile(
            title: Text(
              'Send Message',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            value: controller.sendMessage.value,
            onChanged: (v) => controller.sendMessage.value = v ?? false,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentImage(BuildContext context, String? imageUrl) {
    final theme = Theme.of(context);

    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _photoPlaceholder(context),
              )
            : _photoPlaceholder(context),
      ),
    );
  }

  Widget _photoPlaceholder(BuildContext context) {
    return Center(
      child: Icon(Icons.person, size: 48, color: Theme.of(context).hintColor),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ElevatedButton.icon(
          onPressed: controller.isLoading.value
              ? null
              : controller.searchByReceiptNo,
          icon: const Icon(Icons.search, size: 20),
          label: const Text(
            'Search',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        OutlinedButton.icon(
          onPressed: controller.isLoading.value ? null : _printSlipPdf,
          icon: const Icon(Icons.picture_as_pdf, size: 20),
          label: const Text(
            'Print PDF',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        OutlinedButton.icon(
          onPressed: controller.isLoading.value ? null : _printSlip,
          icon: const Icon(Icons.print, size: 20),
          label: const Text(
            'Print Slip',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        FilledButton.icon(
          onPressed: controller.isLoading.value ? null : controller.submitFee,
          icon: const Icon(Icons.send, size: 20),
          label: const Text(
            'Submit',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<void> _printSlipPdf() async {
    final bytes = await controller.generatePdf();
    if (bytes != null) {
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    }
  }

  Future<void> _printSlip() async {
    final bytes = await controller.generatePdf();
    if (bytes != null) {
      await Printing.sharePdf(bytes: bytes, filename: 'fee-receipt.pdf');
    }
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((d) {
      if (d != null) controller.setSelectedDate(d);
    });
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value.isEmpty && items.isNotEmpty
          ? items.first
          : (items.contains(value) ? value : null),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Date'),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select date',
        ),
      ),
    );
  }

  Widget _buildUnpaidMonthsSection(BuildContext context) {
    return Obx(() {
      if (controller.unpaidMonths.isEmpty) return const SizedBox.shrink();

      final theme = Theme.of(context);
      return Card(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unpaid Months',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.unpaidMonths
                    .map(
                      (m) => Chip(
                        label: Text(
                          m,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        backgroundColor: theme.colorScheme.errorContainer,
                        side: BorderSide(
                          color: theme.colorScheme.error.withOpacity(0.5),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFeeHistoryTable(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.fetchFeeData,
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search, size: 20),
                  label: Text(
                    controller.isLoading.value
                        ? 'Searching...'
                        : 'Search History',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.paidFees.isEmpty &&
                controller.unpaidMonths.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No fee records. Use Search or Search By Receipt No.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                columnSpacing: 32,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Student ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Year',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Month',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Fee Amount',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Fee Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Receipt No',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Unpaid',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Action',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: controller.paidFees
                    .map((r) => _buildDataRow(context, r))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, FeeRecord record) {
    final student = controller.selectedStudent.value;
    return DataRow(
      cells: [
        DataCell(Text(student?.studentId ?? '-')),
        DataCell(Text(record.year)),
        DataCell(Text(record.month)),
        DataCell(Text(record.details)),
        DataCell(Text(record.amount.toStringAsFixed(0))),
        DataCell(
          Text(
            '${record.feeDate.day}/${record.feeDate.month}/${record.feeDate.year}',
          ),
        ),
        DataCell(Text(record.receiptNo)),
        DataCell(Text(record.unpaidMonths.toString())),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _confirmDelete(context, record),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, FeeRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Fee Record'),
        content: Text('Delete receipt ${record.receiptNo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteFeeRecord(record);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
