import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

enum TaskFilter {
  all,
  pending,
  completed,
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To-Do Assessment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const TodoScreen(),
    );
  }
}

class Task {
  String title;
  bool isCompleted;

  Task({
    required this.title,
    this.isCompleted = false,
  });
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final List<Task> tasks = [];

  TaskFilter selectedFilter = TaskFilter.all;

  int get completedCount {
    return tasks.where((task) => task.isCompleted).length;
  }

  int get pendingCount {
    return tasks.where((task) => !task.isCompleted).length;
  }

  List<Task> get filteredTasks {
    List<Task> result = tasks;

    if (selectedFilter == TaskFilter.pending) {
      result = result.where((task) => !task.isCompleted).toList();
    } else if (selectedFilter == TaskFilter.completed) {
      result = result.where((task) => task.isCompleted).toList();
    }

    String searchText = searchController.text.trim().toLowerCase();

    if (searchText.isNotEmpty) {
      result = result
          .where((task) => task.title.toLowerCase().contains(searchText))
          .toList();
    }

    return result;
  }

  void addTask() {
    String taskName = taskController.text.trim();

    if (taskName.isEmpty) {
      showMessage('Task name cannot be empty');
      return;
    }

    setState(() {
      tasks.add(Task(title: taskName));
      taskController.clear();
    });

    showMessage('Task added successfully');
  }

  void toggleTaskStatus(Task task, bool? value) {
    setState(() {
      task.isCompleted = value ?? false;
    });
  }

  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });

    showMessage('Task deleted successfully');
  }

  void clearCompletedTasks() {
    if (completedCount == 0) {
      showMessage('No completed tasks to clear');
      return;
    }

    setState(() {
      tasks.removeWhere((task) => task.isCompleted);
    });

    showMessage('Completed tasks cleared');
  }

  void editTask(Task task) {
    final TextEditingController editController =
    TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Task name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String updatedTask = editController.text.trim();

                if (updatedTask.isEmpty) {
                  showMessage('Task name cannot be empty');
                  return;
                }

                setState(() {
                  task.title = updatedTask;
                });

                Navigator.pop(context);
                showMessage('Task updated successfully');
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget buildSummaryCard(String title, int count, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 6),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterChip(String label, TaskFilter filter) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedFilter == filter,
      onSelected: (selected) {
        setState(() {
          selectedFilter = filter;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: clearCompletedTasks,
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Clear completed tasks',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                buildSummaryCard('Total', tasks.length, Icons.list),
                buildSummaryCard('Pending', pendingCount, Icons.pending_actions),
                buildSummaryCard(
                  'Done',
                  completedCount,
                  Icons.check_circle,
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: 'Enter task name',
                hintText: 'Example: Complete Flutter assessment',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.task),
              ),
              onSubmitted: (value) {
                addTask();
              },
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addTask,
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search task',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),

            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildFilterChip('All', TaskFilter.all),
                  const SizedBox(width: 8),
                  buildFilterChip('Pending', TaskFilter.pending),
                  const SizedBox(width: 8),
                  buildFilterChip('Completed', TaskFilter.completed),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Task List',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(
                child: Text(
                  'No tasks to display',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  Task task = filteredTasks[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          toggleTaskStatus(task, value);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.isCompleted
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        task.isCompleted ? 'Completed' : 'Pending',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.orange,
                            ),
                            onPressed: () {
                              editTask(task);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              deleteTask(task);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}