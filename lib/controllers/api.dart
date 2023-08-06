import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:redmine_client/models/user.dart';

Future<User> getCurrentUser(String hostURL, String login, String password) async {
  String basicAuth = 'Basic ${base64.encode(utf8.encode('$login:$password'))}';

  final response = await http.get(Uri.parse('$hostURL/my/account.json'),
      headers: <String, String>{'authorization': basicAuth});

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return User.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to get user details');
  }
}