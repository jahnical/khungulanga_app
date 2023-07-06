/// User model class
class User {
  String username;
  String email;
  bool isStaff;
  String firstName;
  String lastName;
  int id;

  /// Constructs a new instance of the User class.
  User({
    required this.username,
    required this.email,
    required this.isStaff,
    required this.firstName,
    required this.lastName,
    required this.id,
  });

  /// Constructs a User object from a JSON map.
  ///
  /// [json] is the JSON map representing the User.
  /// Returns a User object.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      isStaff: json['is_staff'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  /// Converts the User object to a JSON map.
  ///
  /// Returns a JSON map representing the User.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['username'] = username;
    data['email'] = email;
    data['is_staff'] = isStaff;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    return data;
  }
}
