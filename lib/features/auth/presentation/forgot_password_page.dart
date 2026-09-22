import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import 'auth_cubit.dart';
import 'auth_widgets.dart';

/// Forgot password screen (mock — always succeeds).
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final s = AppStrings.of(context);
    final ok = await context.read<AuthCubit>().resetPassword(
      _phoneController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.passwordResetSuccess)));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    AuthHeader(
                      title: s.forgotPasswordTitle,
                      subtitle: s.forgotPasswordSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      controller: _phoneController,
                      label: s.phone,
                      hint: s.phoneHint,
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      validator: (v) => !Formatters.isValidLibyanPhone(v)
                          ? s.invalidPhone
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      controller: _passwordController,
                      label: s.newPassword,
                      hint: s.newPasswordHint,
                      icon: Icons.lock_outline,
                      obscure: true,
                      validator: (v) =>
                          (v == null || v.length < 6) ? s.requiredField : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthButton(
                      label: s.resetPassword,
                      loading: state.loading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
