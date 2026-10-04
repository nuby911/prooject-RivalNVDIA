import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget {
	const TaskTile({
		super.key,
		required this.task,
		this.onChanged,
	});

	final Task task;
	final ValueChanged<bool>? onChanged;

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
		final details = <Widget>[];

		if (task.description.trim().isNotEmpty) {
			details.add(
				Text(
					task.description,
					maxLines: 2,
					overflow: TextOverflow.ellipsis,
				),
			);
		}

		if (task.dueAt != null) {
			if (details.isNotEmpty) {
				details.add(const SizedBox(height: 4));
			}
			details.add(
				Text(
					'Tenggat: ${_formatDeadline(task.dueAt!)}',
					style: theme.textTheme.bodySmall,
				),
			);
		}

		return Card(
			margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
			child: ListTile(
				onTap: onChanged == null ? null : () => onChanged!(!task.isCompleted),
				title: Text(
					task.title,
					style: task.isCompleted
							? theme.textTheme.titleMedium?.copyWith(
									decoration: TextDecoration.lineThrough,
									color: theme.colorScheme.onSurfaceVariant,
								)
							: theme.textTheme.titleMedium,
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
				trailing: Checkbox(
					value: task.isCompleted,
					onChanged: onChanged == null
							? null
							: (value) => onChanged!(value ?? false),
				),
			),
		);
	}
}
