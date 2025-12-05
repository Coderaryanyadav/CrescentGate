import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/extras.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class NoticeListScreen extends ConsumerWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text('📢 Building Notices')),
      body: StreamBuilder<List<Notice>>(
        stream: ref.watch(firestoreServiceProvider).getNotices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notices = snapshot.data!;
          if (notices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_unread, size: 60, color: isDark ? Colors.white30 : Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No new notices',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(notice.type),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(_getTypeIcon(notice.type), size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  notice.type.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${notice.createdAt.day}/${notice.createdAt.month}",
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        notice.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notice.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: isDark ? Colors.white70 : Colors.black87, // FIX: White text in dark mode
                        ),
                      ),
                      
                      // Admin-only delete button
                      if (user != null) ...[
                        FutureBuilder(
                          future: ref.read(firestoreServiceProvider).getUser(user.uid),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.data?.role == 'admin') {
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextButton.icon(
                                  onPressed: () => _deleteNotice(context, ref, notice.id),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete Notice'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteNotice(BuildContext context, WidgetRef ref, String noticeId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Delete Notice'),
        content: const Text('Are you sure you want to delete this notice? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(firestoreServiceProvider).deleteNotice(noticeId);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Notice deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'alert': return Colors.red;
      case 'event': return Colors.purple;
      default: return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'alert': return Icons.warning_amber;
      case 'event': return Icons.calendar_month;
      default: return Icons.info_outline;
    }
  }
}
