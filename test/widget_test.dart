import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  void setPhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders HomeScreen and displays title & empty state', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Rencana Hari Ini'), findsOneWidget);
    expect(
      find.text('Satu langkah kecil,\nlebih dekat ke tujuan.'),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Belum ada agenda'), findsOneWidget);
  });

  testWidgets('adds a new task with title and description', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap on FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify AddTaskScreen is open
    expect(find.text('Rencanakan kegiatanmu'), findsOneWidget);

    // Enter title & description
    final titleField = find.widgetWithText(TextFormField, 'Nama tugas *');
    final descField = find.widgetWithText(
      TextFormField,
      'Catatan / Keterangan (Opsional)',
    );

    await tester.enterText(titleField, 'Belajar Flutter Testing');
    await tester.enterText(descField, 'Mempersiapkan presentasi proyek');

    // Tap Save
    await tester.tap(find.text('Simpan Tugas'));
    await tester.pumpAndSettle();

    // Verify task is added to HomeScreen (0 of 1 completed)
    expect(find.text('Belajar Flutter Testing'), findsOneWidget);
    expect(find.text('Mempersiapkan presentasi proyek'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);

    // Toggle complete
    final checkbox = find.byType(Checkbox).first;
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Verify 1/1 completed
    expect(find.text('1/1'), findsOneWidget);
    expect(find.text('100% rencana telah terselesaikan'), findsOneWidget);
  });

  testWidgets('search filters tasks correctly', (WidgetTester tester) async {
    setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Add task 1
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama tugas *'),
      'Makan siang',
    );
    await tester.tap(find.text('Simpan Tugas'));
    await tester.pumpAndSettle();

    // Add task 2
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama tugas *'),
      'Belajar matematika',
    );
    await tester.tap(find.text('Simpan Tugas'));
    await tester.pumpAndSettle();

    expect(find.text('Makan siang'), findsOneWidget);
    expect(find.text('Belajar matematika'), findsOneWidget);

    // Search 'matematika'
    final searchField = find.widgetWithText(
      TextField,
      'Cari tugas atau catatan...',
    );
    await tester.enterText(searchField, 'matematika');
    await tester.pumpAndSettle();

    expect(find.text('Belajar matematika'), findsOneWidget);
    expect(find.text('Makan siang'), findsNothing);
  });

  testWidgets('deletes task and restores it with undo button', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Add task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama tugas *'),
      'Tugas Hapus',
    );
    await tester.tap(find.text('Simpan Tugas'));
    await tester.pumpAndSettle();

    expect(find.text('Tugas Hapus'), findsOneWidget);

    // Click delete icon
    final deleteBtn = find.byTooltip('Hapus Tugas Hapus');
    await tester.ensureVisible(deleteBtn);
    await tester.tap(deleteBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Should be deleted and show SnackBar with URUNGKAN
    expect(find.text('Tugas Hapus'), findsNothing);
    expect(find.text('URUNGKAN'), findsOneWidget);

    // Tap URUNGKAN
    await tester.tap(find.text('URUNGKAN'));
    await tester.pumpAndSettle();

    // Should be restored
    expect(find.text('Tugas Hapus'), findsOneWidget);
  });

  testWidgets('opens DetailTaskScreen and edits task', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Add task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama tugas *'),
      'Tugas Awal',
    );
    await tester.tap(find.text('Simpan Tugas'));
    await tester.pumpAndSettle();

    // Tap on task to open DetailTaskScreen
    await tester.tap(find.text('Tugas Awal'));
    await tester.pumpAndSettle();

    expect(find.text('Detail tugas'), findsOneWidget);

    // Tap edit button in AppBar
    await tester.tap(find.byTooltip('Edit tugas'));
    await tester.pumpAndSettle();

    // Edit title
    final titleField = find.widgetWithText(TextFormField, 'Nama tugas *');
    await tester.enterText(titleField, 'Tugas Sudah Diedit');
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    // Return to HomeScreen
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();

    expect(find.text('Tugas Sudah Diedit'), findsOneWidget);
  });
}
