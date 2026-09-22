import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'auth_cubit.dart';
import 'auth_widgets.dart';

/// OTP verification screen.
///
/// When [firstName] is provided the flow registers a new user,
/// otherwise it logs in an existing one.
class OtpPage extends StatefulWidget {
  const OtpPage({
    super.key,
    required this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.city,
  });

  final String phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? city;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final s = AppStrings.of(context);
    final cubit = context.read<AuthCubit>();
    setState(() => _submitting = true);

    final isRegister = widget.firstName != null;
    final user = isRegister
        ? await cubit.register(
            phone: widget.phone,
            otp: _otpController.text.trim(),
            firstName: widget.firstName!,
            lastName: widget.lastName ?? '',
            email: widget.email,
            city: widget.city,
          )
        : await cubit.login(widget.phone, _otpController.text.trim());

    setState(() => _submitting = false);
    if (!mounted) return;

    if (user != null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.invalidOtp)));
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  AuthHeader(title: s.otpTitle, subtitle: s.otpSubtitle),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    widget.phone,
                    style: AppTypography.title.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(letterSpacing: 12),
                    decoration: InputDecoration(
                      hintText: '••••',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      s.otpDemoNote,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AuthButton(
                    label: s.verify,
                    loading: _submitting || state.loading,
                    onPressed: _verify,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final cubit = context.read<AuthCubit>();
                      await cubit.sendOtp(widget.phone);
                      messenger.showSnackBar(
                        SnackBar(content: Text(s.otpSent)),
                      );
                    },
                    child: Text(s.resendCode),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
