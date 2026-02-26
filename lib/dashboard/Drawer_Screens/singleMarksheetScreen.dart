/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/singleMarksheetController.dart';


class MarksheetScreen extends StatelessWidget {
  final MarksheetController controller = Get.put(MarksheetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marksheet")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final marksheet = controller.marksheet.value;
        if (marksheet == null) {
          return const Center(child: Text("No marksheet found"));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Name: ${marksheet.studentInfo.name}"),
              Text("Roll No: ${marksheet.studentInfo.rollNo}"),
              Text("Class: ${marksheet.studentInfo.className}"),
              Text("Session: ${marksheet.studentInfo.session}"),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: marksheet.subjects.length,
                  itemBuilder: (context, index) {
                    final sub = marksheet.subjects[index];
                    return ListTile(
                      title: Text(sub.subjectName),
                      subtitle: Text(
                          "Max: ${sub.maximumMarks}, Pass: ${sub.passingMarks}"),
                      trailing: Text("${sub.obtainedMarks}"),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: controller.isGeneratingPdf.value
                    ? null
                    : controller.generatePdf,
                child: controller.isGeneratingPdf.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Generate PDF"),
              )
            ],
          ),
        );
      }),
    );
  }
}  */


