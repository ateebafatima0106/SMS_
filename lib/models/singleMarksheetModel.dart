// ignore_for_file: avoid_print
/* class MarksheetModel {
  final StudentInfo studentInfo;
  final List<SubjectMark> subjects;

  MarksheetModel({required this.studentInfo, required this.subjects});

  factory MarksheetModel.fromJson(Map<String, dynamic> json) {
    return MarksheetModel(
      studentInfo: StudentInfo.fromJson(json['studentInfo']),
      subjects: (json['subjects'] as List)
          .map((e) => SubjectMark.fromJson(e))
          .toList(),
    );
  }
}

class StudentInfo {
  final String name;
  final String rollNo;
  final String className;
  final String session;

  StudentInfo({
    required this.name,
    required this.rollNo,
    required this.className,
    required this.session,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      name: json['name'] ?? "",
      rollNo: json['rollNo'] ?? "",
      className: json['className'] ?? "",
      session: json['session'] ?? "",
    );
  }
}

class SubjectMark {
  final String subjectName;
  final int maximumMarks;
  final int passingMarks;
  final int obtainedMarks;

  SubjectMark({
    required this.subjectName,
    required this.maximumMarks,
    required this.passingMarks,
    required this.obtainedMarks,
  });

  factory SubjectMark.fromJson(Map<String, dynamic> json) {
    return SubjectMark(
      subjectName: json['subjectName'] ?? "",
      maximumMarks: json['maximumMarks'] ?? 0,
      passingMarks: json['passingMarks'] ?? 0,
      obtainedMarks: json['obtainedMarks'] ?? 0,
    );
  }
} */
class MarksheetModel {
  final int studentId;
  final String name;
  final String fatherName;
  final String classDesc;
  final int rollNo;
  final int totalMarks;
  final int passingMarks;
  final int obtMarks;
  final String subjectName;

  MarksheetModel({
    required this.studentId,
    required this.name,
    required this.fatherName,
    required this.classDesc,
    required this.rollNo,
    required this.totalMarks,
    required this.passingMarks,
    required this.obtMarks,
    required this.subjectName,
  });

  factory MarksheetModel.fromJson(Map<String, dynamic> json) {
    return MarksheetModel(
      studentId: json['studentId'] ?? 0,
      name: (json['name'] ?? "").toString().trim(),
      fatherName: (json['fatherName'] ?? "").toString().trim(),
      classDesc: json['classDesc'] ?? "",
      rollNo: json['rollNo'] ?? 0,
      totalMarks: json['totalMarks'] ?? 0,
      passingMarks: json['passingMarks'] ?? 0,
      obtMarks: json['obtMarks'] ?? 0,
      subjectName: json['subjectName'] ?? "",
    );
  }
}
