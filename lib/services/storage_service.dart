import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class StorageService {
	static const String _tasksKey = 'todo_tasks';

	Future<List<Task>> loadTasks() async {
		final preferences = await SharedPreferences.getInstance();
		final savedTasks = preferences.getStringList(_tasksKey) ?? const <String>[];
		return savedTasks.map(Task.fromJson).toList();
	}

	Future<void> saveTasks(List<Task> tasks) async {
		final preferences = await SharedPreferences.getInstance();
		await preferences.setStringList(
			_tasksKey,
			tasks.map((task) => task.toJson()).toList(),
		);
	}

	Future<void> saveTask(Task task) async {
		final tasks = await loadTasks();
		final existingIndex = tasks.indexWhere((item) => item.id == task.id);

		if (existingIndex == -1) {
			tasks.add(task);
		} else {
			tasks[existingIndex] = task;
		}

		await saveTasks(tasks);
	}

	Future<void> deleteTask(String taskId) async {
		final tasks = await loadTasks();
		tasks.removeWhere((task) => task.id == taskId);
		await saveTasks(tasks);
	}

	Future<void> clearTasks() async {
		final preferences = await SharedPreferences.getInstance();
		await preferences.remove(_tasksKey);
	}
}
