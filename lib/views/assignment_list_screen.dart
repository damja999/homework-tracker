import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState
    extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter =
      AssignmentPresenter();

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    await _presenter.loadAssignments();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

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
          onChanged: (value) {
            title = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (title.trim().isEmpty) return;

              await _presenter.addAssignment(
                title.trim(),
              );

              if (!mounted) return;

              setState(() {});

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

    final filteredAssignments = assignments.where((assignment) {
      return assignment.title
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search assignments',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                if (assignments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      8,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_presenter.completedCount} of '
                        '${assignments.length} completed',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                    ),
                  ),

                Expanded(
                  child: filteredAssignments.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching assignments',
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              filteredAssignments.length,
                          itemBuilder:
                              (context, index) {
                            final assignment =
                                filteredAssignments[index];

                            final originalIndex =
                                assignments.indexOf(
                              assignment,
                            );

                            return CheckboxListTile(
                              title: Text(
                                assignment.title,
                                style: TextStyle(
                                  decoration:
                                      assignment
                                              .isCompleted
                                          ? TextDecoration
                                              .lineThrough
                                          : TextDecoration
                                              .none,
                                ),
                              ),
                              value: assignment
                                  .isCompleted,
                              onChanged: (_) async {
                                await _presenter
                                    .toggleCompleted(
                                  originalIndex,
                                );

                                if (!mounted) return;

                                setState(() {});
                              },
                            );
                          },
                        ),
                ),
              ],
            ),

      floatingActionButton:
          FloatingActionButton(
        tooltip: 'Add assignment',
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}