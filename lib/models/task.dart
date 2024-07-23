import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:quest/utils/parse_utils.dart';

class Task {
  /// The title of this task.
  final String title;

  /// The status of this task.
  final String status;

  /// The deadline of this task.
  /// null means this task has not deadline.
  final DateTime? deadline;

  /// Extra data associated with this task.
  final Map<String, dynamic> extra;

  /// Creates a [Task] instance.
  ///
  /// [title] and [status] are required.
  /// [deadline] is optional and defaults to `null`.
  /// [extra] is optional and defaults to an empty map.
  Task(
    this.title,
    this.status, {
    this.deadline,
    Map<String, dynamic>? extra,
  }) : extra = extra ?? {};

  /// Creates a [Task] instance from a JSON [Map].
  ///
  /// [json] should contain keys 'Title', 'Status', and optionally 'Deadline'.
  /// Any other keys in [json] will be stored in [extra].
  factory Task.fromJson(Map<String, dynamic> json) {
    final deadlineStr = json['Deadline']?.toString() ?? '';
    final extra = Map<String, dynamic>.from(json);

    extra.removeWhere((key, _) {
      return ['Title', 'Status', 'Deadline'].contains(key);
    });

    return Task(
      ParseUtils.getValue<String>(json, 'Title').trim(),
      ParseUtils.getValue<String>(json, 'Status').trim(),
      deadline: DateFormat('d/M/y').tryParse(deadlineStr),
      extra: extra,
    );
  }

  @override
  String toString() {
    return 'Task(title: $title, status: $status, deadline: $deadline, extra: $extra)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.title == title &&
        other.status == status &&
        other.deadline == deadline &&
        mapEquals(other.extra, extra);
  }

  @override
  int get hashCode {
    return title.hashCode ^
        status.hashCode ^
        deadline.hashCode ^
        extra.hashCode;
  }
}
