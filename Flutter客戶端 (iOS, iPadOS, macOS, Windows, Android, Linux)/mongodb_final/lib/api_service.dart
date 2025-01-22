// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ApiService {
//   final String baseUrl = "https://65c1-59-120-242-188.ngrok-free.app/api/todoapp";
//
//   Future<List<dynamic>> getNotes() async {
//     final response = await http.get(Uri.parse('$baseUrl/GetNote'));
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load notes');
//     }
//   }
//
//   Future<void> addNote(String description) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/AddNote'),
//       body: {'newNotes': description},
//     );
//     if (response.statusCode != 200) {
//       throw Exception('新增失敗');
//     }
//   }
//
//   Future<void> deleteNote(String id) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/DeleteNote?id=$id'),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete note');
//     }
//   }
//
//   Future<void> updateNote(String id, String newDescription) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/UpdateNote'),
//       body: {'id': id, 'newDescription': newDescription},
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Failed to update note');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://65c1-59-120-242-188.ngrok-free.app/api/todoapp";

  Future<List<dynamic>> getNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/GetNote'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<void> addNote(String description, String importance, String urgency) async {
    final response = await http.post(
      Uri.parse('$baseUrl/AddNote'),
      body: {
        'newNotes': description,
        'importance': importance,
        'urgency': urgency,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('新增失敗');
    }
  }

  Future<void> deleteNote(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/DeleteNote?id=$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete note');
    }
  }

  Future<void> updateNote(String id, String newDescription, String importance, String urgency) async {
    final response = await http.put(
      Uri.parse('$baseUrl/UpdateNote'),
      body: {
        'id': id,
        'newDescription': newDescription,
        'importance': importance,
        'urgency': urgency,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update note');
    }
  }
}

