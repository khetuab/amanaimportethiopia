import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/animated_check.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_field.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Form(
      key: controller.formKey,
      child: AuthScaffold(
        title: 'auth.welcome'.tr,
        subtitle: 'auth.login.subtitle'.tr,
        children: [
          PremiumField(
            controller: controller.identifierCtrl,
            label: 'auth.login.emailOrPhone'.tr,
            hint: 'auth.login.identifierHint'.tr,
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: controller.validateIdentifier,
          ),
          const SizedBox(height: 16),
          Obx(
                () => PremiumField(
              controller: controller.passwordCtrl,
              label: 'auth.password'.tr,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: controller.obscure.value,
              textInputAction: TextInputAction.done,
              validator: controller.validatePassword,
              onSubmitted: (_) => controller.submit(),
              suffix: PasswordToggle(
                obscured: controller.obscure.value,
                onTap: controller.toggleObscure,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _RememberAndForgot(onForgot: controller.goToForgotPassword),
          const SizedBox(height: 20),
          Obx(
                () => PremiumButton(
              label: 'auth.signIn'.tr,
              icon: Icons.arrow_forward_rounded,
              loading: controller.loading.value,
              onPressed: controller.submit,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('auth.login.newHere'.tr, style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: controller.goToRegister,
                child: Text('auth.createAccount'.tr),
              ),
            ],
          ),
          Text(
            'auth.login.termsNote'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: .6),
            ),
          ),
        ],
      ),
    );
  }
}

class _RememberAndForgot extends StatefulWidget {
  const _RememberAndForgot({required this.onForgot});
  final VoidCallback onForgot;

  @override
  State<_RememberAndForgot> createState() => _RememberAndForgotState();
}

class _RememberAndForgotState extends State<_RememberAndForgot> {
  // UI-only for now. If LoginController gains a rememberMe flag, bind it here.
  bool _remember = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedCheck(
          value: _remember,
          onChanged: (v) => setState(() => _remember = v),
          child: Text('auth.login.rememberMe'.tr, style: Theme.of(context).textTheme.bodySmall),
        ),
        const Spacer(),
        TextButton(
          onPressed: widget.onForgot,
          child: Text('auth.forgotPassword'.tr),
        ),
      ],
    );
  }
}