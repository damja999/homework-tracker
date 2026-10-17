import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../presenters/assignment_presenter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      await _presenter.loadAssignments();
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to load assignments. Pull down to retry.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = _presenter.completionRatio;
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Homework Tracker')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadAssignments, child: const Text('Retry')),
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _loadAssignments,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: CircularPercentIndicator(
                          radius: 120,
                          lineWidth: 14,
                          percent: percent,
                          animation: true,
                          animationDuration: 800,
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(percent * 100).round()}%',
                                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                              ),
                              const Text('Completed'),
                            ],
                          ),
                          progressColor: color,
                          backgroundColor: Colors.grey.shade300,
                          footer: const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Assignments Completed'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.assignment_outlined),
                          title: const Text('Total Assignments'),
                          trailing: Text('${_presenter.totalAssignments}'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.task_alt),
                          title: const Text('Completed Assignments'),
                          trailing: Text('${_presenter.completedAssignments}'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
