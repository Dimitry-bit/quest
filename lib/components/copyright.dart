import 'package:flutter/material.dart';

class Copyright extends StatelessWidget {
  final String organization;

  const Copyright({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      '© ${DateTime.now().year} $organization. All Rights Reserved.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
      ),
    );
  }
}
