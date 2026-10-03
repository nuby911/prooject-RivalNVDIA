import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/models/task.dart';
import 'package:app/services/storage_service.dart';

void main() {
  late StorageService storageService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
  });

  test('saves and loads task fields', () async {
    final task = Task(
      id: 'task-1',
      title: 'Belajar Flutter',
      description: 'Selesaikan materi',
      dueAt: DateTime(2026, 10, 2, 9),
      reminderAt: DateTime(2026, 10, 2, 8, 45),
      isCompleted: true,
      createdAt: DateTime(2026, 10, 1, 17),
    );

    await storageService.saveTask(task);
    final loadedTasks = await storageService.loadTasks();

    expect(loadedTasks, hasLength(1));
    expect(loadedTasks.single.id, task.id);
    expect(loadedTasks.single.title, task.title);
    expect(loadedTasks.single.description, task.description);
    expect(loadedTasks.single.dueAt, task.dueAt);
    expect(loadedTasks.single.reminderAt, task.reminderAt);
    expect(loadedTasks.single.isCompleted, isTrue);
    expect(loadedTasks.single.createdAt, task.createdAt);
  });

  test('saving an existing task updates instead of duplicating it', () async {
    await storageService.saveTask(Task(id: 'task-1', title: 'Judul lama'));
    await storageService.saveTask(Task(id: 'task-1', title: 'Judul baru'));

    final loadedTasks = await storageService.loadTasks();

    expect(loadedTasks, hasLength(1));
    expect(loadedTasks.single.title, 'Judul baru');
  });

  test('deletes and clears saved tasks', () async {
    await storageService.saveTasks([
      Task(id: 'task-1', title: 'Pertama'),
      Task(id: 'task-2', title: 'Kedua'),
    ]);

    await storageService.deleteTask('task-1');
    expect((await storageService.loadTasks()).map((task) => task.id), [
      'task-2',
    ]);

    await storageService.clearTasks();
    expect(await storageService.loadTasks(), isEmpty);
  });
}
