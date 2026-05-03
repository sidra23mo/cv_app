// lib/screens/settings_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/resume_bloc.dart';
import '../blocs/resume_event.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/pdf_service.dart';
import '../theme/theme_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _autoSave;
  late bool _aiSuggestions;
  late bool _darkMode;
  late TemplateType _defaultTemplate;
  late int _resumeLimit;

  final List<Map<String, dynamic>> _templates = [
    {'id': TemplateType.modern, 'name': 'modern', 'color': const Color(0xFF2563EB)},
    {'id': TemplateType.executive, 'name': 'executive', 'color': const Color(0xFF1E293B)},
    {'id': TemplateType.creative, 'name': 'creative', 'color': const Color(0xFF7C3AED)},
    {'id': TemplateType.minimal, 'name': 'minimal', 'color': Colors.black},
    {'id': TemplateType.tech, 'name': 'tech', 'color': const Color(0xFF0F172A)},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final currentState = context.read<ResumeBloc>().state;
    final themeProvider = context.read<ThemeProvider>();
    setState(() {
      _autoSave = true;
      _aiSuggestions = true;
      _darkMode = themeProvider.isDarkMode;
      _defaultTemplate = currentState.defaultTemplate;
      _resumeLimit = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = ThemeHelper.isDarkMode(context);
    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.getCardColor(context),
        elevation: 0,
        surfaceTintColor: ThemeHelper.getCardColor(context),
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeHelper.getIconColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.translate('settings'), style: TextStyle(color: ThemeHelper.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
        child: Column(
          children: [
            // General Settings
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeHelper.getBorderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('general_settings'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeHelper.getTextColor(context))),
                  const SizedBox(height: 20),
                  _buildSwitchTile(l10n.translate('auto_save'), l10n.translate('auto_save_desc'), _autoSave, (value) => setState(() => _autoSave = value)),
                  Divider(height: 24, color: ThemeHelper.getBorderColor(context)),
                  _buildSwitchTile(l10n.translate('ai_suggestions'), l10n.translate('ai_suggestions_desc'), _aiSuggestions, (value) => setState(() => _aiSuggestions = value)),
                  Divider(height: 24, color: ThemeHelper.getBorderColor(context)),
                  _buildSwitchTile(l10n.translate('dark_mode'), l10n.translate('dark_mode_desc'), _darkMode, (value) {
                    setState(() => _darkMode = value);
                    context.read<ThemeProvider>().setTheme(value);
                  }),
                  Divider(height: 24, color: ThemeHelper.getBorderColor(context)),
                  _buildLanguageTile(l10n),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Template Settings
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeHelper.getBorderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('template_settings'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeHelper.getTextColor(context))),
                  const SizedBox(height: 8),
                  Text(l10n.translate('default_template'), style: TextStyle(fontSize: 14, color: ThemeHelper.getSecondaryTextColor(context))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _templates.map((template) {
                      final templateType = template['id'] as TemplateType;
                      final isSelected = _defaultTemplate == templateType;
                      return GestureDetector(
                        onTap: () => setState(() => _defaultTemplate = templateType),
                        child: Container(
                          width: 90,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (template['color'] as Color).withOpacity(isSelected ? 0.1 : 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? template['color'] as Color : ThemeHelper.getBorderColor(context),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: template['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.translate(template['name'] as String),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: ThemeHelper.getTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Data Management
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeHelper.getBorderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('data_management'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeHelper.getTextColor(context))),
                  const SizedBox(height: 16),
                  _buildListTile(Icons.save_outlined, l10n.translate('export_all'), l10n.translate('export_all_desc'), Colors.blue, () => _exportAllData(context)),
                  Divider(height: 24, color: ThemeHelper.getBorderColor(context)),
                  _buildListTile(Icons.delete_outline, l10n.translate('clear_all'), l10n.translate('clear_all_desc'), Colors.red, () => _showClearDataDialog(context)),
                  Divider(height: 24, color: ThemeHelper.getBorderColor(context)),
                  _buildListTile(Icons.storage_outlined, l10n.translate('storage_info'), l10n.translate('storage_info_desc'), Colors.green, () => _showStorageInfo(context)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // About & Help
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeHelper.getBorderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('about_help'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeHelper.getTextColor(context))),
                  const SizedBox(height: 16),
                  _buildListTile(Icons.help_outline, l10n.translate('help_tutorials'), l10n.translate('help_tutorials_desc'), Colors.purple, () => _showHelpDialog(context)),
                  Divider(height: 24, color: ThemeHelper.getBorderColor(context)),
                  _buildListTile(Icons.bug_report_outlined, l10n.translate('report_bug'), l10n.translate('report_bug_desc'), Colors.orange, () => _reportBug(context)),
                  Divider(height: 24, color: ThemeHelper.getBorderColor(context)),
                  _buildListTile(Icons.star_outline, l10n.translate('rate_app'), l10n.translate('rate_app_desc'), Colors.amber, () => _rateApp(context)),
                  Divider(height: 24, color: ThemeHelper.getBorderColor(context)),
                  _buildListTile(Icons.code, l10n.translate('version'), '1.0.0 • Professional Resume Builder', Colors.grey, null),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeHelper.getButtonColor(context),
                  foregroundColor: ThemeHelper.getButtonTextColor(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(l10n.translate('save_settings')),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ThemeHelper.getButtonColor(context)),
                  foregroundColor: ThemeHelper.getButtonColor(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(l10n.translate('cancel')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool>? onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ThemeHelper.getTextColor(context))),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 13, color: ThemeHelper.getSecondaryTextColor(context))),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: ThemeHelper.getButtonColor(context),
        ),
      ],
    );
  }

  Widget _buildLanguageTile(AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale.languageCode;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('language'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ThemeHelper.getTextColor(context))),
              const SizedBox(height: 4),
              Text(l10n.translate('choose_language'), style: TextStyle(fontSize: 13, color: ThemeHelper.getSecondaryTextColor(context))),
            ],
          ),
        ),
        DropdownButton<String>(
          value: currentLocale,
          items: [
            DropdownMenuItem(value: 'en', child: Text(l10n.translate('english'))),
            DropdownMenuItem(value: 'ar', child: Text(l10n.translate('arabic'))),
          ],
          onChanged: (value) {
            if (value != null) {
              localeProvider.setLocale(Locale(value));
            }
          },
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ThemeHelper.getTextColor(context))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: ThemeHelper.getSecondaryTextColor(context))),
                ],
              ),
            ),
            if (onTap != null) Icon(Icons.chevron_right, color: ThemeHelper.getSecondaryTextColor(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAllData(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      final resumes = context.read<ResumeBloc>().state.resumes;
      if (resumes.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.translate('no_data_export')), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      final archive = Archive();
      
      for (int i = 0; i < resumes.length; i++) {
        final resume = resumes[i];
        final pdfBytes = await PdfService.generatePdfBytes(resume);
        final fileName = resume.personalInfo.fullName.isNotEmpty 
            ? '${resume.personalInfo.fullName.replaceAll(' ', '_')}_${i + 1}.pdf'
            : 'resume_${i + 1}.pdf';
        archive.addFile(ArchiveFile(fileName, pdfBytes.length, pdfBytes));
      }

      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) {
        throw Exception('Failed to encode ZIP file');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final downloadsPath = '/storage/emulated/0/Download';
      final file = File('$downloadsPath/profiflow_resumes_$timestamp.zip');
      await file.writeAsBytes(zipBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate('export_success')} ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate('export_failed')}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n.translate('clear_all')),
        content: Text(l10n.translate('clear_all_confirm')),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: Text(l10n.translate('cancel'))),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ResumeBloc>().add(const ClearAllResumes());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.translate('all_deleted')), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.translate('delete_all')),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n.translate('storage_info')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('app_size')),
            const SizedBox(height: 8),
            Text(l10n.translate('resume_data')),
            const SizedBox(height: 8),
            Text(l10n.translate('cache')),
            const SizedBox(height: 8),
            Text(l10n.translate('total')),
          ],
        ),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: Text(l10n.translate('clear_cache'))),
          TextButton(onPressed: Navigator.of(context).pop, child: Text(l10n.translate('close'))),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n.translate('help_tutorials')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.translate('getting_started'), style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(l10n.translate('help_step1')),
              Text(l10n.translate('help_step2')),
              Text(l10n.translate('help_step3')),
              Text(l10n.translate('help_step4')),
              const SizedBox(height: 16),
              Text(l10n.translate('tips'), style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(l10n.translate('help_tip1')),
              Text(l10n.translate('help_tip2')),
              Text(l10n.translate('help_tip3')),
              Text(l10n.translate('help_tip4')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: Navigator.of(context).pop, child: Text(l10n.translate('close')))],
      ),
    );
  }

  void _reportBug(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final subject = Uri.encodeComponent('ProfiFlow Bug Report');
    final body = Uri.encodeComponent(
      'Bug Description:\n'
      '\n'
      '\n'
      'Steps to Reproduce:\n'
      '1. \n'
      '2. \n'
      '3. \n'
      '\n'
      'Expected Behavior:\n'
      '\n'
      '\n'
      'Actual Behavior:\n'
      '\n'
      '\n'
      'Device Info:\n'
      'App Version: 1.0.0\n'
      'Platform: Android\n'
    );
    final emailUrl = Uri.parse('mailto:sidra1234m@gmail.com?subject=$subject&body=$body');
    
    try {
      await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('email_not_available')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rateApp(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.translate('coming_soon')), backgroundColor: Colors.amber),
    );
  }

  void _saveSettings() {
    final l10n = AppLocalizations.of(context);
    context.read<ResumeBloc>().add(UpdateDefaultTemplate(_defaultTemplate));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.translate('template_updated')),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }
}
