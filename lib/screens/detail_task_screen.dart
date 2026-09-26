import 'package:flutter/material.dart';

class DetailTaskScreen extends StatefulWidget {
  const DetailTaskScreen({
    super.key,
    required this.title,
    this.description = '',
    this.dueAt,
    this.isCompleted = false,
  });

  final String title;
  final String description;
  final DateTime? dueAt;
  final bool isCompleted;

  @override
  State<DetailTaskScreen> createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
  late bool _isCompleted = widget.isCompleted;

  void _close() => Navigator.of(context).pop<bool>(_isCompleted);

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = widget.dueAt == null
        ? 'Belum dijadwalkan'
        : localizations.formatMediumDate(widget.dueAt!);
    final timeLabel = widget.dueAt == null
        ? 'Waktu fleksibel'
        : localizations.formatTimeOfDay(TimeOfDay.fromDateTime(widget.dueAt!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail tugas'),
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _close,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF5B67CA).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _isCompleted ? Icons.task_alt_rounded : Icons.event_note_rounded,
              size: 32,
              color: const Color(0xFF5B67CA),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isCompleted
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _isCompleted ? 'Selesai' : 'Belum selesai',
              style: TextStyle(
                color: _isCompleted
                    ? Colors.green.shade800
                    : Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _DetailSection(
            icon: Icons.calendar_month_rounded,
            title: 'Jadwal',
            value: '$dateLabel · $timeLabel',
          ),
          const SizedBox(height: 16),
          _DetailSection(
            icon: Icons.notes_rounded,
            title: 'Catatan',
            value: widget.description.trim().isEmpty
                ? 'Tidak ada catatan untuk tugas ini.'
                : widget.description,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () => setState(() => _isCompleted = !_isCompleted),
              icon: Icon(
                _isCompleted ? Icons.undo_rounded : Icons.check_rounded,
              ),
              label: Text(
                _isCompleted ? 'Tandai belum selesai' : 'Tandai selesai',
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _close,
            child: const Text('Simpan dan kembali'),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF5B67CA)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(value, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
