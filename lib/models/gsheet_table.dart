import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// Types of table joins supported by [GSheetTable] class.
enum TableJoinTypes {
  left,
  right,
}

/// A class representing a table structure for managing and manipulating tabular data.
class GSheetTable {
  final List<List<String>> _rows;

  /// Interact with this sheet as a map of values.
  late final ValueMapper map;

  GSheetTable._(this._rows) {
    map = ValueMapper._(this);
  }

  /// Constructs a [GSheetTable] instance from a list of rows.
  GSheetTable.fromRows(List<List<String>> rows)
      : _rows = _normalizeRowLengths(rows, '') {
    map = ValueMapper._(this);
  }

  /// Constructs a [GSheetTable] instance from a list of columns.
  GSheetTable.fromColumn(List<List<String>> columns)
      : _rows = _normalizeRowLengths(_transpose(columns), '') {
    map = ValueMapper._(this);
  }

  /// Constructs an empty [GSheetTable] instance.
  GSheetTable.empty() : _rows = [] {
    map = ValueMapper._(this);
  }

  /// Returns the number of rows in the table.
  int get numRows => _rows.length;

  /// Returns the number of columns in the table.
  int get numColumns => _rows.firstOrNull?.length ?? 0;

  /// Returns `true` if the table is empty (contains no rows).
  bool get isEmpty => _rows.isEmpty;

  /// Returns `true` if the table is not empty (contains one or more rows).
  bool get isNotEmpty => _rows.isNotEmpty;

  /// Returns the first row of the table.
  List<String> get first => _rows.first;

  /// Returns the first row of the table or null if the table is empty.
  List<String>? get firstOrNull => _rows.firstOrNull;

  /// Returns the last row of the table.
  List<String> get last => _rows.last;

  /// Returns the last row of the table or null if the table is empty.
  List<String>? get lastOrNull => _rows.lastOrNull;

  /// Removes the row at the specified [row] index.
  ///
  /// If [row] is out of bounds, no action is taken.
  void dropRow(int row) {
    if (row >= 0 && row < numRows) {
      _rows.removeAt(row);
    }
  }

  /// Removes the column at the specified [column] index.
  ///
  /// If [column] is out of bounds, no action is taken.
  void dropColumn(int column) {
    if (column >= 0 && column < numColumns) {
      for (var row in _rows) {
        row.removeAt(column);
      }
    }
  }

  /// Removes rows that satisfies [verdict] function.
  void dropRowWhere(bool Function(List<String> row, int index) verdict) {
    int i = 0;
    _rows.removeWhere((r) => verdict(r, i++));
  }

  /// Removes columns that satisfies [verdict] function.
  void dropColumnWhere(bool Function(List<String> column, int index) verdict) {
    for (int i = numColumns - 1; i >= 0; i--) {
      List<String>? col = getColumns(fromColumn: i).firstOrNull;
      if (col != null && verdict(col, i)) {
        dropColumn(i);
      }
    }
  }

  /// Retains only the rows with indices specified in [rows].
  void dropAllRowsExcept(List<int> rows) {
    int i = 0;
    _rows.retainWhere((r) => rows.contains(i++));
  }

  /// Retains only the columns with indices specified in [columns].
  void dropAllColumnsExcept(List<int> columns) {
    for (int i = numColumns - 1; i >= 0; i--) {
      if (!columns.contains(i)) {
        dropColumn(i);
      }
    }
  }

  /// Adds a new [row] to the end of the table.
  void addRow(List<String> row) {
    _rows.add(List.from(row, growable: true));
  }

  /// Adds a new [column] to the end of the table.
  ///
  /// If [column.length] is less than [numOfRows], then remaining rows
  /// are initialized with empty string.
  void addColumn(List<String> column) {
    for (int i = 0; i < numRows; i++) {
      if (i < column.length) {
        _rows[i].add(column[i]);
      } else {
        _rows[i].add('');
      }
    }
  }

  /// Inserts a new [row] at the specified [index].
  void insertRow(int index, List<String> row) {
    assert(index >= 0 && index <= numRows);

    _rows.insert(index, List.from(row, growable: true));
  }

  /// Inserts a new [column] at the specified [index].
  ///
  /// If [column.length] is less than [numOfRows], then remaining rows
  /// are initialized with empty string.
  void insertColumn(int index, List<String> column) {
    assert(index >= 0 && index <= numColumns);

    for (int i = 0; i < numRows; i++) {
      _rows[i].insert(index, i < column.length ? column[i] : '');
    }
  }

  /// Returns the index of the first occurrence of the specified [row].
  ///
  /// Returns -1 if the [row] is not found in the table.
  int indexOfRow(List<String> row) {
    return _rows.indexWhere((r) => listEquals(r, row));
  }

  /// Returns the index of the first occurrence of the specified [column].
  ///
  /// Returns -1 if the [column] is not found in the table.
  int indexOfColumn(List<String> column) {
    for (int i = 0; i < numColumns; i++) {
      List<String>? col = getColumns(fromColumn: i).firstOrNull;

      if (listEquals(col, column)) {
        return i;
      }
    }

    return -1;
  }

  /// Returns the value at the specified [row] and [column] indices.
  ///
  /// - [row] must be non-negative and less than [numRows].
  /// - [column] must be non-negative and less than [numColumns].
  String cell(int row, int column) {
    assert((row >= 0) && (row < numRows));
    assert((column >= 0) && (column < numColumns));

    return _rows[row][column];
  }

  /// Returns the row at the specified [row] index.
  ///
  /// - [row] must be non-negative and less than [numRows].
  List<String> getRow(int row) {
    return getRows(fromRow: row, count: 1).first;
  }

  /// Returns the column at the specified [column] index.
  ///
  /// - [column] must be non-negative and less than [numColumns].
  List<String> getColumn(int column) {
    return getColumns(fromColumn: column, count: 1).first;
  }

  /// Returns a list of rows starting from [fromRow] index up to [count] rows,
  /// and from [fromColumn] index up to [length] columns.
  ///
  /// - [fromRow] must be non-negative and less than [numRows].
  /// - [fromColumn] must be non-negative and less than [numColumns].
  /// - [count] of -1 indicates that all rows starting from [fromRow] should be included.
  /// - [length] of -1 indicates that all columns starting from [fromColumn] should be included.
  List<List<String>> getRows({
    int fromRow = 0,
    int fromColumn = 0,
    int count = -1,
    int length = -1,
  }) {
    assert(fromRow >= 0 && fromRow < numRows);
    assert(fromColumn >= 0 && fromColumn < numColumns);

    int toRow = (count == -1) ? numRows : fromRow + count;
    int toColumn = (length == -1) ? numColumns : fromColumn + length;

    assert(toRow <= numRows);
    assert(toColumn <= numColumns);

    final result = <List<String>>[];
    for (int r = fromRow; r < toRow; r++) {
      final row = <String>[];

      for (int c = fromColumn; c < toColumn; c++) {
        row.add(_rows[r][c]);
      }

      result.add(row);
    }

    return result;
  }

  /// Returns a list of columns starting from [fromColumn] index up to [count] columns,
  /// and from [fromRow] index up to [length] rows.
  ///
  /// - [fromRow] must be non-negative and less than [numRows].
  /// - [fromColumn] must be non-negative and less than [numColumns].
  /// - [count] of -1 indicates that all columns starting from [fromColumn] should be included.
  /// - [length] of -1 indicates that all row starting from [fromRow] should be included.
  List<List<String>> getColumns({
    int fromRow = 0,
    int fromColumn = 0,
    int count = -1,
    int length = -1,
  }) {
    assert(fromRow >= 0 && fromRow < numRows);
    assert(fromColumn >= 0 && fromColumn < numColumns);

    int toRow = (length == -1) ? numRows : fromRow + length;
    int toColumn = (count == -1) ? numColumns : fromColumn + count;

    assert(toRow <= numRows);
    assert(toColumn <= numColumns);

    final result = <List<String>>[];
    for (int c = fromColumn; c < toColumn; c++) {
      final column = <String>[];

      for (int r = fromRow; r < toRow; r++) {
        column.add(_rows[r][c]);
      }

      result.add(column);
    }

    return result;
  }

  /// Joins this [GSheetTable] with another [GSheetTable].
  ///
  /// - [formColumn] specifies the column index of this table to start the join.
  /// - [length] limits the number of columns to be joined.
  /// - [type] determines the type of join (left or right).
  ///
  /// - [fromColumn] must be non-negative and less than [numColumns].
  /// - [length] of -1 indicates that all columns of [other] should be joined.
  ///
  /// Returns a new [GSheetTable] containing the result of joining this with [other].
  GSheetTable join(
    GSheetTable other, {
    TableJoinTypes type = TableJoinTypes.left,
  }) {
    GSheetTable left = (type == TableJoinTypes.left) ? other : this;
    GSheetTable right = (type == TableJoinTypes.left) ? this : other;

    int toRow = (left.numRows < right.numRows) ? left.numRows : right.numRows;
    int toColumn = left.numColumns;

    assert(toRow <= left.numRows && toRow <= right.numRows);
    assert(toColumn <= left.numColumns);

    final result = <List<String>>[];
    for (int r = 0; r < toRow; r++) {
      final joinedRow = List<String>.from(
        left._rows[r].getRange(0, toColumn),
        growable: true,
      );
      joinedRow.addAll(right._rows[r]);

      result.add(joinedRow);
    }

    return GSheetTable._(result);
  }

  /// Splits this table start from [fromRow] up to [count] rows and
  /// [fromColumn] columns into rows with [length] columns.
  ///
  /// - [fromRow] must be non-negative and less than [numRows].
  /// - [fromColumn] must be non-negative and less than [numColumns].
  /// - [count] of -1 indicates that all rows starting from [fromRow] should be included.
  /// - [length] number of columns of the reshaped table.
  ///
  /// Returns a new [GSheetTable] containing the result of this reshape.
  GSheetTable reshapeColumn({
    int fromRow = 0,
    int fromColumn = 0,
    int count = -1,
    int length = 1,
  }) {
    assert(fromRow >= 0 && fromRow < numRows);
    assert(fromColumn >= 0 && fromColumn < numColumns);
    assert(length >= 1 && length <= numColumns);

    int toRow = (count == -1) ? numRows : fromRow + count;
    assert(toRow <= numRows);

    final result = <List<String>>[];
    for (int r = fromRow; r < toRow; r++) {
      final newRows = _rows[r].skip(fromColumn).slices(length);

      for (var newRow in newRows) {
        if (newRow.isEmpty) {
          break;
        }

        while (newRow.length < length) {
          newRow.add('');
        }

        result.add(newRow);
      }
    }

    return GSheetTable._(result);
  }

  /// Splits this table start from [fromColumn] up to [length] column and
  /// [fromRow] rows into columns with [count] rows.
  ///
  /// - [fromRow] must be non-negative and less than [numRows].
  /// - [fromColumn] must be non-negative and less than [numColumns].
  /// - [count] number of rows of the reshaped table.
  /// - [length] of -1 indicates that all rows starting from [fromRow] should be included.
  ///
  /// Returns a new [GSheetTable] containing the result of this reshape.
  GSheetTable reshapeRow({
    int fromRow = 0,
    int fromColumn = 0,
    int count = -1,
    int length = 1,
  }) {
    return reshapeColumn(
      fromRow: fromColumn,
      fromColumn: fromRow,
      count: length,
      length: count,
    );
  }

  GSheetTable copy() => GSheetTable.fromRows(_rows);

  @override
  String toString() => 'TableMapper(table: $_rows)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GSheetTable &&
        const DeepCollectionEquality().equals(_rows, other._rows);
  }

  @override
  int get hashCode => _rows.hashCode;
}

/// A utility class for mapping and querying data within a [GSheetTable].
class ValueMapper {
  final GSheetTable _gTable;

  ValueMapper._(this._gTable);

  /// Returns the index of the first occurrence of [key] in the specified [schema] column.
  ///
  /// - [schema] must be non-negative and less than [numColumns].
  int indexOfRow(String key, {int schema = 0}) {
    assert(schema >= 0 && schema < _gTable.numColumns);

    final col = _gTable.getColumn(schema);
    return col.indexOf(key);
  }

  /// Returns the index of the first occurrence of [key] in the specified [schema] row.
  ///
  /// - [schema] must be non-negative and less than [numRows].
  int indexOfColumn(String key, {int schema = 0}) {
    assert(schema >= 0 && schema < _gTable.numRows);

    final row = _gTable.getRow(schema);
    return row.indexOf(key);
  }

  /// Returns the index of the first row containing [value] in the
  /// specified [row] of the table.
  ///
  /// - [schema] must be non-negative and less than [numRows].
  ///
  /// Returns -1 if no column is found.
  int findInRow(String row, String value, {int schema = 0}) {
    final rowIndex = indexOfRow(row, schema: schema);

    if (rowIndex != -1) {
      for (int i = 0; i < _gTable.numColumns; ++i) {
        if ((i != schema) && (_gTable.getRow(rowIndex)[i] == value)) {
          return i;
        }
      }
    }

    return -1;
  }

  /// Returns the index of the first column containing [value] in the
  /// specified [column] of the table.
  ///
  /// - [schema] must be non-negative and less than [numOfColumn].
  ///
  /// Returns -1 if no row is found.
  int findInColumn(String column, String value, {int schema = 0}) {
    final colIndex = indexOfColumn(column, schema: schema);

    if (colIndex != -1) {
      for (int i = 0; i < _gTable.numRows; ++i) {
        if ((i != schema) && (_gTable.getRow(i)[colIndex] == value)) {
          return i;
        }
      }
    }

    return -1;
  }

  /// Retrieves rows from the table starting from [fromRow] index up to [count] rows,
  /// and from [fromColumn] index up to [length] columns, converting them into maps.
  ///
  /// If [alias] is provided, it assigns column names from the alias list; otherwise,
  /// it uses the first row of the table as default column names.
  ///
  /// - [fromRow] must be non-negative and less than [numRows].
  /// - [fromColumn] must be non-negative and less than [numColumns].
  /// - [count] of -1 indicates that all rows starting from [fromRow] should be included.
  /// - [length] of -1 indicates that all columns starting from [fromColumn] should be included.
  List<Map<String, String>> getRows({
    int fromRow = 1,
    int fromColumn = 0,
    int count = -1,
    int length = -1,
    List<String>? alias,
  }) {
    if (_gTable.isEmpty) return [];

    alias ??= _gTable.first;
    final rows = _gTable.getRows(
      fromRow: fromRow,
      fromColumn: fromColumn,
      count: count,
      length: length,
    );

    assert(alias.length == (rows.firstOrNull?.length ?? 0));

    final result = <Map<String, String>>[];
    for (var row in rows) {
      final map = <String, String>{};

      for (int c = 0; c < row.length; c++) {
        map[alias[c]] = row[c];
      }

      result.add(map);
    }

    return result;
  }

  /// Retrieves columns from the table starting from [fromColumn] index up to [count] columns,
  /// and from [fromRow] index up to [length] rows, converting them into maps.
  ///
  /// If [alias] is provided, it assigns row names from the alias list; otherwise,
  /// it uses the first column of the table as default row names.
  ///
  /// - [fromRow] must be non-negative and less than [numRows].
  /// - [fromColumn] must be non-negative and less than [numColumns].
  /// - [count] of -1 indicates that all columns starting from [fromColumn] should be included.
  /// - [length] of -1 indicates that all rows starting from [fromRow] should be included.
  List<Map<String, String>> getColumns({
    int fromRow = 0,
    int fromColumn = 1,
    int count = -1,
    int length = -1,
    List<String>? alias,
  }) {
    if (_gTable.isEmpty) return [];

    alias ??= _gTable.getColumn(0);
    final columns = _gTable.getColumns(
      fromRow: fromRow,
      fromColumn: fromColumn,
      count: count,
      length: length,
    );

    assert(alias.length == (columns.firstOrNull?.length ?? 0));

    final result = <Map<String, String>>[];
    for (var col in columns) {
      final map = <String, String>{};

      for (int c = 0; c < col.length; c++) {
        map[alias[c]] = col[c];
      }

      result.add(map);
    }

    return result;
  }
}

List<List<T>> _transpose<T>(List<List<T>> values) {
  if (values.isEmpty) return [];

  int numRows = values[0].length;
  int numCols = values.length;

  List<List<T>> transposed = List.generate(numRows, (row) {
    return List.generate(numCols, (col) => values[col][row]);
  });

  return transposed;
}

List<List<T>> _normalizeRowLengths<T>(List<List<T>> lists, T padValue) {
  int maxLength = 0;
  for (var list in lists) {
    if (list.length > maxLength) {
      maxLength = list.length;
    }
  }

  List<List<T>> result = [];
  for (var list in lists) {
    List<T> paddedList = List<T>.from(list);

    while (paddedList.length < maxLength) {
      paddedList.add(padValue);
    }

    result.add(paddedList);
  }

  return result;
}
