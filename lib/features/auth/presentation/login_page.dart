import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import 'auth_cubit.dart';
import 'auth_widgets.dart';
import 'otp_page.dart';
import 'register_page.dart';

/// Login screen (phone + OTP).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final s = AppStrings.of(context);
    final cubit = context.read<AuthCubit>();
    final ok = await cubit.sendOtp(_phoneController.text.trim());
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.authFailed)));
      return;
    }
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpPage(phone: _phoneController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
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
                    const SizedBox(height: AppSpacing.xl),
                    AuthHeader(title: s.login, subtitle: s.welcomeSubtitle),
                    const SizedBox(height: AppSpacing.xxl),
                    AuthTextField(
                      controller: _phoneController,
                      label: s.phone,
                      hint: s.phoneHint,
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      validator: (v) => !Formatters.isValidLibyanPhone(v)
                          ? s.invalidPhone
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthButton(
                      label: s.sendOtp,
                      loading: state.loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AuthSwitchRow(
                      question: s.needAccount,
                      action: s.signUp,
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterPage(),
                        ),
                      ),
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
