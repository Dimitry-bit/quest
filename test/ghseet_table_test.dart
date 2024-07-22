import 'package:flutter_test/flutter_test.dart';
import 'package:quest/models/gsheet_table.dart';

void main() {
  group('GSheetTable tests', () {
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

    test('numRows and numColumns', () {
      expect(table.numRows, 4);
      expect(table.numColumns, 3);
    });

    test('isEmpty and isNotEmpty', () {
      expect(table.isEmpty, isFalse);
      expect(table.isNotEmpty, isTrue);
    });

    test('addRow', () {
      table.addRow(['Task 4', 'Incomplete', '7/7/2024']);

      expect(table.numRows, 5);
      expect(table.last, equals(['Task 4', 'Incomplete', '7/7/2024']));
    });

    test('dropRow', () {
      table.dropRow(0);

      expect(table.numRows, 3);
      expect(table.first, equals(['Task 1', 'Accepted', '8/1/2004']));
    });

    test('addColumn', () {
      final col = [
        'Notes',
        'T1 Notes',
        'T2 Notes',
        'T3 Notes',
      ];
      table.addColumn(col);

      expect(table.numColumns, 4);
      expect(table.getColumn(3), equals(col));
    });

    test('dropColumn', () {
      table.dropColumn(0);

      expect(table.numColumns, 2);
      expect(
        table.getColumn(0),
        equals([
          'Status',
          'Accepted',
          'Rejected',
          'Not Submitted',
        ]),
      );
    });

    test('indexOfRow', () {
      int index = table.indexOfRow(['Title', 'Status', 'Deadline']);
      expect(index, equals(0));

      index = table.indexOfRow([]);
      expect(index, equals(-1));
    });

    test('indexOfColumn', () {
      int index = table.indexOfColumn([
        'Title',
        'Task 1',
        'Task 2',
        'Task 3',
      ]);
      expect(index, equals(0));

      index = table.indexOfColumn([]);
      expect(index, equals(-1));
    });

    test('join', () {
      List<List<String>> otherData = [
        ['Notes', 'Extra'],
        ['Note 1', 'Extra 1'],
        ['Note 2', 'Extra 2'],
        ['Note 3', 'Extra 3'],
      ];
      GSheetTable otherTable = GSheetTable.fromRows(otherData);

      GSheetTable joinedTable = table.join(otherTable);
      expect(joinedTable.numRows, 4);
      expect(joinedTable.numColumns, 5);
    });

    test('getRow', () {
      expect(table.getRow(0), equals(['Title', 'Status', 'Deadline']));
    });

    test('getRow out of bounds index', () {
      expect(() => table.getRow(table.numRows), throwsAssertionError);
    });

    test('getColumn', () {
      expect(
        table.getColumn(0),
        equals([
          'Title',
          'Task 1',
          'Task 2',
          'Task 3',
        ]),
      );
    });

    test('getColumn out of bounds index', () {
      expect(() => table.getColumn(table.numColumns), throwsAssertionError);
    });

    test('getRows', () {
      List<List<String>> rows = table.getRows(
        fromRow: 1,
        fromColumn: 1,
        count: 2,
        length: 1,
      );

      expect(rows.length, equals(2));
      expect(rows[0], equals(['Accepted']));
      expect(rows[1], equals(['Rejected']));
    });

    test('getRows out of bounds', () {
      expect(() => table.getRows(fromRow: table.numRows), throwsAssertionError);
      expect(
        () => table.getRows(fromColumn: table.numColumns),
        throwsAssertionError,
      );
      expect(
        () => table.getRows(count: table.numRows + 1),
        throwsAssertionError,
      );
      expect(
        () => table.getRows(length: table.numColumns + 1),
        throwsAssertionError,
      );
    });

    test('getColumns', () {
      List<List<String>> columns = table.getColumns(
        fromRow: 1,
        fromColumn: 0,
        count: 2,
        length: 2,
      );

      expect(columns.length, equals(2));
      expect(columns[0], equals(['Task 1', 'Task 2']));
      expect(columns[1], equals(['Accepted', 'Rejected']));
    });

    test('getColumns out of bounds', () {
      expect(() => table.getColumns(fromRow: table.numRows), throwsAssertionError);
      expect(
        () => table.getColumns(fromColumn: table.numColumns),
        throwsAssertionError,
      );
      expect(
        () => table.getColumns(count: table.numColumns + 1),
        throwsAssertionError,
      );
      expect(
        () => table.getColumns(length: table.numRows + 1),
        throwsAssertionError,
      );
    });
  });
}
