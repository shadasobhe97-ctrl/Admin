import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('PDF package can create a document with local Tajawal font and Arabic text', () async {
    final pdf = pw.Document();

    final fontBytes = await File('lib/fonts/Tajawal-Regular.ttf').readAsBytes();
    final boldFontBytes = await File('lib/fonts/Tajawal-Bold.ttf').readAsBytes();

    final font = pw.Font.ttf(Uint8List.fromList(fontBytes).buffer.asByteData());
    final boldFont = pw.Font.ttf(Uint8List.fromList(boldFontBytes).buffer.asByteData());

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Center(
              child: pw.Text(
                'منظومة دَربِي للنقل المدرسي - تقرير تجريبي',
                style: pw.TextStyle(font: boldFont, fontSize: 18),
              ),
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(100));
  });
}
