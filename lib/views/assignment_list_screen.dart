import '../widgets/add_fab.dart';
import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';
import '../presenters/course_presenter.dart';

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

  final CoursePresenter _coursePresenter =
      CoursePresenter();

  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCourseFilter;
  String _completionFilter = 'All';
  List<String> _courseNames = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _coursePresenter.loadCourses();
    await _presenter.loadAssignments();

    if (!mounted) return;

    setState(() {
      _courseNames = _coursePresenter.courses
          .map((course) => course.name)
          .toList();

      _isLoading = false;
    });
  }

  Future<void> _showAddAssignmentDialog() async {
    if (_courseNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add a course before adding assignments.',
          ),
        ),
      );
      return;
    }

    String title = '';
    String? selectedCourse = _courseNames.first;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Assignment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Title',
                    ),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourse,
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(),
                    ),
                    items: _courseNames.map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCourse = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (title.trim().isEmpty ||
                              selectedCourse == null) {
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            await _presenter.addAssignment(
                              title.trim(),
                              selectedCourse!,
                            );

                            if (!mounted) return;

                            setState(() {});
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (error) {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isSaving = false;
                              });

                              ScaffoldMessenger.of(
                                dialogContext,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not add assignment: $error',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _presenter.assignments;

    final displayedAssignments = assignments.where(
      (assignment) {
        final matchesSearch = assignment.title
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        final matchesCourse =
            _selectedCourseFilter == null ||
            assignment.courseName ==
                _selectedCourseFilter;

        final matchesCompletion =
            _completionFilter == 'All' ||
            (_completionFilter == 'Completed' &&
                assignment.isCompleted) ||
            (_completionFilter == 'Incomplete' &&
                !assignment.isCompleted);

        return matchesSearch &&
            matchesCourse &&
            matchesCompletion;
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          if (_courseNames.isNotEmpty)
            DropdownButton<String>(
              hint: const Text('Filter Course'),
              value: _selectedCourseFilter,
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Courses'),
                ),
                ..._courseNames.map(
                  (name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCourseFilter = value;
                });
              },
            ),
          const SizedBox(width: 12),
        ],
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

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      const Text('Status: '),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _completionFilter,
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('All'),
                            ),
                            DropdownMenuItem(
                              value: 'Incomplete',
                              child: Text('Incomplete'),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Text('Completed'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _completionFilter = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                if (assignments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16, 0, 16, 8,
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
                  child: displayedAssignments.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching assignments',
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              displayedAssignments.length,
                          itemBuilder: (context, index) {
                            final assignment =
                                displayedAssignments[index];

                            final originalIndex =
                                assignments.indexOf(
                                  assignment,
                                );

                            return CheckboxListTile(
                              title: Text(
                                assignment.title,
                                style: TextStyle(
                                  decoration:
                                      assignment.isCompleted
                                          ? TextDecoration
                                              .lineThrough
                                          : TextDecoration
                                              .none,
                                ),
                              ),
                              subtitle: Text(
                                'Course: ${assignment.courseName}',
                              ),
                              value: assignment.isCompleted,
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

      floatingActionButton: AddFAB(
  onPressed: _showAddAssignmentDialog,
      ),
    );
  }
}
