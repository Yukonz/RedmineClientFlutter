import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:redmine_client/models/user.dart';
import 'package:redmine_client/models/issue.dart';

class ApiController {
  final String hostURL;
  final String login;
  final String password;

  const ApiController({
    required this.hostURL,
    required this.login,
    required this.password,
  });

  String getAuthHeader() {
    return 'Basic ${base64.encode(utf8.encode('$login:$password'))}';
  }

  Future<User> getCurrentUser() async {
    final response = await http.get(Uri.parse('$hostURL/my/account.json'),
        headers: <String, String>{'authorization': getAuthHeader()});

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<List> getAssignedTasks() async {
    List<Issue> myIssues = <Issue>[];

    final response = await http.get(Uri.parse('$hostURL/issues.json?assigned_to_id=me'),
        headers: <String, String>{'authorization': getAuthHeader()});

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      print(data['issues'][0]['category']['name']);

      for (var i = 0; i < data['issues'].length; i++) {
        myIssues.add(Issue.fromJson(data['issues'][i]));
      }

      return myIssues;
    } else {
      throw Exception('Failed to get issues');
    }
  }
}