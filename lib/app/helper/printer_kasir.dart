import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintKasir extends StatefulWidget {
  const PrintKasir({
    super.key,
  });
  @override
  // ignore: no_logic_in_create_state
  PrintKasirState createState() => PrintKasirState(dataPrint: null);
}

class PrintKasirState extends State<PrintKasir> {
  final Map<String, dynamic>? dataPrint;
  PrintKasirState({required this.dataPrint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Printing"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ElevatedButton(
              onPressed: null,
              child: Text(
                'Create & Print PDF',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _displayPdf,
              child: const Text(
                'Display PDF',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: generatePdf,
              child: const Text(
                'Generate Advanced PDF',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// create PDF & print it
  createPdf() async {
    final doc = pw.Document();

    /// for using an image from assets
    // final image = await imageFromAssetBundle('assets/logo.png');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw
              .Column(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
            // pw.Image(image),
            pw.Text('Saputra Car Wash'),
            pw.Text('Profesional Auto Detailing'),
            pw.Text('${dataPrint!["kota"]}'),
            pw.SizedBox(height: 35),
            pw.Row(children: [
              pw.Expanded(flex: 1, child: pw.Text('No Trx')),
              pw.Expanded(flex: 3, child: pw.Text(' : ${dataPrint!["no_trx"]}'))
            ]),
            pw.Row(children: [
              pw.Expanded(flex: 1, child: pw.Text('Tanggal')),
              pw.Expanded(
                  flex: 3, child: pw.Text(' : ${dataPrint!["tanggal"]}'))
            ]),
            pw.Row(children: [
              pw.Expanded(flex: 1, child: pw.Text('Kasir')),
              pw.Expanded(flex: 3, child: pw.Text(' : ${dataPrint!["kasir"]}'))
            ]),
            pw.SizedBox(height: 35),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${dataPrint!["kendaraan"]}'),
                  pw.Text('${dataPrint!["nopol"]}'),
                ]),
            pw.SizedBox(height: 15),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Petugas',
                    ),
                  ),
                  pw.Expanded(
                      flex: 3, child: pw.Text(' : ${dataPrint!["petugas"]}')),
                ]),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Services',
                  ),
                  pw.Text(
                    'Total',
                  ),
                ]),
            pw.Divider(),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(dataPrint!["service_name"]),
                  pw.Text(dataPrint!["harga"]),
                ]),
            pw.Divider(),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total'),
                  pw.Text(NumberFormat.simpleCurrency(
                          locale: 'in', decimalDigits: 0)
                      .format(dataPrint!["grand_total"])
                      .toString()),
                ]),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Bayar'),
                  pw.Text(NumberFormat.simpleCurrency(
                          locale: 'in', decimalDigits: 0)
                      .format(dataPrint!["bayar"])
                      .toString()),
                ]),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Kembali'),
                  pw.Text(NumberFormat.simpleCurrency(
                          locale: 'in', decimalDigits: 0)
                      .format(dataPrint!["kembali"])
                      .toString()),
                ]),
            pw.SizedBox(height: 15),
            pw.Text(dataPrint!["pembayaran"]),
            pw.SizedBox(height: 35),
            pw.Text('-- Terima Kasih --'),
            pw.SizedBox(height: 35),
            pw.Text(dataPrint!["alamat"], textAlign: pw.TextAlign.center),
            // pw.Text(dataPrint!["kota"]),
            // }
          ]); // Center
        },
      ),
    ); // Page

    /// print the document using the iOS or Android print service:
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());

    /// share the document to other applications:
    // await Printing.sharePdf(bytes: await doc.save(), filename: 'my-document.pdf');

    /// tutorial for using path_provider: https://www.youtube.com/watch?v=fJtFDrjEvE8
    /// save PDF with Flutter library "path_provider":
    // final output = await getTemporaryDirectory();
    // final file = File('${output.path}/example.pdf');
    // await file.writeAsBytes(await doc.save());
  }

  /// display a pdf document.
  void _displayPdf() {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              'Hello eclectify Enthusiast',
              style: const pw.TextStyle(fontSize: 30),
            ),
          );
        },
      ),
    );

    /// open Preview Screen
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(doc: doc),
        ));
  }

  /// Convert a Pdf to images, one image per page, get only pages 1 and 2 at 72 dpi
  void _convertPdfToImages(pw.Document doc) async {
    await for (var page
        in Printing.raster(await doc.save(), pages: [0, 1], dpi: 72)) {
      final image = page.toImage(); // ...or page.toPng()
      // print(image);
    }
  }

  /// print an existing Pdf file from a Flutter asset
  void _printExistingPdf() async {
    // import 'package:flutter/services.dart';
    final pdf = await rootBundle.load('assets/document.pdf');
    await Printing.layoutPdf(onLayout: (_) => pdf.buffer.asUint8List());
  }

  /// more advanced PDF styling
  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            children: [
              pw.SizedBox(
                width: double.infinity,
                child: pw.FittedBox(
                  child: pw.Text(title, style: pw.TextStyle(font: font)),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Flexible(child: pw.FlutterLogo())
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  void generatePdf() async {
    const title = 'eclectify Demo';
    await Printing.layoutPdf(onLayout: (format) => _generatePdf(format, title));
  }
}

class PreviewScreen extends StatelessWidget {
  final pw.Document doc;

  const PreviewScreen({
    Key? key,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        centerTitle: true,
        title: const Text("Preview"),
      ),
      body: PdfPreview(
        build: (format) => doc.save(),
        allowSharing: true,
        allowPrinting: true,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: "mydoc.pdf",
      ),
    );
  }
}
