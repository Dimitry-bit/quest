import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/copyright.dart';
import 'package:quest/components/failure_text.dart';
import 'package:quest/components/logo.dart';
import 'package:quest/components/quest_search_bar.dart';
import 'package:quest/components/task_details.dart';
import 'package:quest/controllers/response.dart';
import 'package:quest/controllers/task_controller.dart';
import 'package:quest/models/task.dart';
import 'package:timelines_plus/timelines_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Map<String, Color> defaultStatusColors = {
    "Accepted": Colors.greenAccent,
    "Late": Colors.greenAccent,
    "Incomplete": Colors.redAccent,
    "Rejected": Colors.redAccent,
    "Not Submitted": Colors.grey,
  };

  static const Map<String, IconData> defaultStatusIcons = {
    "Accepted": Icons.check_rounded,
    "Late": Icons.hourglass_empty_rounded,
    "Incomplete": Icons.priority_high_rounded,
    "Rejected": Icons.close_rounded,
    "Not Submitted": Icons.question_mark_rounded,
  };

  Map<String, Color> _statusColors = defaultStatusColors;
  Map<String, IconData> _statusIcons = defaultStatusIcons;

  late final TaskController _taskController;
  Future<Response<List<Task>>>? fetchTasksFuture;

  @override
  void initState() {
    super.initState();

    _taskController = Provider.of<TaskController>(context, listen: false);
    _taskController.getStatusColors().then((value) {
      if (value.isNotEmpty) {
        setState(() => _statusColors = value);
      }
    });
    _taskController.getStatusIcons().then((value) {
      if (value.isNotEmpty) {
        setState(() => _statusIcons = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Logo(label: 'Quest', icon: Icons.track_changes),
                const SizedBox(height: 16.0),
                QuestSearchBar(
                  autoFocus: true,
                  hintText: 'ID',
                  onSubmitted: (value) {
                    value = value.trim();

                    if (value.isEmpty) {
                      fetchTasksFuture = null;
                    } else {
                      setState(() {
                        fetchTasksFuture = _taskController.getUserTasks(value);
                      });
                    }
                  },
                ),
                const SizedBox(height: 8.0),
                _buildBody(context),
              ],
            ),
          ),
          const Copyright(organization: 'Open Source Community'),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder(
      future: fetchTasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          Response<List<Task>> response = snapshot.data!;

          if (response.hasError()) {
            if (kDebugMode) {
              return FailureText(response.error());
            }

            return const FailureText('An error occurred while processing '
                'your request, please try again later.');
          } else if (response.hasData()) {
            if (response.data!.isEmpty) {
              return const Text("No Tasks found.");
            }

            return _buildTasksTimeline(context, response.data!);
          }

          return const Text('User not found.');
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTasksTimeline(BuildContext context, List<Task> tasks) {
    const double contentPadding = 16.0;
    final theme = Theme.of(context);

    return Flexible(
      child: SingleChildScrollView(
        primary: true,
        child: FixedTimeline.tileBuilder(
          mainAxisSize: MainAxisSize.max,
          builder: TimelineTileBuilder.connected(
            itemCount: tasks.length,
            itemExtent: 100.0,
            contentsAlign: ContentsAlign.alternating,
            contentsBuilder: (context, index) {
              final Task task = tasks[index];

              return Padding(
                padding: const EdgeInsets.all(contentPadding),
                child: FilledButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        alignment: Alignment.topRight,
                        insetPadding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero),
                        ),
                        child: TaskDetails(
                          task: task,
                          statusColor: _taskColor(task.status),
                          statusIcon: _taskIcon(task.status),
                        ),
                      ),
                    );
                  },
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                  child: Text(task.title),
                ),
              );
            },
            oppositeContentsBuilder: (context, index) {
              final Task task = tasks[index];

              return Padding(
                padding: const EdgeInsets.all(contentPadding),
                child: Text(
                  task.status,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.textTheme.labelLarge?.color?.withOpacity(0.4),
                  ),
                ),
              );
            },
            connectorBuilder: (context, index, _) {
              final Task task = tasks[index];

              Color color = _taskColor(task.status);
              return SolidLineConnector(color: color);
            },
            indicatorBuilder: (context, index) {
              final Task task = tasks[index];

              Color color = _taskColor(task.status);
              return DotIndicator(
                color: color,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _taskIcon(task.status),
                    size: 16.0,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _taskColor(String status) {
    return _statusColors[status] ?? const Color(0xFFFF00FF);
  }

  IconData _taskIcon(String status) {
    return _statusIcons[status] ?? Icons.question_mark_rounded;
  }
}
