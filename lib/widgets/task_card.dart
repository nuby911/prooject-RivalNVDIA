import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
	const TaskCard({
		super.key,
		required this.task,
		this.onChanged,
		this.onTap,
		this.onDelete,
	});

	final Task task;
	final ValueChanged<bool>? onChanged;
	final VoidCallback? onTap;
	final VoidCallback? onDelete;

	String _formatDeadline(DateTime deadline) {
		final day = deadline.day.toString().padLeft(2, '0');
		final month = deadline.month.toString().padLeft(2, '0');
		final hour = deadline.hour.toString().padLeft(2, '0');
		final minute = deadline.minute.toString().padLeft(2, '0');
		return '$day/$month/${deadline.year} - $hour:$minute';
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final dueAt = task.dueAt;
		final effectiveOnTap =
				onTap ?? (onChanged == null ? null : () => onChanged!(!task.isCompleted));
		final details = <Widget>[];

		if (task.description.trim().isNotEmpty) {
			details.add(
				Text(
					task.description,
					maxLines: 2,
					overflow: TextOverflow.ellipsis,
					style: theme.textTheme.bodySmall,
				),
			);
		}

		if (dueAt != null) {
			if (details.isNotEmpty) {
				details.add(const SizedBox(height: 6));
			}
			details.add(
				Row(
					children: [
						Icon(
							task.isOverdue ? Icons.warning_amber_rounded : Icons.schedule_rounded,
							size: 15,
							color: task.isOverdue
									? theme.colorScheme.error
									: theme.colorScheme.onSurfaceVariant,
						),
						const SizedBox(width: 5),
						Expanded(
							child: Text(
								'${task.isOverdue ? 'Terlambat' : 'Tenggat'}: ${_formatDeadline(dueAt)}',
								style: theme.textTheme.bodySmall?.copyWith(
									color: task.isOverdue
											? theme.colorScheme.error
											: theme.colorScheme.onSurfaceVariant,
								),
							),
						),
					],
				),
			);
		}

		return Card(
			margin: EdgeInsets.zero,
			color: theme.colorScheme.surface,
			elevation: 1,
			shadowColor: theme.colorScheme.primary.withValues(alpha: 0.06),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
			child: ListTile(
				contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
				onTap: effectiveOnTap,
				leading: Checkbox(
					value: task.isCompleted,
					onChanged: onChanged == null
							? null
							: (value) => onChanged!(value ?? false),
					shape: const CircleBorder(),
					activeColor: theme.colorScheme.primary,
				),
				title: Text(
					task.title,
					style: theme.textTheme.titleSmall?.copyWith(
						fontWeight: FontWeight.w600,
						decoration:
								task.isCompleted ? TextDecoration.lineThrough : null,
						color: task.isCompleted
								? theme.colorScheme.onSurfaceVariant
								: theme.colorScheme.onSurface,
					),
				),
				subtitle: details.isEmpty
						? null
						: Padding(
								padding: const EdgeInsets.only(top: 4),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									mainAxisSize: MainAxisSize.min,
									children: details,
								),
							),
				trailing: onDelete == null
						? null
						: IconButton(
								tooltip: 'Hapus ${task.title}',
								onPressed: onDelete,
								icon: const Icon(Icons.close_rounded),
								color: theme.colorScheme.onSurfaceVariant,
							),
			),
		);
	}
}
