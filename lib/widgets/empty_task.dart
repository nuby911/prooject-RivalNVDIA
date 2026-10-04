
import 'package:flutter/material.dart';

class EmptyTask extends StatelessWidget {
	const EmptyTask({
		super.key,
		this.title = 'Belum ada tugas',
		this.message = 'Tugas yang kamu tambahkan akan muncul di sini.',
		this.onAddTask,
	});

	final String title;
	final String message;
	final VoidCallback? onAddTask;

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);

		return Card(
			color: theme.colorScheme.surface,
			elevation: 0,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(18),
				side: BorderSide(color: theme.colorScheme.outlineVariant),
			),
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Icon(
							Icons.event_note_rounded,
							size: 40,
							color: theme.colorScheme.primary,
						),
						const SizedBox(height: 12),
						Text(
							title,
							textAlign: TextAlign.center,
							style: theme.textTheme.titleMedium?.copyWith(
								fontWeight: FontWeight.w700,
							),
						),
						const SizedBox(height: 6),
						Text(
							message,
							textAlign: TextAlign.center,
							style: theme.textTheme.bodyMedium?.copyWith(
								color: theme.colorScheme.onSurfaceVariant,
							),
						),
						if (onAddTask != null) ...[
							const SizedBox(height: 16),
							FilledButton.icon(
								onPressed: onAddTask,
								icon: const Icon(Icons.add_rounded),
								label: const Text('Tambah tugas'),
							),
						],
					],
				),
			),
		);
	}
}
