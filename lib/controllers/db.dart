import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:redmine_client/models/issue_details.dart';

class DbController {
  final String dBfileName = 'rc_db.db';
  late Database database;

  bool dBInitialized = false;

  Future<Database> getDatabase() async {
    return dBInitialized ? database : await initDatabase();
  }

  Future<Database> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();

    return openDatabase(
      join(await getDatabasesPath(), dBfileName),
      onOpen: (db) async {
        dBInitialized = true;
      },
      onCreate: (db, version) async {
        db.execute(
          'CREATE TABLE issues(id INTEGER PRIMARY KEY, priority VARCHAR, author VARCHAR, assigned_to VARCHAR, subject TEXT, date_created VARCHAR, description TEXT)',
        );

        db.execute(
          'CREATE TABLE journals(id INTEGER PRIMARY KEY, task_id INTEGER, author_id INTEGER, author_name VARCHAR, notes TEXT, date_created VARCHAR)',
        );
      },
      version: 1,
    );
  }

  Future<void>storeIssuesToDb(List<dynamic> issues) async {
    getDatabase().then((db) async {
      await db.execute('DELETE FROM issues');

      for (var i = 0; i < issues.length; i++) {
        db.insert(
          'issues',
          issues[i].toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void>storeIssueDetailsToDb(IssueDetails issueDetails) async {
    getDatabase().then((db) async {
      db.update(
        'issues',
        {'description': issueDetails.description},
        where: 'id = ?',
        whereArgs: [issueDetails.id],
      );
    });
  }

  Future<void>storeJournalsToDb(int taskId, List<dynamic> journals) async {
    getDatabase().then((db) async {
      await db.execute('DELETE FROM journals WHERE task_id = $taskId');

      for (var i = 0; i < journals.length; i++) {
        db.insert(
          'journals',
          journals[i].toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}