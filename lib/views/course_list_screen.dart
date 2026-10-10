import 'package:flutter/material.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';
class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() =>
      _CourseListScreenState();
}

class _CourseListScreenState
    extends State<CourseListScreen> {
  final CoursePresenter _presenter =
      CoursePresenter();

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    await _presenter.loadCourses();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showAddCourseDialog() async {
    String name = '';
    String? description;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Course'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (name.trim().isEmpty) return;

                await _presenter.addCourse(
                  name.trim(),
                  description,
                );

                if (!mounted || !dialogContext.mounted) return;

                setState(() {});

                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = _presenter.courses;

    final filteredCourses = courses.where((course) {
      final query = _searchQuery.toLowerCase();

      final nameMatches =
          course.name.toLowerCase().contains(query);

      final descriptionMatches =
          course.description
              ?.toLowerCase()
              .contains(query) ??
          false;

      return nameMatches || descriptionMatches;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
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
                      labelText: 'Search courses',
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

                Expanded(
                  child: filteredCourses.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching courses',
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              filteredCourses.length,
                          itemBuilder:
                              (context, index) {
                            final course =
                                filteredCourses[index];

                            return ListTile(
                              title: Text(
                                course.name,
                              ),
                              subtitle:
                                  course.description !=
                                              null &&
                                          course
                                              .description!
                                              .trim()
                                              .isNotEmpty
                                      ? Text(
                                          course
                                              .description!,
                                        )
                                      : null,
                            );
                          },
                        ),
                ),
              ],
            ),

      floatingActionButton: AddFAB(
  onPressed: _showAddCourseDialog,
      ),
    );
  }
}