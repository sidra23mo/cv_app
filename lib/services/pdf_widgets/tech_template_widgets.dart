import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/resume.dart';
import 'shared_pdf_helpers.dart';

class TechTemplateWidgets {
  static const primaryColor = PdfColor.fromInt(0xFF1E40AF);
  static const accentColor = PdfColor.fromInt(0xFF3B82F6);
  static const darkColor = PdfColor.fromInt(0xFF1E293B);

  static List<pw.Widget> buildTemplate(Resume resume) {
    final personalInfo = resume.personalInfo;

    final widgets = <pw.Widget>[
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(colors: [primaryColor, accentColor]),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  personalInfo.fullName,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  personalInfo.title,
                  style: const pw.TextStyle(
                    fontSize: 13,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          pw.Row(
            children: [
              if (personalInfo.email.isNotEmpty) ...[
                pw.Text(
                  personalInfo.email,
                  style: const pw.TextStyle(fontSize: 9, height: 1.4),
                ),
                if (personalInfo.phone.isNotEmpty)
                  pw.Text('  |  ', style: const pw.TextStyle(fontSize: 9)),
              ],
              if (personalInfo.phone.isNotEmpty) ...[
                pw.Text(
                  personalInfo.phone,
                  style: const pw.TextStyle(fontSize: 9, height: 1.4),
                ),
                if (personalInfo.location.isNotEmpty)
                  pw.Text('  |  ', style: const pw.TextStyle(fontSize: 9)),
              ],
              if (personalInfo.location.isNotEmpty)
                pw.Text(
                  personalInfo.location,
                  style: const pw.TextStyle(fontSize: 9, height: 1.4),
                ),
            ],
          ),
          pw.SizedBox(height: 18),

          if (personalInfo.professionalSummary.isNotEmpty) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFEFF6FF),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 3,
                    height: 60,
                    color: primaryColor,
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Text(
                      personalInfo.professionalSummary,
                      style: const pw.TextStyle(fontSize: 10, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          if (resume.experience.isNotEmpty) ...[
            _buildSectionHeader('Experience'),
            ...resume.experience.map((exp) => _buildExperienceItem(exp)),
          ],

          if (resume.education.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _buildSectionHeader('Education'),
            ...resume.education.map((edu) => _buildEducationItem(edu)),
          ],

          if (resume.skills.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _buildSectionHeader('Skills'),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: resume.skills
                  .map(
                    (skill) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        gradient: pw.LinearGradient(
                          colors: [primaryColor, accentColor],
                        ),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        skill.name,
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          if (resume.projects.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _buildSectionHeader('Projects'),
            ...resume.projects.map((proj) => _buildProjectItem(proj)),
          ],

          if (resume.languages.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _buildSectionHeader('Languages'),
            pw.Wrap(
              spacing: 16,
              runSpacing: 8,
              children: resume.languages
                  .map(
                    (lang) => pw.Text(
                      '${lang.language} (${_getLanguageLabel(lang.proficiency)})',
                      style: const pw.TextStyle(fontSize: 10, height: 1.4),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    ];

    if (resume.certifications.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 24));
      widgets.add(_buildSectionHeader('Certifications'));
      for (final cert in resume.certifications) {
        widgets.add(
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [PdfColor.fromInt(0xFFEFF6FF), PdfColors.white],
              ),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  cert.name,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  cert.issuer,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
                if (cert.credentialId != null && cert.credentialId!.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'ID: ${cert.credentialId}',
                    style: pw.TextStyle(fontSize: 8, color: accentColor),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFEFF6FF),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 3,
            height: 16,
            color: primaryColor,
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildExperienceItem(Experience exp) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 18),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  exp.position,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: darkColor,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFEFF6FF),
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  '${SharedPdfHelpers.formatDate(exp.startDate)} - ${exp.current ? 'Present' : SharedPdfHelpers.formatDate(exp.endDate ?? exp.startDate)}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: primaryColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${exp.company}${exp.location.isNotEmpty ? ', ${exp.location}' : ''}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          if (exp.achievements.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...exp.achievements.map(
              (a) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 5),
                      width: 3,
                      height: 3,
                      decoration: pw.BoxDecoration(
                        color: accentColor,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(
                        a,
                        style: const pw.TextStyle(fontSize: 9, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildEducationItem(Education edu) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${edu.degree}${edu.field.isNotEmpty ? ' in ${edu.field}' : ''}',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: darkColor,
            ),
          ),
          pw.Text(
            '${edu.institution}, ${edu.location}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Row(
            children: [
              pw.Text(
                SharedPdfHelpers.formatDate(edu.graduationDate),
                style: pw.TextStyle(fontSize: 9, color: primaryColor),
              ),
              if (edu.gpa != null && edu.gpa!.isNotEmpty) ...[
                pw.SizedBox(width: 12),
                pw.Text(
                  'GPA: ${edu.gpa}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProjectItem(Project proj) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFAFAFA),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: accentColor, width: 2),
              ),
            ),
            child: pw.Text(
              proj.name,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            proj.description,
            style: const pw.TextStyle(fontSize: 9, height: 1.5),
          ),
          if (proj.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              proj.technologies,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
          if (proj.link.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              proj.link,
              style: pw.TextStyle(fontSize: 8, color: primaryColor),
            ),
          ],
        ],
      ),
    );
  }

  static String _getLanguageLabel(LanguageProficiency proficiency) {
    switch (proficiency) {
      case LanguageProficiency.basic:
        return 'Basic';
      case LanguageProficiency.conversational:
        return 'Conversational';
      case LanguageProficiency.fluent:
        return 'Fluent';
      case LanguageProficiency.native:
        return 'Native';
    }
  }
}