/// Models for Student Fee Module — aligned with real API responses.
///
/// API responses (from Swagger + live testing):
///
/// GET /StudentFee/Get-StudentFees?Year=2026
///   → {success: true, data: [{studentId, year, months, fee, feeDate, slipNo, details}]}
///
/// GET /StudentFee/Get-StudentFeeAdditionals?Year=2026
///   → {success: true, data: [{studentId, year, months, fee, feeDate, slipNo, details}]}
///
/// GET /PendingFee/Get-PendingFee-Tasks?StudentId=792&Year=2026
///   → "No Pending Fee"  OR  list of pending records

// ignore_for_file: dangling_library_doc_comments

/// A single fee record from either Get-StudentFees or Get-StudentFeeAdditionals.
class FeeRecord {
  final int studentId;
  final String year;
  final String month;
  final double fee;
  final String feeDate;
  final int slipNo;
  final String details;

  FeeRecord({
    required this.studentId,
    required this.year,
    required this.month,
    required this.fee,
    required this.feeDate,
    required this.slipNo,
    required this.details,
  });

  factory FeeRecord.fromJson(Map<String, dynamic> json) {
    return FeeRecord(
      studentId: json['studentId'] ?? 0,
      year: (json['year'] ?? '').toString().trim(),
      month: (json['months'] ?? '').toString().trim(),
      fee: (json['fee'] ?? 0).toDouble(),
      feeDate: (json['feeDate'] ?? '').toString().trim(),
      slipNo: json['slipNo'] ?? 0,
      details: (json['details'] ?? 'Monthly Fee').toString().trim(),
    );
  }
}
