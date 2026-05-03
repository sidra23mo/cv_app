import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/resume.dart';

class CreativeTemplateWidgets {
  static const bg = PdfColor.fromInt(0xFFF5F7FB);
  static const surface = PdfColors.white;
  static const darkHeader = PdfColor.fromInt(0xFF0F172A);
  static const darkText = PdfColor.fromInt(0xFF111827);
  static const mutedText = PdfColor.fromInt(0xFF6B7280);
  static const border = PdfColor.fromInt(0xFFE5E7EB);
  static const accent = PdfColor.fromInt(0xFF2563EB);
  static const accentSoft = PdfColor.fromInt(0xFFEFF4FF);
  static const accentSoft2 = PdfColor.fromInt(0xFFEEF2FF);
  static const white = PdfColors.white;

  static pw.Widget buildSidebar(Resume resume) {
    return pw.SizedBox.shrink();
  }

  static List<pw.Widget> buildContent(Resume resume) {
    final widgets = <pw.Widget>[
      _buildHeader(resume),
      pw.SizedBox(height: 16),
    ];

    void addSection(pw.Widget section) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(22, 0, 22, 14),
          child: section,
        ),
      );
    }

    if (resume.personalInfo.professionalSummary.isNotEmpty) {
      addSection(_buildSectionCard(
        title: 'PROFILE',
        child: pw.Text(
          resume.personalInfo.professionalSummary,
          style: const pw.TextStyle(fontSize: 9.6, height: 1.65, color: darkText),
        ),
      ));
    }

    addSection(_buildContactSkillsLanguages(resume));

    if (resume.experience.isNotEmpty) {
      addSection(_buildSectionCard(
        title: 'EXPERIENCE',
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: resume.experience
              .asMap()
              .entries
              .map((e) => _buildExperienceItem(e.value, isLast: e.key == resume.experience.length - 1))
              .toList(),
        ),
      ));
    }

    if (resume.education.isNotEmpty) {
      addSection(_buildSectionCard(
        title: 'EDUCATION',
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: resume.education
              .asMap()
              .entries
              .map((e) => _buildEducationItem(e.value, isLast: e.key == resume.education.length - 1))
              .toList(),
        ),
      ));
    }

    if (resume.certifications.isNotEmpty) {
      addSection(_buildSectionCard(
        title: 'CERTIFICATIONS',
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: resume.certifications
              .asMap()
              .entries
              .map((e) => _buildCertificationItem(e.value, isLast: e.key == resume.certifications.length - 1))
              .toList(),
        ),
      ));
    }

    if (resume.projects.isNotEmpty) {
      addSection(_buildSectionCard(
        title: 'PROJECTS',
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: resume.projects
              .asMap()
              .entries
              .map((e) => _buildProjectItem(e.value, isLast: e.key == resume.projects.length - 1))
              .toList(),
        ),
      ));
    }

    widgets.add(pw.SizedBox(height: 6));
    return widgets;
  }

  static pw.Widget _buildHeader(Resume resume) {
    final p = resume.personalInfo;
    final initials = _getInitials(p.fullName);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: const pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [PdfColor.fromInt(0xFF0F172A), PdfColor.fromInt(0xFF1E3A8A)],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 54,
            height: 54,
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0x26FFFFFF),
              borderRadius: pw.BorderRadius.circular(14),
              border: pw.Border.all(
                color: const PdfColor.fromInt(0x33FFFFFF),
                width: 0.8,
              ),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              initials,
              style: pw.TextStyle(
                color: white,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  p.fullName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 23,
                    fontWeight: pw.FontWeight.bold,
                    color: white,
                    letterSpacing: 1,
                  ),
                ),
                if (p.title.isNotEmpty) ...[ 
                  pw.SizedBox(height: 5),
                  pw.Text(
                    p.title,
                    style: const pw.TextStyle(
                      fontSize: 11.2,
                      color: PdfColor.fromInt(0xFFDBEAFE),
                    ),
                  ),
                ],
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Container(
                      width: 42,
                      height: 3,
                      decoration: pw.BoxDecoration(
                        color: accent,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Container(
                      width: 18,
                      height: 3,
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFF93C5FD),
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildContactSkillsLanguages(Resume resume) {
    final p = resume.personalInfo;
    final sections = <pw.Widget>[];

    if (p.email.isNotEmpty || p.phone.isNotEmpty || p.location.isNotEmpty) {
      sections.add(
        _buildInfoCard(
          title: 'CONTACT',
          children: [
            if (p.email.isNotEmpty) _buildInfoItem('Email', p.email),
            if (p.phone.isNotEmpty) _buildInfoItem('Phone', p.phone),
            if (p.location.isNotEmpty) _buildInfoItem('Location', p.location),
          ],
        ),
      );
    }

    if (resume.skills.isNotEmpty) {
      if (sections.isNotEmpty) sections.add(pw.SizedBox(height: 12));
      sections.add(
        _buildInfoCard(
          title: 'CORE SKILLS',
          children: [_buildSkillsList(resume.skills)],
        ),
      );
    }

    if (resume.languages.isNotEmpty) {
      if (sections.isNotEmpty) sections.add(pw.SizedBox(height: 12));
      sections.add(
        _buildInfoCard(
          title: 'LANGUAGES',
          children: [_buildLanguagesList(resume.languages)],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: sections,
    );
  }

  static pw.Widget _buildInfoCard({
    required String title,
    required List<pw.Widget> children,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: pw.BoxDecoration(
        color: surface,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: border, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 8,
                decoration: const pw.BoxDecoration(
                  color: accent,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: darkText,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoItem(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: border, width: 0.7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 7.5, color: mutedText),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.8,
              color: darkText,
              fontWeight: pw.FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionCard({
    required String title,
    required pw.Widget child,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: pw.BoxDecoration(
        color: surface,
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: border, width: 0.85),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [_buildSectionTitle(title), child],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        children: [
          pw.Container(
            width: 4,
            height: 16,
            decoration: pw.BoxDecoration(
              color: accent,
              borderRadius: pw.BorderRadius.circular(4),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: darkText,
              letterSpacing: 0.7,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Container(height: 1, color: border)),
        ],
      ),
    );
  }

  static pw.Widget _buildExperienceItem(Experience exp, {bool isLast = false}) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration:
          !isLast
              ? pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: border, width: 0.6),
                ),
              )
              : null,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 10,
                height: 10,
                margin: const pw.EdgeInsets.only(top: 2),
                decoration: const pw.BoxDecoration(
                  color: accent,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                                  color: darkText,
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: accentSoft,
                                  borderRadius: pw.BorderRadius.circular(20),
                                ),
                                child: pw.Text(
                                  exp.company,
                                  style: pw.TextStyle(
                                    fontSize: 8.3,
                                    color: accent,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: pw.BoxDecoration(
                            color: const PdfColor.fromInt(0xFFF8FAFC),
                            borderRadius: pw.BorderRadius.circular(10),
                            border: pw.Border.all(color: border, width: 0.7),
                          ),
                          child: pw.Text(
                            _formatDateRange(
                              exp.startDate,
                              exp.endDate,
                              exp.current,
                            ),
                            style: const pw.TextStyle(
                              fontSize: 7.9,
                              color: mutedText,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    if (exp.achievements.isNotEmpty) ...[ 
                      pw.SizedBox(height: 8),
                      ...exp.achievements.map(
                        (a) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 5),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                '- ',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: accent,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  a,
                                  style: const pw.TextStyle(
                                    fontSize: 8.9,
                                    height: 1.5,
                                    color: darkText,
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildEducationItem(Education edu, {bool isLast = false}) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration:
          !isLast
              ? pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: border, width: 0.6),
                ),
              )
              : null,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 10,
            height: 10,
            margin: const pw.EdgeInsets.only(top: 2),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF4F46E5),
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${edu.degree}${edu.field.isNotEmpty ? ' in ${edu.field}' : ''}',
                        style: pw.TextStyle(
                          fontSize: 10.5,
                          fontWeight: pw.FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        edu.institution,
                        style: pw.TextStyle(
                          fontSize: 9.2,
                          color: accent,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (edu.gpa != null && edu.gpa!.isNotEmpty) ...[ 
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'GPA: ${edu.gpa}',
                          style: const pw.TextStyle(
                            fontSize: 8.2,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: pw.BoxDecoration(
                    color: accentSoft2,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    _formatDate(edu.graduationDate),
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColor.fromInt(0xFF4338CA),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCertificationItem(
    Certification cert, {
    bool isLast = false,
  }) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration:
          !isLast
              ? pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: border, width: 0.6),
                ),
              )
              : null,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cert.name,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: darkText,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            cert.issuer,
            style: pw.TextStyle(
              fontSize: 8.6,
              color: accent,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _formatDate(cert.date),
            style: const pw.TextStyle(fontSize: 8.2, color: mutedText),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProjectItem(Project proj, {bool isLast = false}) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const pw.EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF9FBFF),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFD6E4FF),
          width: 0.8,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            proj.name,
            style: pw.TextStyle(
              fontSize: 10.2,
              fontWeight: pw.FontWeight.bold,
              color: darkText,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            proj.description,
            style: const pw.TextStyle(
              fontSize: 8.8,
              height: 1.5,
              color: darkText,
            ),
          ),
          if (proj.technologies.isNotEmpty) ...[ 
            pw.SizedBox(height: 7),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  proj.technologies
                      .split(',')
                      .map((tech) => tech.trim())
                      .where((tech) => tech.isNotEmpty)
                      .map(
                        (tech) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            color: accentSoft,
                            borderRadius: pw.BorderRadius.circular(20),
                          ),
                          child: pw.Text(
                            tech,
                            style: pw.TextStyle(
                              fontSize: 7.8,
                              color: accent,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildSkillsList(List<Skill> skills) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          skills
              .map(
                (skill) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: accentSoft,
                    borderRadius: pw.BorderRadius.circular(20),
                    border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFCFE0FF),
                      width: 0.7,
                    ),
                  ),
                  child: pw.Text(
                    skill.name,
                    style: pw.TextStyle(
                      fontSize: 8.2,
                      color: darkText,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  static pw.Widget _buildLanguagesList(List<Language> languages) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          languages
              .map(
                (lang) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFF8FAFC),
                    borderRadius: pw.BorderRadius.circular(20),
                    border: pw.Border.all(color: border, width: 0.7),
                  ),
                  child: pw.Text(
                    '${lang.language} - ${_getProficiencyLabel(lang.proficiency)}',
                    style: const pw.TextStyle(fontSize: 8.2, color: darkText),
                  ),
                ),
              )
              .toList(),
    );
  }

  static String _getInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
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

  static String _formatDateRange(
    DateTime startDate,
    DateTime? endDate,
    bool isCurrentJob,
  ) {
    final start = _formatDate(startDate);
    if (isCurrentJob) return '$start - Present';
    if (endDate != null) return '$start - ${_formatDate(endDate)}';
    return start;
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
