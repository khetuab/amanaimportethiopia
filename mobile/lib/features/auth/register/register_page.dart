import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/animated_check.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_field.dart';
import '../widgets/role_selector.dart';
import 'register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: controller.formKey,
      child: AuthScaffold(
        title: 'auth.signUp'.tr,
        subtitle: 'auth.register.subtitle'.tr,
        heroHeight: 240,
        children: [
          Text('auth.register.iam'.tr, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Obx(
                () => RoleSelector(
              value: controller.role.value,
              onChanged: controller.setRole,
            ),
          ),
          const SizedBox(height: 8),
          PremiumField(
            controller: controller.nameCtrl,
            label: 'auth.register.fullName'.tr,
            hint: 'auth.register.fullNameHint'.tr,
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: controller.validateName,
          ),
          const SizedBox(height: 16),
          PremiumField(
            controller: controller.emailCtrl,
            label: 'auth.email'.tr,
            hint: 'auth.emailHint'.tr,
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: controller.validateEmail,
          ),
          const SizedBox(height: 16),
          PremiumField(
            controller: controller.phoneCtrl,
            label: 'auth.phone'.tr,
            hint: 'auth.phoneHint'.tr,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: controller.validatePhone,
          ),
          const SizedBox(height: 16),
          Obx(
                () => PremiumField(
              controller: controller.passwordCtrl,
              label: 'auth.password'.tr,
              hint: 'auth.passwordHint'.tr,
              icon: Icons.lock_outline_rounded,
              obscureText: controller.obscurePwd.value,
              textInputAction: TextInputAction.next,
              validator: controller.validatePassword,
              suffix: PasswordToggle(
                obscured: controller.obscurePwd.value,
                onTap: controller.togglePwd,
              ),
            ),
          ),
          PasswordStrengthMeter(controller: controller.passwordCtrl),
          const SizedBox(height: 16),
          Obx(
                () => PremiumField(
              controller: controller.confirmCtrl,
              label: 'auth.register.confirmPassword'.tr,
              icon: Icons.lock_outline_rounded,
              obscureText: controller.obscureConfirm.value,
              textInputAction: TextInputAction.done,
              validator: controller.validateConfirm,
              onSubmitted: (_) => controller.submit(),
              suffix: PasswordToggle(
                obscured: controller.obscureConfirm.value,
                onTap: controller.toggleConfirm,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Obx(
                () => AnimatedCheck(
              value: controller.agreed.value,
              onChanged: (v) => controller.toggleAgreed(v),
              child: Text(
                'auth.register.agreeTerms'.tr,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
                () => PremiumButton(
              label: 'auth.signUp'.tr,
              icon: Icons.arrow_forward_rounded,
              loading: controller.loading.value,
              onPressed: controller.submit,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('auth.alreadyAccount'.tr, style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: controller.goToLogin,
                child: Text('auth.signIn'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}