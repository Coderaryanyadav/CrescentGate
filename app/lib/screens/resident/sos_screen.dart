import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class SOSScreen extends ConsumerStatefulWidget {
  const SOSScreen({super.key});

  @override
  ConsumerState<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends ConsumerState<SOSScreen> {
  bool _isSending = false;

  Future<void> _sendSOS() async {
    if (_isSending) return;
    
    setState(() => _isSending = true);
    
    // 🔊 Haptic Feedback
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.heavyImpact();
    
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      final firestore = ref.read(firestoreServiceProvider);
      final appUser = await firestore.getUser(user.uid);
      
      if (appUser?.flatNumber == null) {
        throw Exception('Flat number not found');
      }

      await firestore.sendSOS(user.uid, appUser!.flatNumber!);
      
      if (mounted) {
        // Success vibration
        HapticFeedback.mediumImpact();
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('🚨 SOS SENT'),
              ],
            ),
            content: const Text('Guards and Admin have been alerted!\nHelp is on the way.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error sending SOS: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🚨 EMERGENCY',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.red),
          ),
          const SizedBox(height: 16),
          Text(
            _isSending ? 'Sending alert...' : 'Press and hold to alert security',
            style: TextStyle(
              fontSize: 16,
              color: _isSending ? Colors.orange : Colors.grey,
              fontWeight: _isSending ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onLongPress: _isSending ? null : _sendSOS,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSending ? Colors.orange.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                border: Border.all(
                  color: _isSending ? Colors.orange : Colors.red,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isSending ? Colors.orange : Colors.red).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                _isSending ? Icons.radio_button_checked : Icons.notifications_active,
                size: 80,
                color: _isSending ? Colors.orange : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
