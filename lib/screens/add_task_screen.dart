import 'package:flutter/material.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.dueAt,
  });

  final String title;
  final String description;
  final DateTime? dueAt;
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _dueAt;

  @override
  void dispose() {
    _titleController.dispose();
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
      firstDate: DateTime(now.year, now.month, now.day),
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

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      TaskDraft(
        title: _titleController.text.trim(),
        description: '',
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
      appBar: AppBar(title: const Text('Tambah tugas')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Rencanakan kegiatanmu',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Catat hal yang ingin kamu selesaikan hari ini.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Jika tenggat diatur, pengingat muncul 10 menit sebelumnya. '
              'Jika tenggat kurang dari 10 menit lagi, pengingat muncul saat tenggat.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nama tugas',
                hintText: 'Contoh: Belajar untuk ujian',
                prefixIcon: Icon(Icons.task_alt_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tugas tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Jadwal',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
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
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saveTask,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
