import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();

  Future<void> _showAddAssignmentDialog() async {
    String title = '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Assignment'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
          onChanged: (value) => title = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (title.trim().isEmpty) return;

              setState(() {
                _presenter.addAssignment(title.trim());
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _presenter.assignments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          if (assignments.isNotEmpty)
            IconButton(
              tooltip: 'Delete all assignments',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  _presenter.deleteAll();
                });
              },
            ),
        ],
      ),

      body: assignments.isEmpty
          ? const Center(
              child: Text('No assignments yet'),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_presenter.completedCount} of '
                      '${assignments.length} completed',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];

                      return CheckboxListTile(
                        title: Text(
                          assignment.title,
                          style: TextStyle(
                            decoration: assignment.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        value: assignment.isCompleted,
                        onChanged: (_) {
                          setState(() {
                            _presenter.toggleCompleted(index);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        tooltip: 'Add assignment',
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}