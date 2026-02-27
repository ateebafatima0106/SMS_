// ignore_for_file: file_names
/*
class AdmitCardModel {
  final String schoolName;
  final String schoolTagline;
  final String schoolSubTagline;
  final String examTitle;

  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final String admissionNo;
  final String grNo;
  final String seatNo;

  final String? logoUrl;
  final String? photoUrl;

  AdmitCardModel({
    required this.schoolName,
    required this.schoolTagline,
    required this.schoolSubTagline,
    required this.examTitle,
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.admissionNo,
    required this.grNo,
    required this.seatNo,
    this.logoUrl,
    this.photoUrl,
  });
}  
class AdmitCardApiModel {
  final int studentId;
  final int year;
  final int classId;
  final String className; // mapped from "class"
  final int rollNo;
  final String examTypeDesc;
  final String? pic;
  final String grNo;
  final String? section;
  final int seatNo;
  final String fatherName;
  final String name;
  final int taskId;

  AdmitCardApiModel({
    required this.studentId,
    required this.year,
    required this.classId,
    required this.className,
    required this.rollNo,
    required this.examTypeDesc,
    this.pic,
    required this.grNo,
    this.section,
    required this.seatNo,
    required this.fatherName,
    required this.name,
    required this.taskId,
  });

  factory AdmitCardApiModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardApiModel(
      studentId: json["studentId"] ?? 0,
      year: json["year"] ?? 0,
      classId: json["classId"] ?? 0,
      className: json["class"] ?? "", // "class" from API
      rollNo: json["rollNo"] ?? 0,
      examTypeDesc: json["examTypeDesc"] ?? "",
      pic: json["pic"],
      grNo: json["grNo"] ?? "",
      section: json["section"],
      seatNo: json["seatNo"] ?? 0,
      fatherName: (json["fatherName"] ?? "").toString().trim(),
      name: (json["name"] ?? "").toString().trim(),
      taskId: json["taskId"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "studentId": studentId,
      "year": year,
      "classId": classId,
      "class": className,
      "rollNo": rollNo,
      "examTypeDesc": examTypeDesc,
      "pic": pic,
      "grNo": grNo,
      "section": section,
      "seatNo": seatNo,
      "fatherName": fatherName,
      "name": name,
      "taskId": taskId,
    };
  }
} 

// ignore_for_file: file_names

class AdmitCardModel {
  // --- API fields ---
  final int studentId;
  final int year;
  final int classId;
  final int rollNo;
  final String examTypeDesc;
  final String? pic;
  final String grNo;
  final String? section;
  final int seatNo;
  final String fatherName;
  final String name;

  // --- UI fields ---
  final String schoolName;
  final String schoolTagline;
  final String schoolSubTagline;

  AdmitCardModel({
    required this.studentId,
    required this.year,
    required this.classId,
    required this.rollNo,
    required this.examTypeDesc,
    this.pic,
    required this.grNo,
    this.section,
    required this.seatNo,
    required this.fatherName,
    required this.name,
    this.schoolName = "BENCHMARK",
    this.schoolTagline = "School of Leadership",
    this.schoolSubTagline = "PLAY GROUP TO MATRIC",
  });

  /// Factory constructor to parse JSON from API
  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardModel(
      studentId: json['studentId'] ?? 0,
      year: json['year'] ?? 0,
      classId: json['classId'] ?? 0,
      rollNo: json['rollNo'] ?? 0,
      examTypeDesc: json['examTypeDesc'] ?? "",
      pic: json['pic'],
      grNo: json['grNo'] ?? "",
      section: json['section'],
      seatNo: json['seatNo'] ?? 0,
      fatherName: (json['fatherName'] ?? "").trim(),
      name: (json['name'] ?? "").trim(),
    );
  }

  // --- Helper getters for UI/PDF ---
  String get studentName => name;
  String get className => examTypeDesc.contains("GRADE") ? examTypeDesc : "";
  String get admissionNo => rollNo.toString();
  String get seatNoStr => seatNo.toString();
}

// ignore_for_file: file_names

class AdmitCardModel {
  final String schoolName;
  final String schoolTagline;
  final String schoolSubTagline;
  final String examTitle;

  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final String admissionNo;
  final String grNo;
  final String seatNo;

  final String? logoUrl;
  final String? photoUrl;

  AdmitCardModel({
    required this.schoolName,
    required this.schoolTagline,
    required this.schoolSubTagline,
    required this.examTitle,
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.admissionNo,
    required this.grNo,
    required this.seatNo,
    this.logoUrl,
    this.photoUrl,
  });

  /// Parse from API response.
  /// The API may return varied field names — handle common variants.
  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardModel(
      schoolName: (json['schoolName'] ?? json['school_name'] ?? 'BENCHMARK')
          .toString(),
      schoolTagline:
          (json['schoolTagline'] ??
                  json['school_tagline'] ??
                  'School of Leadership')
              .toString(),
      schoolSubTagline:
          (json['schoolSubTagline'] ??
                  json['school_sub_tagline'] ??
                  'PLAY GROUP TO MATRIC')
              .toString(),
      examTitle:
          (json['examTitle'] ?? json['exam_title'] ?? json['taskName'] ?? '')
              .toString(),
      studentName:
          (json['studentName'] ?? json['student_name'] ?? json['name'] ?? '')
              .toString(),
      fatherName:
          (json['fatherName'] ??
                  json['father_name'] ??
                  json['fatherName'] ??
                  '')
              .toString(),
      className:
          (json['className'] ?? json['class_name'] ?? json['classDesc'] ?? '')
              .toString(),
      section: (json['section'] ?? '').toString(),
      admissionNo:
          (json['admissionNo'] ??
                  json['admission_no'] ??
                  json['studentId'] ??
                  '')
              .toString(),
      grNo: (json['grNo'] ?? json['gr_no'] ?? '').toString(),
      seatNo: (json['seatNo'] ?? json['seat_no'] ?? json['rollNo'] ?? '')
          .toString(),
      logoUrl: json['logoUrl'] ?? json['logo_url'],
      photoUrl: json['photoUrl'] ?? json['photo_url'] ?? json['pic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolName': schoolName,
      'schoolTagline': schoolTagline,
      'schoolSubTagline': schoolSubTagline,
      'examTitle': examTitle,
      'studentName': studentName,
      'fatherName': fatherName,
      'className': className,
      'section': section,
      'admissionNo': admissionNo,
      'grNo': grNo,
      'seatNo': seatNo,
      'logoUrl': logoUrl,
      'photoUrl': photoUrl,
    };
  }
}

// ignore_for_file: file_names

class AdmitCardModel {
  final String schoolName;
  final String schoolTagline;
  final String schoolSubTagline;
  final String examTitle;

  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final String admissionNo;
  final String grNo;
  final String seatNo;

  final String? logoUrl;
  final String? photoUrl;

  // Extra fields from API
  final int? year;
  final int? taskId;
  final String? taskName;

  AdmitCardModel({
    required this.schoolName,
    required this.schoolTagline,
    required this.schoolSubTagline,
    required this.examTitle,
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.admissionNo,
    required this.grNo,
    required this.seatNo,
    this.logoUrl,
    this.photoUrl,
    this.year,
    this.taskId,
    this.taskName,
  });

  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardModel(
      schoolName: "BENCHMARK",
      schoolTagline: "School of Leadership",
      schoolSubTagline: "PLAY GROUP TO MATRIC",
      examTitle: json['examTypeDesc'] ?? "",
      studentName: (json['name'] ?? "").toString(),
      fatherName: (json['fatherName'] ?? "").toString(),
      className: (json['class'] ?? "").toString(),
      section: (json['section'] ?? "").toString(),
      admissionNo: (json['rollNo'] ?? "").toString(),
      grNo: (json['grNo'] ?? "").toString(),
      seatNo: (json['seatNo'] ?? "").toString(),
      logoUrl: null,
      photoUrl: json['pic']?.toString(),
      year: json['year'] as int?,
      taskId: json['taskId'] as int?,
      taskName: json['taskName']?.toString(),
    );
  }
}  

class AdmitCardModel {
  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final String grNo;
  final String seatNo;
  final int year;
  final int taskId;
  final String examTitle;

  AdmitCardModel({
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.grNo,
    required this.seatNo,
    required this.year,
    required this.taskId,
    required this.examTitle,
  });

  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardModel(
      studentName: json['name']?.toString().trim() ?? '',
      fatherName: json['fatherName']?.toString().trim() ?? '',
      className: json['class'] ?? '',
      section: json['section'] ?? 'N/A',
      grNo: json['grNo'] ?? '',
      seatNo: json['seatNo']?.toString() ?? '',
      year: json['year'],
      taskId: json['taskId'],
      examTitle: "${json['examTypeDesc']} ${json['year']}",
    );
  }
}  
class AdmitCardModel {
  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final String grNo;
  final String seatNo;
  final int year;
  final int taskId;
  final String examTitle;
  final String? photoUrl; // To be used when DB provides filename

  AdmitCardModel({
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.grNo,
    required this.seatNo,
    required this.year,
    required this.taskId,
    required this.examTitle,
    this.photoUrl,
  });

  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    // If your API returns a filename in "pic", combine it with your base URL
    String? imageUrl;
    if (json['pic'] != null && json['pic'].toString().isNotEmpty) {
      imageUrl = "http://209.126.84.176:2099/uploads/students/${json['pic']}";
    }

    return AdmitCardModel(
      studentName: json['name']?.toString().trim() ?? 'N/A',
      fatherName: json['fatherName']?.toString().trim() ?? 'N/A',
      className: json['class'] ?? 'N/A',
      section: json['section'] ?? 'N/A',
      grNo: json['grNo'] ?? 'N/A',
      seatNo: json['seatNo']?.toString() ?? '0',
      year: json['year'] ?? 0,
      taskId: json['taskId'] ?? 0,
      examTitle: "${json['examTypeDesc']} ${json['year']}",
      photoUrl: imageUrl,
    );
  }
}  
class AdmitCardModel {
  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final String grNo;
  final String seatNo;
  final int year;
  final int taskId;
  final String examTitle;
  final String? photoUrl;

  AdmitCardModel({
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.grNo,
    required this.seatNo,
    required this.year,
    required this.taskId,
    required this.examTitle,
    this.photoUrl,
  });

  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    String? picPath = json['pic'];
    String? finalImageUrl;

    if (picPath != null && picPath.toString().trim().isNotEmpty) {
      // If it's just a filename, prepend the base URL
      finalImageUrl = picPath.startsWith('http') 
          ? picPath 
          : "http://209.126.84.176:2099/uploads/students/$picPath";
    }

    return AdmitCardModel(
      studentName: (json['name'] ?? '').toString().trim(),
      fatherName: (json['fatherName'] ?? '').toString().trim(),
      className: json['class'] ?? 'N/A',
      section: json['section'] ?? 'N/A',
      grNo: json['grNo'] ?? 'N/A',
      seatNo: json['seatNo']?.toString() ?? 'N/A',
      year: json['year'] ?? 0,
      taskId: json['taskId'] ?? 0,
      examTitle: "${json['examTypeDesc'] ?? ''} ${json['year'] ?? ''}".trim(),
      photoUrl: finalImageUrl,
    );
  }
}
class AdmitCardModel {
  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final String admissionNo; // Added for your specific UI grid
  final String grNo;
  final String seatNo;
  final int year;
  final int taskId;
  final String examTitle;
  final String? photoUrl;

  AdmitCardModel({
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.admissionNo,
    required this.grNo,
    required this.seatNo,
    required this.year,
    required this.taskId,
    required this.examTitle,
    this.photoUrl,
  });

  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    String? picPath = json['pic'];
    String? finalImageUrl;

    if (picPath != null && picPath.toString().trim().isNotEmpty) {
      finalImageUrl = picPath.startsWith('http') 
          ? picPath 
          : "http://209.126.84.176:2099/uploads/students/$picPath";
    }

    return AdmitCardModel(
      studentName: (json['name'] ?? '').toString().trim(),
      fatherName: (json['fatherName'] ?? '').toString().trim(),
      className: (json['class'] ?? 'N/A').toString(),
      section: (json['section'] ?? 'N/A').toString(),
      admissionNo: (json['studentId'] ?? 'N/A').toString(), // Mapping ID to Admission No
      grNo: (json['grNo'] ?? 'N/A').toString(),
      seatNo: (json['seatNo'] ?? 'N/A').toString(),
      year: json['year'] ?? 0,
      taskId: json['taskId'] ?? 0,
      examTitle: "${json['examTypeDesc'] ?? ''} Examination ${json['year'] ?? ''}".trim(),
      photoUrl: finalImageUrl,
    );
  }
} */
 /*
class AdmitCardModel {
  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final String grNo;
  final String seatNo;
  final String examTitle;
  final String? photoUrl;
  final int year;
  final int taskId;

  AdmitCardModel({
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.grNo,
    required this.seatNo,
    required this.examTitle,
    this.photoUrl,
    required this.year,
    required this.taskId,
  });

  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardModel(
      studentName: json['studentName'] ?? '',
      fatherName: json['fatherName'] ?? '',
      className: json['className'] ?? '',
      section: json['section'] ?? '',
      grNo: json['grNo']?.toString() ?? '',
      seatNo: json['seatNo']?.toString() ?? '',
      examTitle: json['examTitle'] ?? '',
      photoUrl: json['photoUrl'],
      year: json['year'] ?? 0,
      taskId: json['taskId'] ?? 0,
    );
  }
}  */
// ============================================================
// lib/models/admitcardModel.dart  ← keep your original filename
// ============================================================

class AdmitCardModel {
  final int    studentId;
  final int    classId;
  final int    year;
  final int    taskId;
  final int    rollNo;
  final int    seatNo;
  final String studentName; // API: "name"
  final String fatherName;
  final String className;   // API: "class"
  final String section;
  final String grNo;
  final String examTitle;   // API: "examTypeDesc"
  final String? photoUrl;   // API: "pic"

  AdmitCardModel({
    required this.studentId,
    required this.classId,
    required this.year,
    required this.taskId,
    required this.rollNo,
    required this.seatNo,
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.grNo,
    required this.examTitle,
    this.photoUrl,
  });

  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardModel(
      studentId:   json['studentId']    ?? 0,
      classId:     json['classId']      ?? 0,
      year:        json['year']         ?? 0,
      taskId:      json['taskId']       ?? 0,
      rollNo:      json['rollNo']       ?? 0,
      seatNo:      json['seatNo']       ?? 0,
      studentName: json['name']         ?? '',
      fatherName:  json['fatherName']   ?? '',
      className:   json['class']        ?? '',
      section:     json['section']      ?? '',
      grNo:        json['grNo']?.toString() ?? '',
      examTitle:   json['examTypeDesc'] ?? '',
      photoUrl:    json['pic'],
    );
  }
}