import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_field.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Obx(() {
        final step = controller.step.value;
        // Cross-fade between the two steps; each step re-runs its
        // staggered entrance.
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: step == 0
              ? _RequestStep(key: const ValueKey(0), controller: controller)
              : _ResetStep(key: const ValueKey(1), controller: controller),
        );
      }),
    );
  }
}

class _RequestStep extends StatelessWidget {
  const _RequestStep({super.key, required this.controller});
  final ForgotPasswordController controller;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'auth.forgotPassword'.tr,
      subtitle: 'auth.forgot.subtitle'.tr,
      heroHeight: 230,
      children: [
        _StepHeader(
          step: 0,
          icon: Icons.mark_email_unread_outlined,
          caption: 'auth.forgot.requestCaption'.tr,
        ),
        const SizedBox(height: 24),
        PremiumField(
          controller: controller.emailCtrl,
          label: 'auth.email'.tr,
          hint: 'auth.emailHint'.tr,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          validator: controller.validateEmail,
          onSubmitted: (_) => controller.requestReset(),
        ),
        const SizedBox(height: 24),
        Obx(
              () => PremiumButton(
            label: 'auth.forgot.sendCode'.tr,
            icon: Icons.send_rounded,
            loading: controller.loading.value,
            onPressed: controller.requestReset,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: controller.back,
            child: Text('auth.forgot.backToSignIn'.tr),
          ),
        ),
      ],
    );
  }
}

class _ResetStep extends StatelessWidget {
  const _ResetStep({super.key, required this.controller});
  final ForgotPasswordController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = controller.emailCtrl.text.trim();

    return AuthScaffold(
      title: 'auth.forgot.resetTitle'.tr,
      subtitle: 'auth.forgot.resetSubtitle'.tr,
      heroHeight: 230,
      children: [
        _StepHeader(
          step: 1,
          icon: Icons.lock_reset_rounded,
          caption: email.isEmpty
              ? 'auth.forgot.resetCodeCaptionNoEmail'.tr
              : 'auth.forgot.resetCodeCaption'
                  .trParams({'email': email}),
        ),
        const SizedBox(height: 24),
        PremiumField(
          controller: controller.tokenCtrl,
          label: 'auth.forgot.resetCodeLabel'.tr,
          hint: 'auth.forgot.resetCodeHint'.tr,
          icon: Icons.confirmation_number_outlined,
          textInputAction: TextInputAction.next,
          validator: controller.validateToken,
        ),
        const SizedBox(height: 16),
        Obx(
              () => PremiumField(
            controller: controller.newPasswordCtrl,
            label: 'auth.forgot.newPassword'.tr,
            hint: 'auth.passwordHint'.tr,
            icon: Icons.lock_outline_rounded,
            obscureText: controller.obscureNew.value,
            textInputAction: TextInputAction.next,
            validator: controller.validatePassword,
            suffix: PasswordToggle(
              obscured: controller.obscureNew.value,
              onTap: controller.toggleNew,
            ),
          ),
        ),
        PasswordStrengthMeter(controller: controller.newPasswordCtrl),
        const SizedBox(height: 16),
        _ConfirmField(controller: controller),
        const SizedBox(height: 24),
        Obx(
              () => PremiumButton(
            label: 'auth.forgot.resetPasswordButton'.tr,
            icon: Icons.check_rounded,
            loading: controller.loading.value,
            onPressed: controller.resetPassword,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: controller.back,
            child: Text(
              'auth.forgot.backToSignIn'.tr,
              style: theme.textTheme.labelLarge,
            ),
          ),
        ),
      ],
    );
  }
}

/// The controller has no toggle for the confirm field (it was always
/// obscured), so the eye state lives locally here. No logic changes.
class _ConfirmField extends StatefulWidget {
  const _ConfirmField({required this.controller});
  final ForgotPasswordController controller;

  @override
  State<_ConfirmField> createState() => _ConfirmFieldState();
}

class _ConfirmFieldState extends State<_ConfirmField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return PremiumField(
      controller: c.confirmCtrl,
      label: 'auth.forgot.confirmNewPassword'.tr,
      icon: Icons.lock_outline_rounded,
      obscureText: _obscure,
      textInputAction: TextInputAction.done,
      validator: c.validateConfirm,
      onSubmitted: (_) => c.resetPassword(),
      suffix: PasswordToggle(
        obscured: _obscure,
        onTap: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}

/// Icon badge + "Step x of 2" progress pills + caption.
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.icon,
    required this.caption,
  });

  final int step;
  final IconData icon;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: scheme.primary.withValues(alpha: .1),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: .25),
                ),
              ),
              child: Icon(icon, color: scheme.primary, size: 28),
            )
                .animate(delay: 300.ms)
                .scale(
              begin: const Offset(.6, .6),
              duration: 600.ms,
              curve: Curves.elasticOut,
            )
                .fadeIn(duration: 300.ms),
            const Spacer(),
            Row(
              children: List.generate(2, (i) {
                final active = i <= step;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(left: 6),
                  width: i == step ? 28 : 10,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: active
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: .18),
                  ),
                );
              }),
            ),
            const SizedBox(width: 10),
            Text(
              'common.stepOf'
                  .trParams({'step': '${step + 1}', 'total': '2'}),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: .65),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          caption,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: .7),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}