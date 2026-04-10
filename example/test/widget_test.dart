// Smoke test for the Dyplink example app shell.

import 'package:dyplink_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App shell renders with AppBar title', (tester) async {
    await tester.pumpWidget(const DyplinkExampleApp());
    expect(find.text('Dyplink Example'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
