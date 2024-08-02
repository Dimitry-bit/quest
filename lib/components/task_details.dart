import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:quest/models/task.dart';

class TaskDetails extends StatelessWidget {
  final Task task;
  final Color? statusColor;
  final IconData? statusIcon;
  final double spacing;
  final EdgeInsets padding;
  final BoxConstraints constraints;
  final RoundedRectangleBorder chipShape;

  const TaskDetails({
    super.key,
    required this.task,
    this.statusColor,
    this.statusIcon,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.constraints = const BoxConstraints(maxWidth: 420.0),
    this.chipShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: padding,
      constraints: constraints,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.task_alt_rounded, size: 32.0),
              const SizedBox(width: 8.0),
              Text(
                task.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              primary: true,
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _buildStatusChip(context, task),
                  _buildDateChip(context, task),
                  ...task.extra.entries.map((e) {
                    return _buildFeedCard(context, e.key, e.value.toString());
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, Task task) {
    final theme = Theme.of(context);

    return Chip(
      avatar: CircleAvatar(
        backgroundColor: statusColor,
        child: Icon(statusIcon, size: 16.0),
      ),
      side: BorderSide.none,
      color: WidgetStatePropertyAll(theme.colorScheme.primaryContainer),
      shape: chipShape,
      label: Text(
        'Status: ${task.status}',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildDateChip(BuildContext context, Task task) {
    final theme = Theme.of(context);

    if (task.deadline == null) {
      return const SizedBox.shrink();
    }

    return Chip(
      avatar: Icon(
        Icons.date_range_rounded,
        color: theme.colorScheme.onPrimaryContainer,
      ),
      side: BorderSide.none,
      color: WidgetStatePropertyAll(theme.colorScheme.primaryContainer),
      shape: chipShape,
      label: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Deadline: ',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            TextSpan(
              text: DateFormat('d/M/y').format(task.deadline!),
              style: theme.textTheme.labelLarge?.copyWith(
                color: (task.deadline!.isAfter(DateTime.now()))
                    ? theme.colorScheme.onPrimaryContainer
                    : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedCard(BuildContext context, String title, String content) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 0.0,
      margin: EdgeInsets.zero,
      shape: chipShape,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              softWrap: true,
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(
                      Icons.dynamic_feed_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 20.0,
                    ),
                  ),
                  TextSpan(text: ' $title'),
                ],
              ),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8.0),
            MarkdownBody(data: content),
          ],
        ),
      ),
    );
  }
}
