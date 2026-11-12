import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camcode/main.dart';
import 'package:camcode/widgets/feature_card.dart';
import 'package:camcode/widgets/scan_result_sheet.dart';

void main() {
  testWidgets('SnapScan smoke test - renders MainMenuScreen on mobile', (WidgetTester tester) async {
    // Set screen size to mobile portrait (390 x 844)
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SnapScanApp());

    // Verify title and cards are present
    expect(find.text('Cam & Scan'), findsOneWidget);
    expect(find.text('Ambil & Edit Gambar'), findsOneWidget);
    expect(find.text('Scan Barcode'), findsOneWidget);

    // Verify cards have equal width and height (square aspect ratio)
    final cards = tester.widgetList<FeatureCard>(find.byType(FeatureCard)).toList();
    expect(cards.length, 2);

    final card1Size = tester.getSize(find.byType(FeatureCard).first);
    expect(card1Size.width, card1Size.height); // Panjang == Lebar
  });

  testWidgets('SnapScan dynamic layout test - wide screen (Row / kanan-kiri)', (WidgetTester tester) async {
    // Set screen size to tablet/desktop wide (800 x 600)
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SnapScanApp());

    // Verify Row exists containing both cards in wide mode
    expect(find.byType(Row), findsWidgets);
    final card1Size = tester.getSize(find.byType(FeatureCard).first);
    final card2Size = tester.getSize(find.byType(FeatureCard).last);

    // Both cards must have equal width and height
    expect(card1Size.width, card1Size.height);
    expect(card2Size.width, card2Size.height);
    expect(card1Size.width, card2Size.width);
  });

  testWidgets('ScanResultSheet triggers onScanAgain callback', (WidgetTester tester) async {
    bool scanAgainTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScanResultSheet(
            scannedData: '1234567890',
            barcodeFormat: 'QR_CODE',
            onScanAgain: () {
              scanAgainTriggered = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Hasil Scan'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('QR_CODE'), findsOneWidget);

    // Tap 'Scan Lagi' button
    await tester.tap(find.text('Scan Lagi'));
    await tester.pumpAndSettle();

    expect(scanAgainTriggered, isTrue);
  });
}
