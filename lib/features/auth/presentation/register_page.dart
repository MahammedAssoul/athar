import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import 'auth_cubit.dart';
import 'auth_widgets.dart';
import 'login_page.dart';
import 'otp_page.dart';

/// Registration screen (profile creation after OTP).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
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
          builder: (_) => OtpPage(
            phone: _phoneController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
          ),
        ),
      );
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
                    AuthHeader(
                      title: s.registerTitle,
                      subtitle: s.registerSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      controller: _firstNameController,
                      label: s.firstName,
                      hint: s.firstName,
                      icon: Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? s.requiredField
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      controller: _lastNameController,
                      label: s.lastName,
                      hint: s.lastName,
                      icon: Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? s.requiredField
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
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
                      controller: _emailController,
                      label: s.email,
                      hint: s.emailHint,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      controller: _cityController,
                      label: s.city,
                      hint: s.cityHint,
                      icon: Icons.location_city,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthButton(
                      label: s.sendOtp,
                      loading: state.loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AuthSwitchRow(
                      question: s.haveAccount,
                      action: s.signIn,
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginPage(),
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
