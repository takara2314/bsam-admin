import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bsam_admin/components/battery_and_acc.dart';

void main() {
  testWidgets('renders explicit status text when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BatteryAndAcc(batteryLevel: 80, acc: 0.0, statusText: '手動設定'),
        ),
      ),
    );

    expect(find.text('手動設定'), findsOneWidget);
    expect(find.text('バッテリー: '), findsNothing);
  });

  testWidgets('renders battery and accuracy when no status text exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BatteryAndAcc(batteryLevel: 80, acc: 2.5)),
      ),
    );

    expect(find.text('バッテリー: '), findsOneWidget);
    expect(find.text('2.50m'), findsOneWidget);
  });
}
