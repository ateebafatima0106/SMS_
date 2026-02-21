import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NoticesSection extends StatelessWidget {
  const NoticesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notices = [
      {
        'title': 'Midterm Exams Start',
        'date': 'Feb 15th',
        'icon': LucideIcons.calendar,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Fee Reminder',
        'date': 'Feb 20th',
        'icon': LucideIcons.banknote,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Sports Day Event',
        'date': 'Feb 25th',
        'icon': LucideIcons.award,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Parent Meeting',
        'date': 'Mar 1st',
        'icon': LucideIcons.users,
        'color': const Color(0xFF10B981),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notices',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 260,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: notice['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              notice['icon'],
                              color: notice['color'],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  notice['title'],
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notice['date'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
