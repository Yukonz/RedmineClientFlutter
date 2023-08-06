import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:redmine_client/models/user.dart';

Future<User> getCurrentUser(String hostURL, String login, String password) async {
  String basicAuth = 'Basic ${base64.encode(utf8.encode('$login:$password'))}';

  final response = await http.get(Uri.parse('$hostURL/my/account.json'),
      headers: <String, String>{'authorization': basicAuth});

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to get user details');
  }
}