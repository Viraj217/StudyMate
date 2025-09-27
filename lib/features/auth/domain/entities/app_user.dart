class AppUser {
  final String uid;
  final String email;

  AppUser({
    required this.uid,
    required this.email,
  });

  //convert app user -> json
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
  };

  //convert json -> app user
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) => AppUser(
    uid: jsonUser['uid'] as String,
    email: jsonUser['email'] as String,
  );
}
