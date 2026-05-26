import 'package:flutter/material.dart';

class CurrencyTile extends StatelessWidget {
  final String code;

  final String name;

  final VoidCallback onTap;

  const CurrencyTile({
    super.key,
    required this.code,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(code),
      subtitle: Text(name),
      trailing: const Icon(
        Icons.chevron_right,
      ),
    );
  }
}
