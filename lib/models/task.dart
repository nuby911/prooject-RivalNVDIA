import 'dart:convert';

/// Model utama untuk tugas (Task) pada aplikasi pengingat tugas.
/// Dibuat oleh: Rubby (Model)
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueAt;
  final DateTime? reminderAt;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.dueAt,
    this.reminderAt,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  /// Factory helper untuk membuat Task langsung dari form input
  factory Task.fromDraft({
    required String title,
    String description = '',
    DateTime? dueAt,
    DateTime? reminderAt,
  }) {
    return Task(
      title: title,
      description: description,
      dueAt: dueAt,
      reminderAt: reminderAt,
    );
  }

  /// Helper untuk mengecek apakah tugas sudah lewat dari tenggat waktu (deadline)
  bool get isOverdue =>
      !isCompleted && dueAt != null && DateTime.now().isAfter(dueAt!);

  /// Helper untuk mengecek apakah ada jadwal pengingat aktif
  bool get hasReminder => reminderAt != null;

  /// Integer ID unik untuk notifikasi (dibutuhkan oleh flutter_local_notifications)
  int get notificationId => id.hashCode.abs() % 2147483647;

  /// Method copyWith untuk membuat salinan objek dengan modifikasi nilai tertentu
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueAt,
    DateTime? reminderAt,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      reminderAt: reminderAt ?? this.reminderAt,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Mengubah objek Task menjadi Map (untuk disimpan ke SharedPreferences / SQLite / Local Storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueAt': dueAt?.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Membuat objek Task dari Map data tersimpan
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String?,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      dueAt: map['dueAt'] != null
          ? DateTime.tryParse(map['dueAt'] as String)
          : null,
      reminderAt: map['reminderAt'] != null
          ? DateTime.tryParse(map['reminderAt'] as String)
          : null,
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  /// Mengubah objek Task menjadi string format JSON
  String toJson() => json.encode(toMap());

  /// Membuat objek Task langsung dari string JSON
  factory Task.fromJson(String source) =>
      Task.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Task(id: $id, title: $title, dueAt: $dueAt, isCompleted: $isCompleted)';
  }
}
