import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../manager/profile_cubit.dart';

/// Displays a confirmation dialog before permanently deleting the user's account.
Future<void> showDeleteAccountConfirmationDialog(BuildContext context) async {
  final l10n = S.of(context);
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final profileCubit = context.read<ProfileCubit>();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        Icons.delete_forever_outlined,
        color: colorScheme.error,
        size: 32,
      ),
      title: Text(
        l10n.delete_account_confirm_title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Text(
        l10n.delete_account_confirm_message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: Text(l10n.delete_account_confirm_button),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await profileCubit.deleteAccount();
  }
}
