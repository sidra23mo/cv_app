import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/resume.dart';

class ModernTemplateWidgets {
  static const primaryColor = PdfColor.fromInt(0xFF1F2937);
  static const accentColor = PdfColor.fromInt(0xFF3B82F6);
  static const lightGray = PdfColor.fromInt(0xFFF3F4F6);
  static const borderColor = PdfColor.fromInt(0xFFE5E7EB);

  static pw.Widget buildSidebar(Resume resume) {
    return pw.SizedBox.shrink();
  }

  static List<pw.Widget> buildContent(Resume resume) {
    final personalInfo = resume.personalInfo;
    final widgets = <pw.Widget>[];

    // Clean header
    widgets.add(
      pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(28, 24, 28, 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              personalInfo.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
                letterSpacing: 1,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              personalInfo.title,
              style: pw.TextStyle(
                fontSize: 12,
                color: accentColor,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                if (personalInfo.email.isNotEmpty) ...[
                  pw.Text(
                    personalInfo.email,
                    style: const pw.TextStyle(fontSize: 8, color: primaryColor),
                  ),
                  pw.SizedBox(width: 16),
                ],
                if (personalInfo.phone.isNotEmpty) ...[
                  pw.Text(
                    personalInfo.phone,
                    style: const pw.TextStyle(fontSize: 8, color: primaryColor),
                  ),
                  pw.SizedBox(width: 16),
                ],
                if (personalInfo.location.isNotEmpty)
                  pw.Text(
                    personalInfo.location,
                    style: const pw.TextStyle(fontSize: 8, color: primaryColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    // Divider line
    widgets.add(pw.Container(height: 1.5, color: borderColor));

    // Professional Summary
    if (personalInfo.professionalSummary.isNotEmpty) {
      widgets.add(_buildSectionTitle('PROFESSIONAL SUMMARY'));
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 16),
          child: pw.Text(
            personalInfo.professionalSummary,
            style: const pw.TextStyle(
              fontSize: 9,
              height: 1.6,
              color: primaryColor,
            ),
          ),
        ),
      );
    }

    // Experience
    if (resume.experience.isNotEmpty) {
      widgets.add(_buildSectionTitle('EXPERIENCE'));
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:
                resume.experience
                    .map((exp) => _buildExperienceItem(exp))
                    .toList(),
          ),
        ),
      );
    }

    // Education
    if (resume.education.isNotEmpty) {
      widgets.add(_buildSectionTitle('EDUCATION'));
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:
                resume.education
                    .map((edu) => _buildEducationItem(edu))
                    .toList(),
          ),
        ),
      );
    }

    // Skills
    if (resume.skills.isNotEmpty) {
      widgets.add(_buildSectionTitle('SKILLS'));
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 16),
          child: pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: resume.skills.map((s) => _buildSkillTag(s.name)).toList(),
          ),
        ),
      );
    }

    // Certifications
    if (resume.certifications.isNotEmpty) {
      widgets.add(_buildSectionTitle('CERTIFICATIONS'));
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:
                resume.certifications
                    .map((cert) => _buildCertificationItem(cert))
                    .toList(),
          ),
        ),
      );
    }

    // Languages
    if (resume.languages.isNotEmpty) {
      widgets.add(_buildSectionTitle('LANGUAGES'));
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 16),
          child: pw.Wrap(
            spacing: 20,
            runSpacing: 8,
            children:
                resume.languages
                    .map((lang) => _buildLanguageItem(lang))
                    .toList(),
          ),
        ),
      );
    }

    // Projects
    if (resume.projects.isNotEmpty) {
      widgets.add(_buildSectionTitle('PROJECTS'));
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:
                resume.projects.map((proj) => _buildProjectItem(proj)).toList(),
          ),
        ),
      );
    }

    return widgets;
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(28, 12, 28, 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Expanded(child: pw.Container(height: 1, color: borderColor)),
          pw.SizedBox(width: 12),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.8,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(child: pw.Container(height: 1, color: borderColor)),
        ],
      ),
    );
  }

  static pw.Widget _buildSkillTag(String skill) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: lightGray,
        border: pw.Border.all(color: accentColor, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        skill,
        style: pw.TextStyle(
          fontSize: 8,
          color: primaryColor,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildExperienceItem(Experience exp) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
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
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              pw.Text(
                _formatDate(exp.startDate),
                style: pw.TextStyle(
                  fontSize: 8,
                  color: accentColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            exp.company,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromInt(0xFF6B7280),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (exp.location.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              exp.location,
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColor.fromInt(0xFF9CA3AF),
              ),
            ),
          ],
          if (exp.achievements.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...exp.achievements
                .map(
                  (a) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          margin: const pw.EdgeInsets.only(top: 3),
                          width: 2.5,
                          height: 2.5,
                          decoration: pw.BoxDecoration(
                            color: accentColor,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 6),
                        pw.Expanded(
                          child: pw.Text(
                            a,
                            style: const pw.TextStyle(
                              fontSize: 8,
                              height: 1.4,
                              color: primaryColor,
                            ),
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
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${edu.degree}${edu.field.isNotEmpty ? ' in ${edu.field}' : ''}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            edu.institution,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromInt(0xFF6B7280),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            children: [
              pw.Text(
                _formatDate(edu.graduationDate),
                style: pw.TextStyle(
                  fontSize: 8,
                  color: accentColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (edu.gpa != null && edu.gpa!.isNotEmpty) ...[
                pw.Text(
                  ' | ',
                  style: const pw.TextStyle(fontSize: 8, color: primaryColor),
                ),
                pw.Text(
                  'GPA: ${edu.gpa}',
                  style: const pw.TextStyle(fontSize: 8, color: primaryColor),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCertificationItem(Certification cert) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cert.name,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            children: [
              pw.Text(
                cert.issuer,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromInt(0xFF6B7280),
                ),
              ),
              pw.Text(
                ' | ',
                style: const pw.TextStyle(fontSize: 8, color: primaryColor),
              ),
              pw.Text(
                _formatDate(cert.date),
                style: pw.TextStyle(
                  fontSize: 8,
                  color: accentColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildLanguageItem(Language lang) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: lightGray,
        border: pw.Border.all(color: borderColor, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            lang.language,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _getProficiencyLabel(lang.proficiency),
            style: pw.TextStyle(
              fontSize: 8,
              color: accentColor,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProjectItem(Project proj) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            proj.name,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            proj.description,
            style: const pw.TextStyle(
              fontSize: 8,
              height: 1.4,
              color: primaryColor,
            ),
          ),
          if (proj.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Tech: ${proj.technologies}',
              style: pw.TextStyle(
                fontSize: 8,
                color: accentColor,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String _getProficiencyLabel(LanguageProficiency proficiency) {
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
