
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Assignment {
  final String id;
  final String title;
  final String courseName;
  bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.courseName,
    this.isCompleted = false,
  });

  static final _db = FirebaseDatabase.instance.ref();
  static final _auth = FirebaseAuth.instance;

  // Fetch assignments from Firebase
  static Future<List<Assignment>> fetchAssignments() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) return [];

    final snapshot =
        await _db.child('assignments/$userId').get();

    final List<Assignment> assignments = [];

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        if (child.value is! Map) continue;

        final data = Map<String, dynamic>.from(
          child.value as Map,
        );

        assignments.add(
          Assignment(
            id: child.key!,
            title: data['title'] ?? '',
            courseName: data['courseName'] ?? 'Unknown',
            isCompleted: data['isCompleted'] ?? false,
          ),
        );
      }
    }

    return assignments;
  }

  // Add assignment and return its Firebase ID
  static Future<String> addAssignment(
    String title,
    String courseName,
  ) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User is not logged in');
    }

    final newRef =
        _db.child('assignments/$userId').push();

    await newRef.set({
      'title': title,
      'courseName': courseName,
      'isCompleted': false,
    });

    return newRef.key!;
  }

  // Update the correct assignment using its Firebase ID
  static Future<void> updateCompletionStatus(
    String assignmentId,
    bool isCompleted,
  ) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User is not logged in');
    }

    await _db
        .child('assignments/$userId/$assignmentId')
        .update({
      'isCompleted': isCompleted,
    });
  }
}
