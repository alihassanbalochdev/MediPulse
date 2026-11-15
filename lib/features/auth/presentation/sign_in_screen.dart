import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medipulse_medical/core/result/result.dart';
import 'package:medipulse_medical/core/sync/sync_config.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';
import 'package:medipulse_medical/core/theme/app_spacing.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';
import 'package:medipulse_medical/features/auth/presentation/providers/auth_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;
  String? _message;
  bool _messageIsError = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = ref.read(authRepositoryProvider);
    if (repository == null) return;

    setState(() {
      _busy = true;
      _message = null;
    });

    final email = _email.text.trim();
    final password = _password.text;
    final result = _isSignUp
        ? await repository.signUp(email, password)
        : await repository.signIn(email, password);

    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case Success(:final value) when value != null:
        context.pop(); // signed in: the sync coordinator pulls the data
      case Success():
        setState(() {
          _messageIsError = false;
          _message = 'Account created. Check your email to confirm it, then sign in.';
          _isSignUp = false;
        });
      case Failure(:final message):
        setState(() {
          _messageIsError = true;
          _message = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Create account' : 'Sign in', style: AppTextStyles.title),
      ),
      body: SafeArea(
        child: !isSupabaseConfigured
            ? Center(
                child: Padding(
                  padding: AppSpacing.screen,
                  child: Text(
                    'Cloud backup is not set up in this build.',
                    style: AppTextStyles.body.copyWith(color: AppColors.muted),
                  ),
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: AppSpacing.screen,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Back up your medicines and use them on other devices. '
                      'The app keeps working offline.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'At least 6 characters'
                          : null,
                    ),
                    if (_message case final message?) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        message,
                        style: AppTextStyles.body.copyWith(
                          color: _messageIsError ? AppColors.alert : AppColors.scrub,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isSignUp ? 'Create account' : 'Sign in'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _isSignUp = !_isSignUp;
                                _message = null;
                              }),
                      child: Text(
                        _isSignUp
                            ? 'I already have an account'
                            : 'Create a new account',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'If you already have data in your account, signing in '
                      'replaces what is on this device with your account data.',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
