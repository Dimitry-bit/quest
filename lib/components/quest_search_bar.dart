import 'package:flutter/material.dart';

class QuestSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final bool autoFocus;
  final String? hintText;
  final void Function(String)? onSubmitted;

  const QuestSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onSubmitted,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      autoFocus: autoFocus,
      hintText: hintText,
      onSubmitted: onSubmitted,
      elevation: const WidgetStatePropertyAll(0.0),
      hintStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.black45)),
      leading: const Icon(Icons.search, size: 32.0, color: Colors.black54),
    );
  }
}
