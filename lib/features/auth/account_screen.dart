import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/buttons/app_button.dart';
import '../saved_places/saved_places_screen.dart';

/// Shown only when `authProvider` is `AppAuthenticated` — see
/// `HomeScreen`'s account icon for the routing between this and
/// `AuthScreen`.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    final email = switch (state) {
      AppAuthenticated(:final user) => user.email ?? '',
      _ => '',
    };

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.accountTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${AppStrings.accountSignedInAsPrefix}$email'),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: AppStrings.savedPlacesTitle,
              variant: AppButtonVariant.secondary,
              icon: Icons.bookmark_border,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SavedPlacesScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: AppStrings.signOutButton,
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
