import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:provider/provider.dart';
import 'package:quest/controllers/task_controller.dart';
import 'package:quest/env/env.dart';
import 'package:quest/loggers/loggers.dart';
import 'package:quest/models/quest_settings.dart';
import 'package:quest/pages/home_page.dart';

void main() async {
  final gsheets = GSheets(Env.gsheetCredentials);

  try {
    Spreadsheet ss = await gsheets.spreadsheet(Env.gsheetSpreadsheetId);
    QuestSettings settings = await QuestSettings.fromSpreadsheet(ss);
    TaskController taskController = TaskController(settings, ss);

    runApp(
      Provider.value(
        value: taskController,
        child: const MainApp(),
      ),
    );
  } catch (e) {
    logger.f(e.toString());
    exit(1);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}
