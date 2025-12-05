import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'add_visitor.dart';
import 'visitor_status.dart';
import 'scan_pass.dart';
import '../resident/notice_list.dart';
import '../resident/service_directory.dart';
import 'staff_entry.dart';

class GuardHome extends ConsumerStatefulWidget {
  const GuardHome({super.key});

  @override
  ConsumerState<GuardHome> createState() => _GuardHomeState();
}

class _GuardHomeState extends ConsumerState<GuardHome> {
  final Set<String> _handledAlerts = {};
  bool _isAlertShowing = false;

  @override
  Widget build(BuildContext context) {
    // 🚨 Listen for SOS Alerts
    final sosStream = ref.watch(firestoreServiceProvider).getActiveSOS();
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: sosStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
           final newAlerts = snapshot.data!.where((a) => !_handledAlerts.contains(a['id'])).toList();
           if (newAlerts.isNotEmpty && !_isAlertShowing) {
             final alert = newAlerts.first;
             _handledAlerts.add(alert['id']);
             WidgetsBinding.instance.addPostFrameCallback((_) {
               _showSOSDialog(alert);
             });
           }
        }
        
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            title: const Text('Guard Dashboard', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () => ref.read(authServiceProvider).signOut(),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0F10), Color(0xFF151520)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                padding: EdgeInsets.zero,
                children: [
                  _buildGlassCard(context, 'Add Visitor', Icons.person_add, Colors.blueAccent, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVisitorScreen()))),
                  _buildGlassCard(context, 'Visitor Logs', Icons.history, Colors.orangeAccent, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitorStatusScreen()))),
                  _buildGlassCard(context, 'Scan Pass', Icons.qr_code_scanner, Colors.greenAccent, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPassScreen()))),
                  _buildGlassCard(context, 'Notices', Icons.announcement, Colors.purpleAccent, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeListScreen()))),
                  _buildGlassCard(context, 'Directory', Icons.contact_phone, Colors.cyanAccent, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceDirectoryScreen()))),
                  _buildGlassCard(context, 'Daily Staff', Icons.badge, Colors.tealAccent, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffEntryScreen()))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSOSDialog(Map<String, dynamic> alert) {
    setState(() => _isAlertShowing = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF200000), // Deep Dark Red
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
            SizedBox(width: 8),
            Text('SOS ALERT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 24))
          ]
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EMERGENCY REPORTED', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1)),
            const Divider(color: Colors.redAccent),
            const SizedBox(height: 12),
            Text('FLAT: ${alert['flatNumber']}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('WING: ${alert['wing'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white70, fontSize: 20)),
            const SizedBox(height: 16),
            const Text('Action Required Immediately.', style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isAlertShowing = false);
              },
              child: const Text('ACKNOWLEDGE & RESPOND', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ).then((_) => setState(() => _isAlertShowing = false));
  }

  Widget _buildGlassCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.01)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, spreadRadius: 2),
                  ],
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
