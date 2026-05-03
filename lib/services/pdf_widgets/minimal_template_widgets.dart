import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/resume.dart';
import 'shared_pdf_helpers.dart';

class MinimalTemplateWidgets {
  static const primaryColor = PdfColor.fromInt(0xFF2D2D2D);
  static const accentColor = PdfColor.fromInt(0xFFB76E79);

  static List<pw.Widget> buildTemplate(Resume resume) {
    final personalInfo = resume.personalInfo;

    final widgets = <pw.Widget>[
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            personalInfo.fullName,
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            personalInfo.title,
            style: pw.TextStyle(fontSize: 12, color: accentColor, height: 1.4),
          ),
          pw.SizedBox(height: 4),
          pw.Container(height: 2, width: 50, color: accentColor),
          pw.SizedBox(height: 16),

          pw.Row(
            children: [
              if (personalInfo.email.isNotEmpty) ...[
                pw.Text(
                  personalInfo.email,
                  style: const pw.TextStyle(fontSize: 10, height: 1.4),
                ),
                if (personalInfo.phone.isNotEmpty)
                  pw.Text('  |  ', style: const pw.TextStyle(fontSize: 10)),
              ],
              if (personalInfo.phone.isNotEmpty) ...[
                pw.Text(
                  personalInfo.phone,
                  style: const pw.TextStyle(fontSize: 10, height: 1.4),
                ),
                if (personalInfo.location.isNotEmpty)
                  pw.Text('  |  ', style: const pw.TextStyle(fontSize: 10)),
              ],
              if (personalInfo.location.isNotEmpty)
                pw.Text(
                  personalInfo.location,
                  style: const pw.TextStyle(fontSize: 10, height: 1.4),
                ),
            ],
          ),
          pw.SizedBox(height: 20),

          if (personalInfo.professionalSummary.isNotEmpty) ...[
            pw.Text(
              personalInfo.professionalSummary,
              style: const pw.TextStyle(fontSize: 10, height: 1.6),
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
              spacing: 12,
              runSpacing: 8,
              children: resume.skills
                  .map(
                    (skill) => pw.Text(
                      skill.name,
                      style: const pw.TextStyle(fontSize: 10, height: 1.4),
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
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  cert.name,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                    height: 1.4,
                  ),
                ),
                pw.Text(
                  cert.issuer,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                    height: 1.4,
                  ),
                ),
                if (cert.credentialId != null && cert.credentialId!.isNotEmpty)
                  pw.Text(
                    'ID: ${cert.credentialId}',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: accentColor,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Container(height: 1, width: 30, color: PdfColors.grey400),
        ],
      ),
    );
  }

  static pw.Widget _buildExperienceItem(Experience exp) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            exp.position,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              height: 1.4,
            ),
          ),
          pw.Text(
            '${exp.company}${exp.location.isNotEmpty ? ', ${exp.location}' : ''}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              height: 1.4,
            ),
          ),
          pw.Text(
            '${SharedPdfHelpers.formatDate(exp.startDate)} to ${exp.current ? 'Present' : SharedPdfHelpers.formatDate(exp.endDate ?? exp.startDate)}',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey500,
              height: 1.4,
            ),
          ),
          if (exp.achievements.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            ...exp.achievements.map(
              (a) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Text(
                  a,
                  style: const pw.TextStyle(fontSize: 9, height: 1.5),
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
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${edu.degree}${edu.field.isNotEmpty ? ' in ${edu.field}' : ''}',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              height: 1.4,
            ),
          ),
          pw.Text(
            '${edu.institution}, ${edu.location}',
            style: const pw.TextStyle(fontSize: 10, height: 1.4),
          ),
          pw.Row(
            children: [
              pw.Text(
                SharedPdfHelpers.formatDate(edu.graduationDate),
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                  height: 1.4,
                ),
              ),
              if (edu.gpa != null && edu.gpa!.isNotEmpty) ...[
                pw.Text(
                  ' | ',
                  style: const pw.TextStyle(fontSize: 8, height: 1.4),
                ),
                pw.Text(
                  'GPA: ${edu.gpa}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                    height: 1.4,
                  ),
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
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            proj.name,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              height: 1.4,
            ),
          ),
          pw.Text(
            proj.description,
            style: const pw.TextStyle(fontSize: 9, height: 1.5),
          ),
          if (proj.technologies.isNotEmpty)
            pw.Text(
              proj.technologies,
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
                height: 1.4,
              ),
            ),
          if (proj.link.isNotEmpty)
            pw.Text(
              proj.link,
              style: pw.TextStyle(fontSize: 8, color: primaryColor, height: 1.4),
            ),
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