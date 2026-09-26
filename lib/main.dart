import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rencana Hri Ini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B67CA),
          surface: const Color(0xFFF7F7FC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class _Task {
  _Task({required this.title, required this.time, this.isDone = false});

  final String title;
  final String time;
  bool isDone;
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog({required this.onSave});

  final ValueChanged<String> onSave;

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tugas baru'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Contoh: Belajar untuk ujian',
          labelText: 'Nama tugas',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          final title = value.trim();
          if (title.isEmpty) return;
          widget.onSave(title);
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isEmpty) return;
            widget.onSave(title);
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final List<_Task> _tasks = [
    _Task(title: 'Baca materi Flutter', time: '09:00', isDone: true),
    _Task(title: 'Selesaikan tugas kelompok', time: '11:30'),
    _Task(title: 'Olahraga ringan', time: '16:00'),
  ];

  int get _completedTasks => _tasks.where((task) => task.isDone).length;

  void _showAddTaskDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _AddTaskDialog(
        onSave: (taskTitle) {
          setState(() {
            _tasks.add(_Task(title: taskTitle, time: 'Kapan saja'));
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _tasks.isEmpty ? 0.0 : _completedTasks / _tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rencana Hari Ini',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            const Text(
              'Satu langkah kecil,\nlebih dekat ke tujuan.',
              style: TextStyle(
                fontSize: 27,
                height: 1.2,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Atur kegiatanmu dan nikmati progresnya.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6874D8), Color(0xFF515DBE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
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
                        '$_completedTasks/${_tasks.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
                        : 'Tugas selesai dari total rencana',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Daftar tugas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${_tasks.length} tugas',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
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
                child: const Column(
                  children: [
                    Icon(Icons.event_note_rounded, size: 36),
                    SizedBox(height: 8),
                    Text('Belum ada tugas. Yuk, tambahkan satu!'),
                  ],
                ),
              )
            else
              ..._tasks.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      leading: Checkbox(
                        value: task.isDone,
                        onChanged: (value) {
                          setState(() => task.isDone = value ?? false);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isDone ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Text(task.time),
                      trailing: IconButton(
                        tooltip: 'Hapus ${task.title}',
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: Colors.grey.shade500,
                        onPressed: () => setState(() => _tasks.removeAt(index)),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah tugas'),
      ),
    );
  }
}
