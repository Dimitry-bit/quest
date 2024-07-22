import 'package:quest/models/gsheet_table.dart';
import 'package:test/test.dart';

void main() {
  group('ValueMapper tests', () {
    late GSheetTable table;

    setUp(() {
      List<List<String>> sampleData = [
        ['Title', 'Status', 'Deadline'],
        ['Task 1', 'Accepted', '8/1/2004'],
        ['Task 2', 'Rejected', '12/12/2012'],
        ['Task 3', 'Not Submitted', '1/1/2024'],
      ];

      table = GSheetTable.fromRows(sampleData);
    });

    test('indexOfRow', () {
      expect(table.map.indexOfRow('Title'), equals(0));
      expect(table.map.indexOfRow(''), equals(-1));
    });

    test('indexOfColumn', () {
      expect(table.map.indexOfColumn('Status'), equals(1));
      expect(table.map.indexOfColumn(''), equals(-1));
    });

    test('findInRow', () {
      expect(table.map.findInRow('Task 1', 'Accepted'), equals(1));
      expect(table.map.findInRow('Task 1', ''), equals(-1));
      expect(table.map.findInRow('', ''), equals(-1));
    });

    test('findInColumn', () {
      expect(table.map.findInColumn('Title', 'Task 2'), equals(2));
      expect(table.map.findInColumn('Title', ''), equals(-1));
      expect(table.map.findInColumn('', ''), equals(-1));
    });

    test('getRows', () {
      List<Map<String, String>> mappedRows = table.map.getRows();

      // Exclude header row.
      expect(mappedRows.length, equals(table.numRows - 1));
      expect(mappedRows.first['Title'], equals('Task 1'));
    });

    test('getRows aliased ', () {
      List<Map<String, String>> mappedRows = table.map.getRows(
        alias: ['New Title', 'Status', 'Deadline'],
      );

      // Exclude header row.
      expect(mappedRows.length, equals(table.numRows - 1));
      expect(mappedRows.first['New Title'], equals('Task 1'));
    });

    test('getColumns', () {
      List<Map<String, String>> mappedColumns = table.map.getColumns();

      // Exclude header column.
      expect(mappedColumns.length, equals(table.numColumns - 1));
      expect(mappedColumns.first['Title'], equals('Status'));
    });

    test('getColumns aliased', () {
      List<Map<String, String>> mappedColumns = table.map.getColumns(
        alias: ['New Title', 'Status', 'Deadline', 'Extra'],
      );

      // Exclude header column.
      expect(mappedColumns.length, equals(table.numColumns - 1));
      expect(mappedColumns.first['New Title'], equals('Status'));
    });
  });
}
