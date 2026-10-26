import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    this.description = '',
    this.dueAt,
  });

  final String title;
  final String description;
  final DateTime? dueAt;
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, this.initialTask});

  final Task? initialTask;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _dueAt;

  bool get _isEditMode => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialTask?.description ?? '');
    _dueAt = widget.initialTask?.dueAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _dueAt ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now)
          ? DateTime(now.year, now.month, now.day)
          : initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;

    setState(() {
      _dueAt = DateTime(
        date.year,
        date.month,
        date.day,
        _dueAt?.hour ?? TimeOfDay.now().hour,
        _dueAt?.minute ?? TimeOfDay.now().minute,
      );
    });
  }

  Future<void> _selectTime() async {
    final currentTime = _dueAt == null
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(_dueAt!);
    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (time == null || !mounted) return;

    final date = _dueAt ?? DateTime.now();
    setState(() {
      _dueAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _clearSchedule() {
    setState(() {
      _dueAt = null;
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      TaskDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueAt: _dueAt,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatMediumDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _dueAt == null
        ? 'Pilih waktu'
        : MaterialLocalizations.of(context)
            .formatTimeOfDay(TimeOfDay.fromDateTime(_dueAt!));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit tugas' : 'Tambah tugas'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _isEditMode ? 'Perbarui rencana tugas' : 'Rencanakan kegiatanmu',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _isEditMode
                  ? 'Ubah informasi judul, catatan, atau tenggat waktu tugas.'
                  : 'Catat hal yang ingin kamu selesaikan hari ini.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Jika tenggat diatur, pengingat otomatis dijadwalkan 10 menit sebelumnya.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              autofocus: !_isEditMode,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nama tugas *',
                hintText: 'Contoh: Belajar untuk ujian',
                prefixIcon: Icon(Icons.task_alt_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tugas tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Catatan / Keterangan (Opsional)',
                hintText: 'Tambahkan rincian atau keterangan tugas...',
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Jadwal Tenggat (Opsional)',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                if (_dueAt != null)
                  TextButton.icon(
                    onPressed: _clearSchedule,
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    label: const Text('Hapus jadwal'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: Text(
                      _dueAt == null ? 'Pilih tanggal' : _formatDate(_dueAt!),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(timeLabel),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saveTask,
                icon: Icon(_isEditMode ? Icons.check_circle_rounded : Icons.check_rounded),
                label: Text(
                  _isEditMode ? 'Simpan Perubahan' : 'Simpan Tugas',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
