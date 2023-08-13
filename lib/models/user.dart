class User {
  final int id;
  final String login;
  final String email;
  final String firstName;
  final String lastName;
  final String lastLogin;
  final String avatarUrl;

  const User({
    required this.id,
    required this.login,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.lastLogin,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:        json['user']['id'] ?? 0,
      login:     json['user']['login'] ?? '',
      email:     json['user']['mail'] ?? '',
      firstName: json['user']['firstname'] ?? '',
      lastName:  json['user']['lastname'] ?? '',
      lastLogin: json['user']['last_login_on'] ?? '',
      avatarUrl: json['user']['avatar_url'] ?? '',
    );
  }
}