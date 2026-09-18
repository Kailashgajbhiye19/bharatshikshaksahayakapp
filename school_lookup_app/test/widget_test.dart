import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:school_lookup_app/features/auth/presentation/pages/login_page.dart';

void main() {
  setUpAll(() async {
    // The login page reads remembered-session preferences from this local box.
    Hive.init(Directory.systemTemp.createTempSync('bss_test_').path);
    await Hive.openBox('settings');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('login screen shows the real authentication form', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: LoginPage()),
    ));

    expect(find.text('Teacher ID or Email'), findsOneWidget);
    expect(find.text('Login to Dashboard  →'), findsOneWidget);
  });
}
