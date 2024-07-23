import 'package:flutter/material.dart';

class FailureText extends StatelessWidget {
  final String errorMessage;

  const FailureText(this.errorMessage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 32,
          color: Colors.amber,
        ),
        const SizedBox(width: 8.0),
        Flexible(
          child: Text(
            errorMessage,
            overflow: TextOverflow.fade,
            softWrap: true,
          ),
        )
      ],
    );
  }
}
