import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:redmine_client/models/journal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:redmine_client/models/issue.dart';
import 'package:redmine_client/models/issue_details.dart';

class DbController {
  final String dBfileName = 'rc_db.v2.db';
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
          'CREATE TABLE issues(id INTEGER PRIMARY KEY, priority VARCHAR, author VARCHAR, assigned_to VARCHAR, subject TEXT, date_created VARCHAR, description TEXT, hash VARCHAR)',
        );

        db.execute(
          'CREATE TABLE journals(id INTEGER PRIMARY KEY, task_id INTEGER, author_id INTEGER, author_name VARCHAR, notes TEXT, date_created VARCHAR, hash VARCHAR)',
        );
      },
      version: 1,
    );
  }

  Future<void>storeIssuesToDb(List<dynamic> issues) async {
    getDatabase().then((db) async {
      List<int> currentIssueIDs = [];

      for (var i = 0; i < issues.length; i++) {
        currentIssueIDs.add(issues[i].id);
      }

      String currentIssueIDsStr = currentIssueIDs.join(",");

      await db.execute('DELETE FROM issues WHERE id NOT IN ($currentIssueIDsStr)');

      final List<Map<String, dynamic>> storedIssues = await db.rawQuery('SELECT id, hash FROM issues');

      for (var i = 0; i < issues.length; i++) {
        for (var k = 0; k < storedIssues.length; k++) {
          if (issues[i].id == storedIssues[k]['id']) {
            if (issues[i].hashCode != storedIssues[k]['hash']) {
              await db.execute('DELETE FROM issues WHERE id = ${issues[i].id}');

              db.insert(
                'issues',
                issues[i].toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }

            break;
          }
        }
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
      List<int> currentJournalIDs = [];

      for (var i = 0; i < journals.length; i++) {
        currentJournalIDs.add(journals[i].id);
      }

      String currentJournalIDsStr = currentJournalIDs.join(",");

      await db.execute('DELETE FROM journals WHERE task_id = $taskId AND id NOT IN ($currentJournalIDsStr)');

      final List<Map<String, dynamic>> storedJournals = await db.rawQuery('SELECT id, hash FROM journals WHERE task_id = $taskId');

      for (var i = 0; i < journals.length; i++) {
        for (var k = 0; k < storedJournals.length; k++) {
          if (journals[i].id == storedJournals[k]['id']) {
            if (journals[i].hashCode != storedJournals[k]['hash']) {
              await db.execute('DELETE FROM journals WHERE id = ${journals[i].id}');

              db.insert(
                'journals',
                journals[i].toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }

            break;
          }
        }
      }
    });
  }

  Future<List<Issue>> getStoredIssues() async {
    final db = await getDatabase();

    final List<Map<String, dynamic>> storedIssues =
        await db.query('issues ORDER BY priority');

    return List.generate(storedIssues.length, (i) {
      return Issue(
        id:          storedIssues[i]['id'],
        priority:    storedIssues[i]['priority'],
        author:      storedIssues[i]['author'],
        assignedTo:  storedIssues[i]['assigned_to'],
        subject:     storedIssues[i]['subject'],
        dateCreated: storedIssues[i]['date_created'],
      );
    });
  }

  Future<IssueDetails> getStoredIssueDetails(int taskID) async {
    final db = await getDatabase();

    final List<Map<String, dynamic>> issueDetails = await db.query(
      'issues WHERE id = $taskID ORDER BY priority LIMIT 1');

    final List<Map<String, dynamic>> journalsData = await db.query(
        'journals WHERE task_id = $taskID AND notes != "" ORDER BY date_created ASC');

    List<Journal> issueJournals = List.generate(journalsData.length, (i) {
      return Journal(
        taskId: taskID,
        id: journalsData[i]['id'],
        authorId: journalsData[i]['author_id'],
        authorName: journalsData[i]['author_name'],
        notes: journalsData[i]['notes'],
        dateCreated: journalsData[i]['date_created'],
      );
    });

    return IssueDetails(
      id:          issueDetails[0]['id'],
      priority:    issueDetails[0]['priority'],
      author:      issueDetails[0]['author'],
      assignedTo:  issueDetails[0]['assigned_to'],
      subject:     issueDetails[0]['subject'],
      dateCreated: issueDetails[0]['date_created'],
      description: issueDetails[0]['description'],
      journals: issueJournals,
      attachments: [],
    );
  }
}