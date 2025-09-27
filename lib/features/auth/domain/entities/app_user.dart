class AppUser {
  final String name;
  final String uid;
  final String email;

  AppUser({required this.name, required this.uid, required this.email});

  //convert app user -> json
  Map<String, dynamic> toJson() => {'name': name, 'uid': uid, 'email': email};

  //convert json -> app user
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) => AppUser(
    name: jsonUser['name'] as String,
    uid: jsonUser['uid'] as String,
    email: jsonUser['email'] as String,
  );
}
