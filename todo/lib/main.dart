import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum Filter { all, current, completed }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo Менеджер',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TaskList(),
    );
  }
}

class Task {
  String title;
  String description;
  bool completed;

  Task({
    required this.title,
    required this.description,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'completed': completed,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        description: json['description'],
        completed: json['completed'],
      );
}

class TaskList extends StatefulWidget {
  @override
  TaskListState createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  List<Task> taskList = [];
  Filter currentFilter = Filter.all;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List jsonList = json.decode(tasksJson);
      setState(() {
        taskList = jsonList.map((json) => Task.fromJson(json)).toList();
      });
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'tasks', json.encode(taskList.map((t) => t.toJson()).toList()));
  }

  void toggleCompletion(int index) {
    setState(() {
      taskList[index].completed = !taskList[index].completed;
      saveTasks();
    });
  }

  void addTask(Task task) {
    setState(() {
      taskList.add(task);
      saveTasks();
    });
  }

  void editTask(int index, Task task) {
    setState(() {
      taskList[index] = task;
      saveTasks();
    });
  }

  void deleteTask(int index) {
    setState(() {
      taskList.removeAt(index);
      saveTasks();
    });
  }

  void navigateToEditScreen({Task? task, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskEdit(task: task)),
    );
    if (result != null && result is Task) {
      if (index != null) {
        editTask(index, result);
      } else {
        addTask(result);
      }
    }
  }

  List<Task> getFilteredTasks() {
    switch (currentFilter) {
      case Filter.current:
        return taskList.where((t) => !t.completed).toList();
      case Filter.completed:
        return taskList.where((t) => t.completed).toList();
      case Filter.all:
      default:
        return taskList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = getFilteredTasks();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          PopupMenuButton<Filter>(
            onSelected: (Filter value) {
              setState(() {
                currentFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Filter>>[
              const PopupMenuItem<Filter>(
                value: Filter.all,
                child: Text('Все задачи'),
              ),
              const PopupMenuItem<Filter>(
                value: Filter.current,
                child: Text('Текущие'),
              ),
              const PopupMenuItem<Filter>(
                value: Filter.completed,
                child: Text('Выполненные'),
              ),
            ],
          ),
        ],
      ),
      body: visibleTasks.isEmpty
          ? const Center(child: Text('Нет запланированных задач.'))
          : ListView.builder(
              itemCount: visibleTasks.length,
              itemBuilder: (context, index) {
                final task = visibleTasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => navigateToEditScreen(
                      task: task,
                      index: taskList.indexOf(task),
                    ),
                  ),
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (value) {
                      toggleCompletion(taskList.indexOf(task));
                    },
                  ),
                  onLongPress: () {
                    toggleCompletion(taskList.indexOf(task));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskEdit extends StatefulWidget {
  final Task? task;

  const TaskEdit({super.key, this.task});

  @override
  TaskEditState createState() => TaskEditState();
}

class TaskEditState extends State<TaskEdit> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleCtrl.text = widget.task!.title;
      descCtrl.text = widget.task!.description;
    }
  }

  void saveTask() {
    if (titleCtrl.text.isNotEmpty) {
      Navigator.pop(
        context,
        Task(
          title: titleCtrl.text,
          description: descCtrl.text,
          completed: widget.task?.completed ?? false,
        ),
      );
    }
  }

  void deleteTask() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.task == null ? 'Добавить задачу' : 'Редактировать задачу'),
        actions: widget.task != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: deleteTask,
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Название задачи', border: OutlineInputBorder()),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                  labelText: 'Описание задачи', border: OutlineInputBorder()),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveTask,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
