import 'dart:async';

import 'package:flutter/material.dart';

import 'add_task_screen.dart';
import 'detail_task_screen.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadTasks());
  }

  Future<void> _loadTasks() async {
    try {
      final storedTasks = await _storageService.loadTasks();
      final tasks = storedTasks.map((task) {
        if (task.reminderAt != null || task.dueAt == null) return task;
        return task.copyWith(reminderAt: _defaultReminderAt(task.dueAt));
      }).toList();
      if (!mounted) return;
      setState(() => _tasks.addAll(tasks));

      if (storedTasks.any(
        (task) => task.reminderAt == null && task.dueAt != null,
      )) {
        await _storageService.saveTasks(tasks);
      }

      final remindersToSchedule = tasks
          .where(
            (task) =>
                !task.isCompleted &&
                task.reminderAt?.isAfter(DateTime.now()) == true,
          )
          .toList();
      if (remindersToSchedule.isNotEmpty) {
        try {
          for (final task in remindersToSchedule) {
            await NotificationService.instance.scheduleReminder(task);
          }
        } catch (_) {
          if (mounted) _showNotificationError();
        }
      }
    } catch (_) {
      if (mounted) _showStorageError();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _persistTasks() async {
    try {
      await _storageService.saveTasks(List<Task>.of(_tasks));
    } catch (_) {
      if (mounted) _showStorageError();
    }
  }

  void _showStorageError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan tugas gagal disimpan.')),
    );
  }

  void _showNotificationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengingat gagal dijadwalkan. Periksa izin notifikasi.'),
      ),
    );
  }

  DateTime? _defaultReminderAt(DateTime? dueAt) {
    if (dueAt == null || !dueAt.isAfter(DateTime.now())) return null;

    final tenMinutesBefore = dueAt.subtract(const Duration(minutes: 10));
    return tenMinutesBefore.isAfter(DateTime.now()) ? tenMinutesBefore : dueAt;
  }

  Future<void> _syncReminder(Task task) async {
    try {
      if (task.isCompleted) {
        await NotificationService.instance.cancelReminder(task);
      } else {
        await NotificationService.instance.scheduleReminder(task);
      }
    } catch (_) {
      if (mounted) _showNotificationError();
    }
  }

  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  Future<void> _addTask() async {
    final draft = await Navigator.of(context).push<TaskDraft>(
      MaterialPageRoute<TaskDraft>(builder: (_) => const AddTaskScreen()),
    );

    if (!mounted || draft == null) return;

    final task = Task.fromDraft(
      title: draft.title,
      description: draft.description,
      dueAt: draft.dueAt,
      reminderAt: _defaultReminderAt(draft.dueAt),
    );
    setState(() => _tasks.add(task));
    await _persistTasks();

    if (task.reminderAt != null) {
      try {
        final notificationsAllowed = await NotificationService.instance
            .requestPermissions();
        final exactAlarmsAllowed = await NotificationService.instance
            .requestExactAlarmPermission();
        await NotificationService.instance.scheduleReminder(task);
        if (!mounted) return;
        if (!notificationsAllowed) {
          _showNotificationError();
        } else if (!exactAlarmsAllowed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin alarm presisi belum aktif. Pengingat tetap dijadwalkan, '
                'tetapi bisa terlambat.',
              ),
            ),
          );
        }
      } catch (_) {
        if (mounted) _showNotificationError();
      }
    }
  }

  Future<void> _openTask(Task task) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DetailTaskScreen(
          title: task.title,
          description: task.description,
          dueAt: task.dueAt,
          isCompleted: task.isCompleted,
        ),
      ),
    );

    if (!mounted || completed == null) return;
    setState(() => task.isCompleted = completed);
    await _persistTasks();
    await _syncReminder(task);
  }

  Future<void> _setTaskCompleted(Task task, bool? completed) async {
    setState(() => task.isCompleted = completed ?? false);
    await _persistTasks();
    await _syncReminder(task);
  }

  Future<void> _deleteTask(Task task) async {
    setState(() => _tasks.remove(task));
    await _persistTasks();
    try {
      await NotificationService.instance.cancelReminder(task);
    } catch (_) {
      if (mounted) _showNotificationError();
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Waktu belum ditentukan';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return 'Hari ini · $hour:$minute';
  }

  String get _todayLabel {
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _tasks.isEmpty ? 0.0 : _completedCount / _tasks.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F3),
      appBar: AppBar(
        title: const Text(
          'Rencana harian',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
                children: [
                  Text(
                    _todayLabel.toUpperCase(),
                    style: TextStyle(
                      color: Color(0xFF668078),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Fokus hari ini',
                    style: TextStyle(
                      color: Color(0xFF172E29),
                      fontSize: 30,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ngoding boleh gila jangan, oke?',
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF173D34), Color(0xFF286653)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Target hari ini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '$_completedCount/${_tasks.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 9,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFD9F5B8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _tasks.isEmpty
                              ? 'Tambahkan tugas pertamamu hari ini.'
                              : 'Tugas selesai dari total rencana',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.checklist_rounded,
                          label: 'TOTAL AGENDA',
                          value: '${_tasks.length}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.done_all_rounded,
                          label: 'TERSELESAIKAN',
                          value: '$_completedCount',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Agenda hari ini',
                          style: TextStyle(
                            color: Color(0xFF172E29),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${_tasks.length} agenda',
                        style: TextStyle(
                          color: const Color(0xFF4F796C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_tasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_note_rounded,
                            size: 38,
                            color: Colors.indigo.shade300,
                          ),
                          const SizedBox(height: 8),
                          const Text('Belum ada tugas. Yuk, tambahkan satu!'),
                        ],
                      ),
                    )
                  else
                    ..._tasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Colors.white,
                          elevation: 1,
                          shadowColor: const Color(0xFF173D34)
                              .withValues(alpha: 0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) =>
                                  _setTaskCompleted(task, value),
                              shape: const CircleBorder(),
                              activeColor: const Color(0xFF286653),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: Color(0xFF789088),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _formatTime(task.dueAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF789088),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => _openTask(task),
                            trailing: IconButton(
                              tooltip: 'Hapus ${task.title}',
                              icon: const Icon(Icons.close_rounded, size: 20),
                              color: Colors.blueGrey.shade300,
                              onPressed: () => _deleteTask(task),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        backgroundColor: const Color(0xFFD9F5B8),
        foregroundColor: const Color(0xFF173D34),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah tugas',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF4F796C)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF172E29),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF789088),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
