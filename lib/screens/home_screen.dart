import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_task.dart';
import 'add_task_screen.dart';
import 'detail_task_screen.dart';

enum TaskFilter { all, pending, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final List<Task> _tasks = [];
  bool _isLoading = true;

  // Filter & Search
  TaskFilter _selectedFilter = TaskFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(_loadTasks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
  int get _pendingCount => _tasks.where((task) => !task.isCompleted).length;

  List<Task> get _filteredTasks {
    var result = _tasks.where((task) {
      if (_selectedFilter == TaskFilter.pending && task.isCompleted) return false;
      if (_selectedFilter == TaskFilter.completed && !task.isCompleted) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchDesc = task.description.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc) return false;
      }

      return true;
    }).toList();

    result.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.dueAt != null && b.dueAt != null) {
        return a.dueAt!.compareTo(b.dueAt!);
      }
      if (a.dueAt != null) return -1;
      if (b.dueAt != null) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return result;
  }

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
        final notificationsAllowed =
            await NotificationService.instance.requestPermissions();
        final exactAlarmsAllowed =
            await NotificationService.instance.requestExactAlarmPermission();
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
    final result = await Navigator.of(context).push<DetailResult>(
      MaterialPageRoute<DetailResult>(
        builder: (_) => DetailTaskScreen(task: task),
      ),
    );

    if (!mounted || result == null) return;

    if (result.action == DetailActionResult.deleted) {
      await _deleteTask(task, showUndo: true);
    } else if (result.action == DetailActionResult.updated && result.task != null) {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        setState(() => _tasks[index] = result.task!);
        await _persistTasks();
        await _syncReminder(result.task!);
      }
    }
  }

  Future<void> _setTaskCompleted(Task task, bool? completed) async {
    setState(() => task.isCompleted = completed ?? false);
    await _persistTasks();
    await _syncReminder(task);
  }

  Future<void> _deleteTask(Task task, {bool showUndo = true}) async {
    final index = _tasks.indexOf(task);
    setState(() => _tasks.remove(task));
    await _persistTasks();

    if (task.reminderAt != null) {
      try {
        await NotificationService.instance.cancelReminder(task);
      } catch (_) {
        if (mounted) _showNotificationError();
      }
    }

    if (showUndo && mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tugas "${task.title}" dihapus.'),
          action: SnackBarAction(
            label: 'URUNGKAN',
            onPressed: () => _restoreTask(task, index),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _restoreTask(Task task, int originalIndex) async {
    setState(() {
      if (originalIndex >= 0 && originalIndex <= _tasks.length) {
        _tasks.insert(originalIndex, task);
      } else {
        _tasks.add(task);
      }
    });
    await _persistTasks();
    await _syncReminder(task);
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Tanpa tenggat';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diffDays = targetDate.difference(today).inDays;

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    if (diffDays == 0) {
      return 'Hari ini · $timeStr';
    } else if (diffDays == 1) {
      return 'Besok · $timeStr';
    } else if (diffDays == -1) {
      return 'Kemarin · $timeStr';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} · $timeStr';
    }
  }

  String get _todayLabel {
    const weekdays = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _tasks.isEmpty ? 0.0 : _completedCount / _tasks.length;
    final filteredTasks = _filteredTasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rencana Hari Ini',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
                children: [
                  Text(
                    _todayLabel.toUpperCase(),
                    style: TextStyle(
                      color: isDark ? const Color(0xFFA5ADFF) : AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Satu langkah kecil,\nlebih dekat ke tujuan.',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      fontSize: 27,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Atur kegiatanmu dan nikmati progresnya.',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Card Progress (Gradient Asli: Indigo 0xFF6874D8 -> 0xFF515DBE)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Progres hari ini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '$_completedCount/${_tasks.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
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
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _tasks.isEmpty
                              ? 'Tambahkan tugas pertamamu hari ini.'
                              : '${(progress * 100).toInt()}% rencana telah terselesaikan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Summary Tiles
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.checklist_rounded,
                          label: 'TOTAL AGENDA',
                          value: '${_tasks.length}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.pending_actions_rounded,
                          label: 'BELUM SELESAI',
                          value: '$_pendingCount',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.done_all_rounded,
                          label: 'TERSELESAIKAN',
                          value: '$_completedCount',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Cari tugas atau catatan...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text('Semua (${_tasks.length})'),
                          selected: _selectedFilter == TaskFilter.all,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = TaskFilter.all),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Belum Selesai ($_pendingCount)'),
                          selected: _selectedFilter == TaskFilter.pending,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = TaskFilter.pending),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Selesai ($_completedCount)'),
                          selected: _selectedFilter == TaskFilter.completed,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = TaskFilter.completed),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Title
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Daftar tugas',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${filteredTasks.length} tugas',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFA5ADFF) : AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Task List or Empty State
                  if (filteredTasks.isEmpty)
                    EmptyTask(
                      title: _searchQuery.isNotEmpty
                          ? 'Tidak ada hasil pencarian'
                          : (_selectedFilter == TaskFilter.completed
                              ? 'Belum ada tugas selesai'
                              : 'Belum ada agenda'),
                      message: _searchQuery.isNotEmpty
                          ? 'Coba gunakan kata kunci pencarian yang lain.'
                          : (_selectedFilter == TaskFilter.completed
                              ? 'Selesaikan tugas pertamamu hari ini!'
                              : 'Yuk, tambahkan tugas barumu!'),
                      onAddTask: _searchQuery.isEmpty && _selectedFilter != TaskFilter.completed
                          ? _addTask
                          : null,
                    )
                  else
                    ...filteredTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: Key(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.delete_rounded, color: Colors.white),
                          ),
                          onDismissed: (_) => _deleteTask(task, showUndo: true),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) =>
                                    _setTaskCompleted(task, value),
                                activeColor: AppTheme.primaryColor,
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted ? Colors.grey : null,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.description.trim().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          task.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule_rounded,
                                          size: 14,
                                          color: task.isOverdue
                                              ? Colors.red.shade400
                                              : (isDark ? Colors.grey.shade400 : AppTheme.primaryColor),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _formatTime(task.dueAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: task.isOverdue
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                            color: task.isOverdue
                                                ? Colors.red.shade400
                                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () => _openTask(task),
                              trailing: IconButton(
                                tooltip: 'Hapus ${task.title}',
                                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                color: Colors.grey.shade500,
                                onPressed: () => _deleteTask(task, showUndo: true),
                              ),
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
