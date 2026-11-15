import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_stay/app.dart';

void main() {
  testWidgets('splash PetStay menampilkan nama dan tagline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetStayApp());

    expect(find.text('PetStay'), findsOneWidget);
    expect(find.text('Titip tenang, pulang lega'), findsOneWidget);
  });

  testWidgets('peran penitip mendapat panel dan alur laporan khusus', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PetStayApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'penitip@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');
    await tester.tap(find.text('Penitip'));
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Panel Penitip'), findsOneWidget);
    expect(find.text('Ringkasan'), findsOneWidget);
    expect(find.text('Permintaan'), findsOneWidget);
    expect(find.text('Laporan'), findsWidgets);
    expect(find.text('Hewan Saya'), findsNothing);

    await tester.tap(find.text('Permintaan'));
    await tester.pumpAndSettle();
    expect(find.text('Permintaan Penitipan'), findsOneWidget);

    await tester.tap(find.text('Mimi bersama Nadia Putri'));
    await tester.pumpAndSettle();
    expect(find.text('Kirim laporan kepada pemilik'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField),
      'Mimi sudah makan dan bermain.',
    );
    await tester.tap(find.text('Kirim Laporan'));
    await tester.pumpAndSettle();
    expect(find.text('Laporan harian berhasil dikirim.'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Permintaan Penitipan'), findsOneWidget);
    await tester.tap(find.text('Laporan').last);
    await tester.pumpAndSettle();
    expect(find.text('Laporan Harian'), findsOneWidget);
    expect(find.text('Mimi sudah makan dan bermain.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Keluar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Apakah Anda yakin mau keluar dari sistem?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Permintaan'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.text('Apakah Anda yakin mau keluar dari sistem?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Permintaan Penitipan'), findsOneWidget);
  });

  testWidgets('navigasi utama tetap terukur dalam mode landscape', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PetStayApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'pemilik@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');
    final Finder loginButton = find.widgetWithText(FilledButton, 'Masuk');
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Pesanan Saya'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.pets_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Hewan'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Simulasi Offline'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Titipkan dengan tenang'), findsOneWidget);

    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    final Finder offlineSwitch = find.text('Simulasi Offline');
    await tester.ensureVisible(offlineSwitch);
    await tester.pumpAndSettle();
    await tester.tap(offlineSwitch);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Koneksi terputus'), findsOneWidget);

    final Finder retryButton = find.text('Coba Lagi');
    await tester.ensureVisible(retryButton);
    await tester.pumpAndSettle();
    await tester.tap(retryButton);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Koneksi terputus'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulasi Offline'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final Finder sitterName = find.text('Nadia Putri');
    await tester.drag(find.byType(ListView).first, const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(sitterName);
    await tester.pumpAndSettle();
    await tester.tap(sitterName);
    await tester.pumpAndSettle();
    expect(find.text('Detail Penitip'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Pesan Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Form Pemesanan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
