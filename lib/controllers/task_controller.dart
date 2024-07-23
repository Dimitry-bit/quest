import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:quest/controllers/response.dart';
import 'package:quest/models/gsheet_table.dart';
import 'package:quest/loggers/loggers.dart';
import 'package:quest/models/quest_settings.dart';
import 'package:quest/models/task.dart';

/// Manages interaction with Google Sheets to retrieve and manipulate task-related data.
///
/// This class provides methods to fetch user-specific tasks, status colors, and status icons
/// from a Google Sheets spreadsheet based on provided [QuestSettings].
class TaskController {
  final Spreadsheet _spreadsheet;
  final QuestSettings _settings;

  /// Cached mapping of task status to corresponding color values.
  ///
  /// Populated when [getStatusColors] is called.
  Map<String, Color>? _statusColors;

  /// Cached mapping of task status to corresponding icon data values.
  ///
  /// Populated when [getStatusIcons] is called.
  Map<String, IconData>? _statusIcons;

  /// Cached list of status mappings fetched from Google Sheets.
  ///
  /// Used for parsing status colors and icons.
  List<Map<String, String>>? _statusMaps;

  /// Constructs a [TaskController].
  ///
  /// [_settings] should provide configuration settings for interacting with the Google Sheets.
  /// [_spreadsheet] is the instance of the Google Sheets spreadsheet to interact with.
  TaskController(this._settings, this._spreadsheet);

  /// Retrieves tasks assigned to a user identified by [identifier].
  /// Returns a [Response] object containing a list of [Task] objects if tasks are found,
  /// otherwise returns a response with `null`.
  Future<Response<List<Task>>> getUserTasks(String identifier) async {
    GSheetTable tasksTable;
    GSheetTable studentsTable;

    try {
      final students = await _fetchTable(_settings.studentTasksSheetTitle);
      final tasks = await _fetchTable(_settings.tasksSheetTitle);

      studentsTable = GSheetTable.fromRows(students);
      tasksTable = GSheetTable.fromRows(tasks);

      // Tasks header is not need.
      tasksTable.dropRow(0);
    } catch (e) {
      return Response.error(
        "Failed to fetch '${_settings.tasksSheetTitle}' and "
        "'${_settings.studentTasksSheetTitle}' tables, ${e.toString()}",
      );
    }

    // Search for student's task row.
    int studentIndex = _findStudentTasksRow(
      studentsTable,
      _settings.searchColumn,
      identifier,
    );

    if (studentIndex == -1) {
      return Response(null);
    }

    // Search for first task.
    String? firstTask = tasksTable.firstOrNull?.firstOrNull;
    if (firstTask == null) {
      return Response([]);
    }
    final tasksIndex = studentsTable.map.indexOfColumn(firstTask);

    // Isolate student tasks row.
    studentsTable.dropRowWhere((_, index) => index != studentIndex);

    studentsTable = studentsTable.reshapeColumn(
      fromColumn: tasksIndex,
      length: _settings.taskColumnDisplayNames.length - tasksTable.numColumns,
    );

    studentsTable = studentsTable.join(tasksTable);

    List<Map<String, String>> tasks = studentsTable.map.getRows(
      fromRow: 0,
      alias: _settings.taskColumnDisplayNames,
    );

    List<Task> result = [];
    for (var t in tasks) {
      try {
        final task = Task.fromJson(t);
        result.add(task);
      } catch (e) {
        logger.w("Failed to construct task $t, ${e.toString()}");
      }
    }

    return Response(result);
  }

  /// Finds the row index in [studentsTable] that matches [identifier] in any of the [searchColumns].
  ///
  /// Returns the index of the matching row if found, otherwise returns `-1`.
  int _findStudentTasksRow(
    GSheetTable studentsTable,
    List<String> searchColumns,
    String identifier,
  ) {
    for (var column in searchColumns) {
      int index = studentsTable.map.findInColumn(column, identifier);
      if (index != -1) {
        return index;
      }
    }

    return -1;
  }

  /// Fetches and returns a map of task status colors, where keys are status names
  /// and values are corresponding [Color] objects.
  ///
  /// Returns an empty map if fetching fails or no valid data is found.
  Future<Map<String, Color>> getStatusColors() async {
    await _initializeStatusMaps();
    _statusColors ??= _parseStatusColors(_statusMaps!);
    return _statusColors!;
  }

  /// Fetches and returns a map of task status icons, where keys are status names
  /// and values are corresponding [IconData] objects.
  ///
  /// Returns an empty map if fetching fails or no valid data is found.
  Future<Map<String, IconData>> getStatusIcons() async {
    await _initializeStatusMaps();
    _statusIcons = _parseStatusIcons(_statusMaps!);
    return _statusIcons!;
  }

  /// Returns a list of rows fetched form worksheet with the
  /// given [title] from [_spreadsheet].
  ///
  /// Optionally provides a callback [onError] if fetching fails.
  ///
  /// Throws:
  ///   - [StateError] if the [title] worksheet is not found and no [onError] is provided.
  ///   - [GSheetsException] if a failure occurred while fetching rows;
  Future<List<List<String>>> _fetchTable(
    String title, {
    List<List<String>> Function()? onError,
  }) async {
    final sheet = _spreadsheet.worksheetByTitle(title);
    if (sheet == null) {
      if (onError != null) {
        return onError();
      }

      throw StateError("Couldn't locate $title worksheet");
    }

    try {
      return await sheet.values.allRows();
    } catch (e) {
      if (onError != null) {
        return onError();
      }

      rethrow;
    }
  }

  /// Initializes [_statusMaps] by fetching [_settings.statusSheetTitle] worksheet.
  /// Defaults to empty map if worksheet does not exist.
  Future<void> _initializeStatusMaps() async {
    if (_statusMaps != null) {
      return;
    }

    try {
      final ws = _spreadsheet.worksheetByTitle(_settings.statusSheetTitle);
      _statusMaps ??= await ws?.values.map.allRows() ?? [];
    } catch (e) {
      logger.e("Failed to Fetched '${_settings.statusSheetTitle}' table.");
      _statusMaps = [];
    }

    assert(_statusMaps != null);
  }

  /// Parses a map of task status colors.
  ///
  /// Each map entry should contain 'Status' and 'Hex Color' fields.
  /// Converts hex color strings to [Color] objects.
  Map<String, Color> _parseStatusColors(List<Map<String, String>> colors) {
    Map<String, Color> result = {};

    for (Map<String, String> color in colors) {
      String? status = color['Status']?.trim();
      String hexString = color['Hex Color']?.trim().replaceAll('#', '') ?? '';
      int? colorCode = int.tryParse(hexString, radix: 16);

      if ((status != null) && (colorCode != null)) {
        result[status] = Color(colorCode);
      } else {
        logger.w("Invalid color format $color, skipping.");
      }
    }

    return result;
  }

  /// Parses a map of task status icons.
  ///
  /// Each map entry should contain 'Status' and 'Icon Code Point' fields.
  /// Converts code point strings to [IconData] objects.
  Map<String, IconData> _parseStatusIcons(List<Map<String, String>> icons) {
    Map<String, IconData> result = {};

    for (Map<String, String> icon in icons) {
      String? status = icon['Status']?.trim();
      String codePointStr = icon['Icon Code Point']?.trim() ?? '';
      int? codePoint = int.tryParse(codePointStr, radix: 16);

      if ((status != null) && (codePoint != null)) {
        result[status] = IconData(codePoint, fontFamily: 'MaterialIcons');
      } else {
        logger.w('Invalid icon format $icon, skipping.');
      }
    }

    return result;
  }
}
