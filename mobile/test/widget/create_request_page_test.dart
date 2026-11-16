import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField renders label and hint', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AppTextField(label: 'Title', hint: 'MacBook Pro'),
        ),
      ),
    );
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('MacBook Pro'), findsOneWidget);
  });
}
