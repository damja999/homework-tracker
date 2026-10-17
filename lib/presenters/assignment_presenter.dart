import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignments = [];

  List<Assignment> get assignments => _assignments;
  int get totalAssignments => _assignments.length;
  int get completedAssignments =>
      _assignments.where((assignment) => assignment.isCompleted).length;
  int get completedCount => completedAssignments;
  double get completionRatio =>
      totalAssignments == 0 ? 0.0 : completedAssignments / totalAssignments;

  Future<void> loadAssignments() async {
    final fetched = await Assignment.fetchAssignments();
    _assignments
      ..clear()
      ..addAll(fetched);
  }

  Future<void> addAssignment(String title, String courseName) async {
    final id = await Assignment.addAssignment(title, courseName);
    _assignments.add(
      Assignment(id: id, title: title, courseName: courseName),
    );
  }

  Future<void> toggleCompleted(int index) async {
    if (index < 0 || index >= _assignments.length) return;
    final assignment = _assignments[index];
    final newStatus = !assignment.isCompleted;
    await Assignment.updateCompletionStatus(assignment.id, newStatus);
    assignment.isCompleted = newStatus;
  }
}
