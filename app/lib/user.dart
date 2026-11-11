import 'dart:typed_data';

class User {
  String name;
  String email;
  String phone;

  User({
    required this.name,
    required this.email,
    required this.phone,
  });
}

User? registeredUser;
Uint8List? profilePhoto;
