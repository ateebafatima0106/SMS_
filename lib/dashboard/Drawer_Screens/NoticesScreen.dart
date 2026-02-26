import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/models/noticesModel.dart';

class NoticesScreen extends StatelessWidget {
  NoticesScreen({super.key});

  final noticeController = Get.find<NoticesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (noticeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (noticeController.notices.isEmpty) {
          return Center(
            child: Text(
              "No notices yet",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: noticeController.refreshNotices,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: noticeController.notices.length,
            itemBuilder: (context, index) {
              final NoticeModel notice =
                  noticeController.notices[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ======================
                      // Title + NEW Badge
                      // ======================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notice.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),

                          if (notice.isNew) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.4),
                                ),
                              ),
                              child: const Text(
                                "NEW",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ======================
                      // Description
                      // ======================
                      Text(
                        notice.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                            ),
                      ),

                      const SizedBox(height: 14),

                      // ======================
                      // Date
                      // ======================
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "${notice.date.day.toString().padLeft(2, '0')}-"
                          "${notice.date.month.toString().padLeft(2, '0')}-"
                          "${notice.date.year}",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}