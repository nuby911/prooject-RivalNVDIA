import 'package:flutter/material.dart';

import '../models/task.dart';
import 'add_task_screen.dart';

enum DetailActionResult { none, updated, deleted }

class DetailResult {
  const DetailResult({required this.action, this.task});

  final DetailActionResult action;
  final Task? task;
}

class DetailTaskScreen extends StatefulWidget {
  const DetailTaskScreen({super.key, required this.task});

  final Task task;

  @override
  State<DetailTaskScreen> createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
  late Task _currentTask;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  void _close() {
    if (_hasChanges) {
      Navigator.of(context).pop(
        DetailResult(action: DetailActionResult.updated, task: _currentTask),
      );
    } else {
      Navigator.of(context)
          .pop(const DetailResult(action: DetailActionResult.none));
    }
  }

  Future<void> _editTask() async {
    final draft = await Navigator.of(context).push<TaskDraft>(
      MaterialPageRoute<TaskDraft>(
        builder: (_) => AddTaskScreen(initialTask: _currentTask),
      ),
    );

    if (draft == null || !mounted) return;

    setState(() {
      _currentTask = _currentTask.copyWith(
        title: draft.title,
        description: draft.description,
        dueAt: draft.dueAt,
      );
      _hasChanges = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tugas berhasil diperbarui')));
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text(
          'Tugas "${_currentTask.title}" akan dihapus dari daftar rencana.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      Navigator.of(context).pop(
        DetailResult(action: DetailActionResult.deleted, task: _currentTask),
      );
    }
  }

  void _toggleCompleted() {
    setState(() {
      _currentTask = _currentTask.copyWith(
        isCompleted: !_currentTask.isCompleted,
      );
      _hasChanges = true;
    });
  }

  String _formatDate(DateTime date) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatMediumDate(date);
  }

  String _formatTime(DateTime date) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date));
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _currentTask.isCompleted;
    final dueAt = _currentTask.dueAt;
    final isOverdue = _currentTask.isOverdue;

    final String scheduleText;
    if (dueAt != null) {
      scheduleText = '${_formatDate(dueAt)} · ${_formatTime(dueAt)}';
    } else {
      scheduleText = 'Belum dijadwalkan';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail tugas'),
          leading: IconButton(
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _close,
          ),
          actions: [
            IconButton(
              tooltip: 'Edit tugas',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editTask,
            ),
            IconButton(
              tooltip: 'Hapus tugas',
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.red.shade400,
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withValues(alpha: 0.12)
                        : (isOverdue
                              ? Colors.red.withValues(alpha: 0.12)
                              : const Color(0xFF5B67CA)
                                    .withValues(alpha: 0.12)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.task_alt_rounded
                        : (isOverdue
                              ? Icons.error_outline_rounded
                              : Icons.event_note_rounded),
                    size: 30,
                    color: isCompleted
                        ? Colors.green
                        : (isOverdue ? Colors.red : const Color(0xFF5B67CA)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          isCompleted ? 'Selesai' : 'Belum selesai',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.green.shade800
                                : Colors.orange.shade900,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Terlambat',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _currentTask.title,
              style: TextStyle(
                fontSize: 26,
                height: 1.25,
                fontWeight: FontWeight.w800,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 24),
            _DetailSection(
              icon: Icons.calendar_month_rounded,
              title: 'Jadwal Tenggat',
              value: scheduleText,
            ),
            const SizedBox(height: 14),
            _DetailSection(
              icon: Icons.notes_rounded,
              title: 'Catatan / Deskripsi',
              value: _currentTask.description.trim().isEmpty
                  ? 'Tidak ada catatan tambahan untuk tugas ini.'
                  : _currentTask.description,
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _toggleCompleted,
                style: FilledButton.styleFrom(
                  backgroundColor: isCompleted
                      ? Colors.blueGrey.shade700
                      : const Color(0xFF5B67CA),
                ),
                icon: Icon(
                  isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded,
                ),
                label: Text(
                  isCompleted ? 'Tandai Belum Selesai' : 'Tandai Selesai',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _editTask,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit Rincian Tugas'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.4,
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
