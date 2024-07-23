import 'package:flutter/foundation.dart';
import 'package:gsheets/gsheets.dart';
import 'package:quest/utils/parse_utils.dart';

/// Represents settings parsed from a Google Sheets spreadsheet for quest configuration.
class QuestSettings {
  /// Constants for identifying keys in the GSheet settings.
  static const String _settingsSheetTitle = 'Quest Settings';
  static const String _vTasksSheetTitle = 'tasks_sheet_title';
  static const String _vStudentTasksSheetTitle = 'student_tasks_sheet_title';
  static const String _vSearchColumnsNames = 'search_columns_names';
  static const String _vTaskColumnsAlias = 'task_columns_names';
  static const String _vStatusSheetTitle = 'status_sheet_title';

  /// The title of the sheet containing tasks titles and information.
  /// Fields: any
  /// Required Fields: 'Title'
  /// Note: 'Title' must be unique.
  final String tasksSheetTitle;

  /// The title of the worksheet containing student-specific tasks information.
  final String studentTasksSheetTitle;

  /// Column names to use for searching tasks.
  final List<String> searchColumn;

  /// Display names for task columns.
  /// example:
  /// - 'Task 1' column aliased to 'Status'
  /// - 'Task 1 Notes' column aliased to 'Notes'
  final List<String> taskColumnDisplayNames;

  /// The title of the sheet containing task status information
  /// Fields: 'Status', 'Hex Color', 'Icon Code Point'.
  final String statusSheetTitle;

  /// Creates [QuestSettings] instance with required properties.
  ///
  /// All parameters are required and correspond to settings parsed from a
  /// Google Sheets spreadsheet.
  const QuestSettings({
    required this.tasksSheetTitle,
    required this.studentTasksSheetTitle,
    required this.searchColumn,
    required this.taskColumnDisplayNames,
    String? statusSheetTitle,
  }) : statusSheetTitle = statusSheetTitle ?? '';

  /// Parses settings from a [Spreadsheet] object and returns [QuestSettings].
  ///
  /// Throws:
  ///   - [ArgumentError] if a required variable does not exist or has incorrect formatting.
  ///   - [StateError] if [_settingsSheetTitle] worksheet does not exist in this [spreadsheet].
  static Future<QuestSettings> fromSpreadsheet(Spreadsheet spreadsheet) async {
    final Worksheet? ws = spreadsheet.worksheetByTitle(_settingsSheetTitle);
    if (ws == null) {
      throw StateError("Couldn't locate '$_settingsSheetTitle' worksheet");
    }

    List<Map<String, String>> settings = await ws.values.map.allRows() ?? [];
    Map<String, String> settingsJson = {};
    for (var setting in settings) {
      bool isValidVariable = setting.containsKey('Variable') &&
          (setting['Variable']?.isNotEmpty ?? false);

      if (!isValidVariable) {
        continue;
      }

      String varName = setting['Variable']!.trim();
      String varValue = setting['Value']?.trim() ?? '';
      settingsJson[varName] = varValue;
    }

    return QuestSettings.fromJson(settingsJson);
  }

  /// Creates [QuestSettings] from JSON [Map].
  ///
  /// Throws:
  ///   - [ArgumentError] if a required variable does not exist has incorrect formatting.
  factory QuestSettings.fromJson(Map<String, dynamic> json) {
    return QuestSettings(
      tasksSheetTitle:
          ParseUtils.getValue<String>(json, _vTasksSheetTitle).trim(),
      studentTasksSheetTitle:
          ParseUtils.getValue<String>(json, _vStudentTasksSheetTitle).trim(),
      searchColumn: ParseUtils.parseCSV(
          ParseUtils.getValue<String>(json, _vSearchColumnsNames)),
      taskColumnDisplayNames: ParseUtils.parseCSV(
          ParseUtils.getValue<String>(json, _vTaskColumnsAlias)),
      statusSheetTitle: json[_vStatusSheetTitle]?.toString().trim(),
    );
  }

  @override
  String toString() {
    return 'QuestSettings(tasksSheetTitle: $tasksSheetTitle, '
        'studentTaskSheetTitle: $studentTasksSheetTitle, '
        'statusSheetTitle: $statusSheetTitle, searchColumn: $searchColumn, '
        'taskColumnDisplayNames: $taskColumnDisplayNames)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is QuestSettings &&
        other.tasksSheetTitle == tasksSheetTitle &&
        other.studentTasksSheetTitle == studentTasksSheetTitle &&
        other.statusSheetTitle == statusSheetTitle &&
        listEquals(other.searchColumn, searchColumn) &&
        listEquals(other.taskColumnDisplayNames, taskColumnDisplayNames);
  }

  @override
  int get hashCode {
    return tasksSheetTitle.hashCode ^
        studentTasksSheetTitle.hashCode ^
        statusSheetTitle.hashCode ^
        searchColumn.hashCode ^
        taskColumnDisplayNames.hashCode;
  }
}
