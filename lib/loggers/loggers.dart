import 'package:logger/web.dart';

Logger logger = Logger(
  printer: PrettyPrinter(
    colors: true,
    noBoxingByDefault: true,
    methodCount: 0,
  ),
);
