import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/visitor_request.dart';

class VisitorCard extends StatelessWidget {
  final VisitorRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showActions;

  const VisitorCard({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 Color & Icon Logic
    final purp = request.purpose.toLowerCase();
    final isDelivery = purp.contains('delivery');
    final isGuest = purp.contains('guest');
    final isCab = purp.contains('cab');
    
    Color accentColor = Colors.purpleAccent;
    IconData typeIcon = Icons.build;
    
    // Strip Emojis
    String cleanPurpose = request.purpose.replaceAll(RegExp(r'[^\x00-\x7F]+'), '').trim().toUpperCase();
    if (cleanPurpose.isEmpty) cleanPurpose = "VISITOR";

    if (isDelivery) { accentColor = Colors.orangeAccent; typeIcon = Icons.local_shipping; }
    else if (isGuest) { accentColor = Colors.cyanAccent; typeIcon = Icons.people; }
    else if (isCab) { accentColor = Colors.amberAccent; typeIcon = Icons.local_taxi; }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF252525),
            const Color(0xFF000000),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // ✨ Subtle Glow Overlay
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 50),
                  ],
                ),
              ),
            ),

            Column(
              children: [
                // Header: Active/Status Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                    color: Colors.white.withOpacity(0.02),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(typeIcon, size: 14, color: accentColor),
                            const SizedBox(width: 6),
                            Text(
                              cleanPurpose,
                              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(request.createdAt),
                            style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📸 Photo (Base64) with Gradient Border
                      GestureDetector(
                        onTap: () => _showFullScreenImage(context, request.photoUrl, 'photo_${request.id}'),
                        child: Hero(
                          tag: 'photo_${request.id}',
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [accentColor, Colors.purple]),
                              boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10)],
                            ),
                            padding: const EdgeInsets.all(2), // Border width
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                              child: ClipOval(
                                child: _buildImage(request.photoUrl),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // 📝 Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.visitorName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white, letterSpacing: 0.5),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                             Row(
                              children: [
                                Icon(Icons.phone_iphone, size: 14, color: Colors.indigoAccent),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => launchUrl(Uri.parse('tel:${request.visitorPhone}')),
                                  child: Text(
                                    request.visitorPhone,
                                    style: TextStyle(color: Colors.indigoAccent.shade100, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _getStatusColor(request.status).withOpacity(0.1),
                              ),
                              child: Text(
                                request.status.toUpperCase(), 
                                style: TextStyle(
                                  color: _getStatusColor(request.status), 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 11,
                                  letterSpacing: 1,
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 🚦 Status Icon
                      _buildStatusIcon(request.status),
                    ],
                  ),
                ),

                // ⚡ Actions (Approve/Reject)
                if (showActions && request.status == 'pending')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: onReject,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: const Center(
                                child: Text('REJECT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: onApprove,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.green.shade800, Colors.green.shade600]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10)],
                              ),
                              child: const Center(
                                child: Text('APPROVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const Center(child: Icon(Icons.person, color: Colors.white54));
    }
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
      );
    } catch (e) {
      return const Center(child: Icon(Icons.error, color: Colors.white54));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'exited': return Colors.grey;
      default: return Colors.orange;
    }
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'approved': icon = Icons.check_circle; color = Colors.green; break;
      case 'rejected': icon = Icons.cancel; color = Colors.red; break;
      default: icon = Icons.access_time_filled; color = Colors.orange; break;
    }
    return Icon(icon, color: color, size: 28);
  }

  String _formatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  void _showFullScreenImage(BuildContext context, String? photoUrl, String heroTag) {
    if (photoUrl == null || photoUrl.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      body: PhotoView(
        imageProvider: photoUrl.startsWith('http')
            ? NetworkImage(photoUrl) as ImageProvider
            : MemoryImage(base64Decode(photoUrl)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
    )));
  }
}
