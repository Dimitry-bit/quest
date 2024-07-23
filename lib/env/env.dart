import 'package:envied/envied.dart';

part 'env.g.dart';

@envied
final class Env {
  @EnviedField(varName: 'GSHEET_CREDENTIALS', obfuscate: true)
  static final String gsheetCredentials = _Env.gsheetCredentials;

  @EnviedField(varName: 'GSHEET_SPREADSHEET_ID', obfuscate: true)
  static final String gsheetSpreadsheetId = _Env.gsheetSpreadsheetId;
}
