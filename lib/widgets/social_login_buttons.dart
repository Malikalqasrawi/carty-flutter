import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// "Continue with Google" and "Continue with Apple" buttons.
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final disabled = auth.isLoading;

    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('or continue with', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),

        // Google
        OutlinedButton(
          onPressed: disabled ? null : () => auth.signInWithGoogle(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'G',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4285F4),
                ),
              ),
              SizedBox(width: 12),
              Text('Continue with Google', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Apple
        ElevatedButton.icon(
          onPressed: disabled ? null : () => auth.signInWithApple(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.apple, size: 26),
          label: const Text('Continue with Apple', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
