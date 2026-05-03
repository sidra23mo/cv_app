// lib/services/export_service.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cross_file/cross_file.dart';
import '../data/models/resume.dart';
import './pdf_service.dart';

class ExportService {
  static Future<void> exportResume({
    required Resume resume,
    required BuildContext context,
    ExportFormat format = ExportFormat.pdf,
  }) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Exporting resume...'),
            ],
          ),
        ),
      );

      final filePath = await _generateExportFile(resume, format);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      await _showExportOptions(context, filePath, resume, format);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Export failed: ${e.toString().substring(0, min(e.toString().length, 100))}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<String> _generateExportFile(
    Resume resume,
    ExportFormat format,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 🔥 SAFER file name: handle missing name and sanitize
    final baseName =
        resume.personalInfo.fullName.isNotEmpty
            ? _sanitizeFileName(resume.personalInfo.fullName)
            : 'Resume';
    final fileName = '${baseName}_Resume_$timestamp';

    String filePath;
    switch (format) {
      case ExportFormat.pdf:
        final pdfBytes = await PdfService.generatePdfBytes(resume);
        filePath = '${tempDir.path}/$fileName.pdf';
        await File(filePath).writeAsBytes(pdfBytes);
        break;
      case ExportFormat.text:
        final textContent = _generateTextResume(resume);
        filePath = '${tempDir.path}/$fileName.txt';
        await File(filePath).writeAsString(textContent);
        break;
      case ExportFormat.html:
        final htmlContent = _generateHtmlResume(resume);
        filePath = '${tempDir.path}/$fileName.html';
        await File(filePath).writeAsString(htmlContent);
        break;
    }
    return filePath;
  }

  // 🔥 NEW: Sanitize file names for all platforms
  static String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
  }

  static Future<void> _showExportOptions(
    BuildContext context,
    String filePath,
    Resume resume,
    ExportFormat format,
  ) async {
    // 🔥 Use actual file name for sharing
    final displayName =
        resume.personalInfo.fullName.isNotEmpty
            ? '${resume.personalInfo.fullName} Resume'
            : 'My Resume';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export Successful!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Your resume has been exported as ${format.name.toUpperCase()}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openFile(filePath),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open File'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _getMimeType(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf:
        return 'application/pdf';
      case ExportFormat.text:
        return 'text/plain';
      case ExportFormat.html:
        return 'text/html';
    }
  }

  static Future<void> _openFile(String filePath) async {
    try {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Silent fail - file may not be openable on all platforms
    }
  }

  // ✅ Keep your existing _generateTextResume and _generateHtmlResume as they are
  static String _generateTextResume(Resume resume) {
    final buffer = StringBuffer();
    final personalInfo = resume.personalInfo;

    buffer.writeln('=' * 60);
    buffer.writeln(personalInfo.fullName.toUpperCase());
    buffer.writeln('=' * 60);
    buffer.writeln();

    buffer.writeln('CONTACT INFORMATION');
    buffer.writeln('-' * 30);
    if (personalInfo.email.isNotEmpty)
      buffer.writeln('Email: ${personalInfo.email}');
    if (personalInfo.phone.isNotEmpty)
      buffer.writeln('Phone: ${personalInfo.phone}');
    if (personalInfo.location.isNotEmpty)
      buffer.writeln('Location: ${personalInfo.location}');
    if (personalInfo.linkedin.isNotEmpty)
      buffer.writeln('LinkedIn: ${personalInfo.linkedin}');
    if (personalInfo.portfolio.isNotEmpty)
      buffer.writeln('Portfolio: ${personalInfo.portfolio}');
    buffer.writeln();

    if (personalInfo.professionalSummary.isNotEmpty) {
      buffer.writeln('PROFESSIONAL SUMMARY');
      buffer.writeln('-' * 30);
      buffer.writeln(personalInfo.professionalSummary);
      buffer.writeln();
    }

    if (resume.experience.isNotEmpty) {
      buffer.writeln('PROFESSIONAL EXPERIENCE');
      buffer.writeln('-' * 30);
      for (var exp in resume.experience) {
        buffer.writeln('${exp.position}');
        buffer.writeln('${exp.company} | ${exp.location}');
        buffer.writeln(
          '${_formatDateText(exp.startDate)} - ${exp.current ? 'Present' : _formatDateText(exp.endDate!)}',
        );
        for (var achievement in exp.achievements) {
          buffer.writeln('  • $achievement');
        }
        buffer.writeln();
      }
    }

    if (resume.education.isNotEmpty) {
      buffer.writeln('EDUCATION');
      buffer.writeln('-' * 30);
      for (var edu in resume.education) {
        buffer.writeln('${edu.degree} in ${edu.field}');
        buffer.writeln('${edu.institution} | ${edu.location}');
        buffer.writeln('Graduated: ${_formatDateText(edu.graduationDate)}');
        if (edu.gpa != null && edu.gpa!.isNotEmpty) {
          buffer.writeln('GPA: ${edu.gpa}');
        }
        buffer.writeln();
      }
    }

    if (resume.skills.isNotEmpty) {
      buffer.writeln('SKILLS');
      buffer.writeln('-' * 30);
      final skillGroups = <String, List<String>>{};
      for (var skill in resume.skills) {
        final level = skill.level.toString().split('.').last;
        skillGroups.putIfAbsent(level, () => []).add(skill.name);
      }
      for (var level in skillGroups.keys) {
        buffer.writeln(
          '${level.toUpperCase()}: ${skillGroups[level]!.join(', ')}',
        );
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  static String _generateHtmlResume(Resume resume) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${resume.personalInfo.fullName} - Resume</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #2563eb;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .name {
            font-size: 32px;
            font-weight: bold;
            color: #1e293b;
            margin: 0;
        }
        .title {
            font-size: 18px;
            color: #2563eb;
            margin: 10px 0;
        }
        .contact-info {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            justify-content: center;
            margin-top: 15px;
        }
        .section {
            margin-bottom: 30px;
        }
        .section-title {
            font-size: 20px;
            font-weight: bold;
            color: #1e293b;
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 5px;
            margin-bottom: 15px;
        }
        .experience-item, .education-item {
            margin-bottom: 20px;
        }
        .job-title {
            font-weight: bold;
            color: #1e293b;
        }
        .company {
            color: #2563eb;
        }
        .date {
            color: #6b7280;
            font-style: italic;
        }
        .achievements {
            margin-left: 20px;
        }
        .achievements li {
            margin-bottom: 5px;
        }
        .skills {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .skill-tag {
            background-color: #2563eb;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
        }
        @media print {
            body {
                padding: 0;
            }
            .no-print {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1 class="name">${resume.personalInfo.fullName}</h1>
        <div class="title">${resume.personalInfo.title}</div>
        <div class="contact-info">
            ${resume.personalInfo.email.isNotEmpty ? '<div>📧 ${resume.personalInfo.email}</div>' : ''}
            ${resume.personalInfo.phone.isNotEmpty ? '<div>📱 ${resume.personalInfo.phone}</div>' : ''}
            ${resume.personalInfo.location.isNotEmpty ? '<div>📍 ${resume.personalInfo.location}</div>' : ''}
            ${resume.personalInfo.linkedin.isNotEmpty ? '<div>🔗 ${resume.personalInfo.linkedin}</div>' : ''}
        </div>
    </div>
    
    ${resume.personalInfo.professionalSummary.isNotEmpty ? '''
    <div class="section">
        <h2 class="section-title">Professional Summary</h2>
        <p>${resume.personalInfo.professionalSummary.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</p>
    </div>
    ''' : ''}
    
    ${resume.experience.isNotEmpty ? '''
    <div class="section">
        <h2 class="section-title">Professional Experience</h2>
        ${resume.experience.map((exp) => '''
        <div class="experience-item">
            <div class="job-title">${exp.position.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</div>
            <div class="company">${exp.company.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')} | ${exp.location.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</div>
            <div class="date">${_formatDateHtml(exp.startDate)} - ${exp.current ? 'Present' : _formatDateHtml(exp.endDate!)}</div>
            <ul class="achievements">
                ${exp.achievements.map((a) => '<li>${a.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</li>').join('')}
            </ul>
        </div>
        ''').join('')}
    </div>
    ''' : ''}
    
    ${resume.education.isNotEmpty ? '''
    <div class="section">
        <h2 class="section-title">Education</h2>
        ${resume.education.map((edu) => '''
        <div class="education-item">
            <div class="job-title">${edu.degree.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</div>
            <div class="company">${edu.institution.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')} | ${edu.location.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</div>
            <div class="date">Graduated: ${_formatDateHtml(edu.graduationDate)}</div>
            ${edu.gpa != null && edu.gpa!.isNotEmpty ? '<div>GPA: ${edu.gpa!.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</div>' : ''}
        </div>
        ''').join('')}
    </div>
    ''' : ''}
    
    ${resume.skills.isNotEmpty ? '''
    <div class="section">
        <h2 class="section-title">Skills</h2>
        <div class="skills">
            ${resume.skills.map((skill) => '<span class="skill-tag">${skill.name.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</span>').join('')}
        </div>
    </div>
    ''' : ''}
    
    <div class="no-print" style="margin-top: 50px; padding-top: 20px; border-top: 1px solid #e5e7eb; text-align: center; color: #6b7280; font-size: 12px;">
        <p>Generated by Professional Resume Builder • ${DateTime.now().year}</p>
    </div>
</body>
</html>
    ''';
  }

  static String _formatDateText(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  static String _formatDateHtml(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

enum ExportFormat { pdf, text, html }

// Helper class for consistent button styling
class ElevatedBuilderButtonStyle extends ButtonStyle {
  @override
  MaterialStateProperty<Color?>? get backgroundColor =>
      MaterialStateProperty.all(Colors.blue);
  @override
  MaterialStateProperty<Color?>? get foregroundColor =>
      MaterialStateProperty.all(Colors.white);
}
