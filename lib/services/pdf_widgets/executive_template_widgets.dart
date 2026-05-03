import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/resume.dart';

class ExecutiveTemplateWidgets {
  static const black = PdfColors.black;
  static const white = PdfColors.white;
  static const lightGray = PdfColor.fromInt(0xFFF5F5F5);
  static const darkGray = PdfColor.fromInt(0xFF333333);
  static const lineColor = PdfColor.fromInt(0xFFDDDDDD);

  static pw.Widget buildSidebar(Resume resume) {
    return pw.SizedBox.shrink();
  }

  static List<pw.Widget> buildContent(Resume resume) {
    final widgets = <pw.Widget>[];

    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(28, 24, 28, 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(resume),

            if (resume.personalInfo.professionalSummary.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _buildSection(
                title: 'PROFESSIONAL SUMMARY',
                child: pw.Text(
                  resume.personalInfo.professionalSummary,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    height: 1.55,
                    color: darkGray,
                  ),
                ),
              ),
            ],

            if (resume.experience.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _buildSection(
                title: 'WORK EXPERIENCE',
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      resume.experience
                          .map((exp) => _buildExperienceItem(exp))
                          .toList(),
                ),
              ),
            ],

            if (resume.education.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _buildSection(
                title: 'EDUCATION',
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      resume.education
                          .map((edu) => _buildEducationItem(edu))
                          .toList(),
                ),
              ),
            ],

            if (resume.skills.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _buildSection(
                title: 'SKILLS',
                child: _buildSkillsList(resume.skills),
              ),
            ],

            if (resume.certifications.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _buildSection(
                title: 'CERTIFICATIONS',
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      resume.certifications
                          .map((cert) => _buildCertificationItem(cert))
                          .toList(),
                ),
              ),
            ],

            if (resume.languages.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _buildSection(
                title: 'LANGUAGES',
                child: _buildLanguagesList(resume.languages),
              ),
            ],

            if (resume.projects.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _buildSection(
                title: 'PROJECTS',
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      resume.projects
                          .map((proj) => _buildProjectItem(proj))
                          .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return widgets;
  }

  static pw.Widget _buildHeader(Resume resume) {
    final personalInfo = resume.personalInfo;

    final contactItems = <String>[
      if (personalInfo.email.isNotEmpty) personalInfo.email,
      if (personalInfo.phone.isNotEmpty) personalInfo.phone,
      if (personalInfo.location.isNotEmpty) personalInfo.location,
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          personalInfo.fullName.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: black,
            letterSpacing: 0.8,
          ),
        ),
        if (personalInfo.title.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            personalInfo.title,
            style: pw.TextStyle(fontSize: 12, color: darkGray),
          ),
        ],
        if (contactItems.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text(
            contactItems.join('  |  '),
            style: const pw.TextStyle(fontSize: 9.5, color: darkGray),
          ),
        ],
        pw.SizedBox(height: 14),
        pw.Container(height: 1, color: lineColor),
      ],
    );
  }

  static pw.Widget _buildSection({
    required String title,
    required pw.Widget child,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [_buildSectionTitle(title), child],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: black,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(height: 0.8, color: lineColor),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildSkillsList(List<Skill> skills) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          skills.map((skill) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(
                skill.name,
                style: const pw.TextStyle(fontSize: 9.5, color: darkGray),
              ),
            );
          }).toList(),
    );
  }

  static pw.Widget _buildLanguagesList(List<Language> languages) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          languages.map((lang) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                '${lang.language} - ${_getProficiencyLabel(lang.proficiency)}',
                style: const pw.TextStyle(fontSize: 9.5, color: darkGray),
              ),
            );
          }).toList(),
    );
  }

  static pw.Widget _buildExperienceItem(Experience exp) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      exp.position,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: black,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      exp.company,
                      style: const pw.TextStyle(fontSize: 10, color: darkGray),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                _formatDate(exp.startDate),
                style: const pw.TextStyle(fontSize: 9, color: darkGray),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          if (exp.achievements.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...exp.achievements.map(
              (achievement) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  '- $achievement',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    height: 1.4,
                    color: darkGray,
                  ),
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
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${edu.degree}${edu.field.isNotEmpty ? ' in ${edu.field}' : ''}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: black,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  edu.institution,
                  style: const pw.TextStyle(fontSize: 10, color: darkGray),
                ),
                if (edu.gpa != null && edu.gpa!.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'GPA: ${edu.gpa}',
                    style: const pw.TextStyle(fontSize: 9, color: darkGray),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Text(
            _formatDate(edu.graduationDate),
            style: const pw.TextStyle(fontSize: 9, color: darkGray),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCertificationItem(Certification cert) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cert.name,
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: black,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${cert.issuer} | ${_formatDate(cert.date)}',
            style: const pw.TextStyle(fontSize: 9, color: darkGray),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProjectItem(Project proj) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            proj.name,
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: black,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            proj.description,
            style: const pw.TextStyle(
              fontSize: 9,
              height: 1.45,
              color: darkGray,
            ),
          ),
          if (proj.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Technologies: ${proj.technologies}',
              style: const pw.TextStyle(fontSize: 9, color: darkGray),
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
