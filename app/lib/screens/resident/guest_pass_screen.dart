import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/guest_pass.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class GuestPassScreen extends ConsumerStatefulWidget {
  const GuestPassScreen({super.key});

  @override
  ConsumerState<GuestPassScreen> createState() => _GuestPassScreenState();
}

class _GuestPassScreenState extends ConsumerState<GuestPassScreen> {
  GuestPass? _currentPass;
  bool _isLoading = false;

  Future<void> _generatePass() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      final pass = GuestPass(
        id: const Uuid().v4(),
        residentId: user.uid,
        visitorName: 'Guest', // Could ask user for name
        validUntil: DateTime.now().add(const Duration(hours: 24)),
        token: const Uuid().v4(), // Secure random token
        isUsed: false,
        createdAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).createGuestPass(pass);
      setState(() => _currentPass = pass);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(title: const Text('Gate Pass')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF101015)],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentPass != null) ...[
              // ✨ HOLOGRAPHIC PASS CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF202025), Colors.black],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                     // QR Container with Glow
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                           BoxShadow(color: Colors.blue.shade900.withOpacity(0.2), blurRadius: 20),
                         ],
                       ),
                       child: QrImageView(
                        data: _currentPass!.token,
                        version: QrVersions.auto,
                        size: 250,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black87),
                      ),
                     ),
                    const SizedBox(height: 24),
                    const Text(
                      'DIGITAL ENTRY PASS',
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.blueAccent, 
                        letterSpacing: 4
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ).createShader(bounds),
                      child: const Text(
                        'Access Granted',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, size: 14, color: Colors.orangeAccent),
                          const SizedBox(width: 8),
                          Text(
                            'EXPIRES AT ${_currentPass!.validUntil.hour}:${_currentPass!.validUntil.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.orangeAccent, letterSpacing: 1, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ] else ...[
               // Empty State
               Container(
                 padding: const EdgeInsets.all(32),
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: Colors.blueAccent.withOpacity(0.1),
                   border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
                 ),
                 child: Icon(Icons.qr_code_scanner, size: 80, color: Colors.blueAccent.shade100)
               ),
               const SizedBox(height: 32),
               const Text(
                 'Generate Guest Pass',
                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
               ),
               const SizedBox(height: 12),
               const Text(
                 'Create a temporary digital access code\nfor your expected guests.',
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
               ),
            ],
            const SizedBox(height: 40),
            
            // 🚀 Generator Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))
                  ],
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2979FF), Color(0xFF1565C0)],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generatePass,
                  icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.auto_awesome, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  label: Text(
                    _isLoading ? 'GENERATING SECURE TOKEN...' : 'GENERATE DIGITAL PASS',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
