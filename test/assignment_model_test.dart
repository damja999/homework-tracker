import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/models/assignment_model.dart';

void main() {
  test('New assignment defaults to incomplete', () {
    final assignment = Assignment(
      id: 'test-1',
      title: 'Test Assignment',
      courseName: 'Math',
    );
    expect(assignment.isCompleted, isFalse);
  });

  test('Assignment stores title and course correctly', () {
    final assignment = Assignment(
      id: 'test-2',
      title: 'Essay',
      courseName: 'English',
    );
    expect(assignment.title, 'Essay');
    expect(assignment.courseName, 'English');
    expect(assignment.id, 'test-2');
  });
}
