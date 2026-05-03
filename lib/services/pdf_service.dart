import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/resume.dart';
import 'pdf_widgets/modern_template_widgets.dart';
import 'pdf_widgets/executive_template_widgets.dart';
import 'pdf_widgets/creative_template_widgets.dart';
import 'pdf_widgets/minimal_template_widgets.dart';
import 'pdf_widgets/tech_template_widgets.dart';

class PdfService {
  static Future<void> generateAndPrintResume(Resume resume) async {
    final pdfBytes = await generatePdfWithTemplate(resume, resume.template);
    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  }

  static Future<Uint8List> generatePdfBytes(Resume resume) {
    return generatePdfWithTemplate(resume, resume.template);
  }

  static Future<Uint8List> generatePdfWithTemplate(
    Resume resume,
    TemplateType template,
  ) async {
    final pdf = pw.Document();

    switch (template) {
      case TemplateType.modern:
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (_) => ModernTemplateWidgets.buildContent(resume),
          ),
        );

      case TemplateType.executive:
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (_) => ExecutiveTemplateWidgets.buildContent(resume),
          ),
        );

      case TemplateType.creative:
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (_) => CreativeTemplateWidgets.buildContent(resume),
          ),
        );

      case TemplateType.minimal:
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (_) => MinimalTemplateWidgets.buildTemplate(resume),
          ),
        );

      case TemplateType.tech:
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (_) => TechTemplateWidgets.buildTemplate(resume),
          ),
        );
    }

    return pdf.save();
  }
}
