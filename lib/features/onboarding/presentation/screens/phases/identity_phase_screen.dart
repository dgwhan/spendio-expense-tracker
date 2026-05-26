import 'package:flutter/material.dart';

class IdentityPhaseScreen extends StatelessWidget {
  final String userEmail;

  const IdentityPhaseScreen({
    super.key,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = UserNameFormatter.extractName(userEmail);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hello,\n$displayName',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Manage your finances smarter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class UserNameFormatter {
  static String extractName(String email) {
    if (email.isEmpty || !email.contains('@')) {
      return 'User';
    }

    final prefix = email.split('@').first;

    if (prefix.isEmpty) {
      return 'User';
    }

    return prefix[0].toUpperCase() + prefix.substring(1);
  }
}
