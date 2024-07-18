import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final Axis direction;
  final IconData? icon;
  final String? label;

  const Logo({
    super.key,
    this.label,
    this.icon,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.displayLarge;

    Widget divider = (direction == Axis.vertical)
        ? const SizedBox(width: 16.0)
        : const SizedBox(height: 16.0);

    if ((icon == null) || (label == null)) {
      divider = const SizedBox.shrink();
    }

    Widget iconWidget = (icon != null) ? Icon(icon, size: 64) : Container();
    Widget textWidget = (label != null)
        ? Text(label!, style: labelStyle)
        : const SizedBox.shrink();

    return Wrap(
      direction: direction,
      children: [
        iconWidget,
        divider,
        textWidget,
      ],
    );
  }
}
