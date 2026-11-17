import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user.dart';

const String baseUrl = 'http://localhost:3000';
String? authToken;

// Register
Future<String?> register(String name, String email, String phone, String password) async {
  var response = await http.post(
    Uri.parse('$baseUrl/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    }),
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 201) {
    return null;
  }

  return data['message'];
}

// Login
Future<String?> login(String email, String password) async {
  var response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    authToken = data['token'];

    registeredUser = User(
      name: data['name'],
      email: email,
      phone: data['phone'] ?? '',
    );

    return null;
  }

  return data['message'];
}

// Get notes
Future<List<dynamic>> getNotes() async {
  var response = await http.get(
    Uri.parse('$baseUrl/notes'),
    headers: {'Authorization': 'Bearer $authToken'},
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data['notes'];
  }

  throw Exception(data['message']);
}

// Create note
Future<bool> createNote(String content) async {
  var response = await http.post(
    Uri.parse('$baseUrl/notes'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    },
    body: jsonEncode({'content': content}),
  );

  return response.statusCode == 201;
}

// Update note
Future<bool> updateNote(String id, String content) async {
  var response = await http.put(
    Uri.parse('$baseUrl/notes/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    },
    body: jsonEncode({'content': content}),
  );

  return response.statusCode == 200;
}

// Delete note
Future<bool> deleteNote(String id) async {
  var response = await http.delete(
    Uri.parse('$baseUrl/notes/$id'),
    headers: {'Authorization': 'Bearer $authToken'},
  );

  return response.statusCode == 200;
}

// Logout
void logout() {
  authToken = null;
  registeredUser = null;
  profilePhoto = null;
}
