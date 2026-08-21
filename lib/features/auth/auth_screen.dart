import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/buttons/app_button.dart';

/// Real Supabase email/password sign-in/sign-up (Phase 14). One screen
/// toggling between the two modes rather than two near-identical screens —
/// they share every field and only differ in which `AuthNotifier` method
/// and copy get used.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    final notifier = ref.read(authProvider.notifier);
    if (_isSignUp) {
      notifier.signUp(email: email, password: password);
    } else {
      notifier.signIn(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Safe to call setState/mutate providers here — ref.listen runs
    // outside the build phase, unlike initState (see Phase 13's
    // camera_preview_screen.dart for what happens when that rule is
    // broken).
    ref.listen<AppAuthState>(authProvider, (previous, next) {
      if (next is AppAuthenticated) {
        Navigator.of(context).pop();
      } else if (next is AppAuthEmailConfirmationRequired) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.authEmailConfirmationRequired),
          ),
        );
        setState(() => _isSignUp = false);
      }
    });

    if (state is AppAuthNotConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.signInTitle)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text(
              AppStrings.authNotConfigured,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSignUp ? AppStrings.signUpTitle : AppStrings.signInTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: AppStrings.emailLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AppStrings.passwordLabel,
              ),
            ),
            if (state is AppAuthError) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _isSignUp
                    ? AppStrings.signUpFailedMessage
                    : AppStrings.signInFailedMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: _isSignUp
                  ? AppStrings.signUpButton
                  : AppStrings.signInButton,
              onPressed: state is AppAuthenticating ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp
                    ? AppStrings.switchToSignIn
                    : AppStrings.switchToSignUp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
