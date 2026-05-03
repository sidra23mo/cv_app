import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme_helper.dart';

class ResumeCard extends StatelessWidget {
  final Resume resume;
  final VoidCallback onEdit;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const ResumeCard({
    super.key,
    required this.resume,
    required this.onEdit,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Preview Section
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: ThemeHelper.getInputFillColor(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 75,
                decoration: BoxDecoration(
                  color: ThemeHelper.getCardColor(context),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: ThemeHelper.getBorderColor(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 3,
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getTemplateColor(context, resume.template),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getBorderColor(context),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getBorderColor(context),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resume.personalInfo.fullName.isNotEmpty
                        ? resume.personalInfo.fullName
                        : l10n.translate('untitled_resume'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.getTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    resume.personalInfo.title.isNotEmpty
                        ? resume.personalInfo.title
                        : l10n.translate('no_title_set'),
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeHelper.getSecondaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getTemplateColor(context, resume.template).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getTemplateName(context, resume.template),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getTemplateColor(context, resume.template),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 11, color: ThemeHelper.getSecondaryTextColor(context)),
                      const SizedBox(width: 3),
                      Text(
                        DateFormat('MMM d, yyyy').format(resume.updatedAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: ThemeHelper.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: ThemeHelper.getBorderColor(context))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(context, Icons.edit_outlined, l10n.translate('edit'), onEdit, ThemeHelper.getButtonColor(context)),
                _buildActionButton(context, Icons.download_outlined, l10n.translate('download'), onDownload, ThemeHelper.getIconColor(context)),
                _buildActionButton(context, Icons.delete_outline, l10n.translate('delete'), onDelete, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemplateColor(BuildContext context, TemplateType type) {
    final isDark = ThemeHelper.isDarkMode(context);
    switch (type) {
      case TemplateType.modern:
        return const Color(0xFF2563EB);
      case TemplateType.executive:
        return isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E293B);
      case TemplateType.creative:
        return const Color(0xFF7C3AED);
      case TemplateType.minimal:
        return isDark ? Colors.white : Colors.black;
      case TemplateType.tech:
        return isDark ? const Color(0xFF64748B) : const Color(0xFF0F172A);
    }
  }

  String _getTemplateName(BuildContext context, TemplateType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case TemplateType.modern:
        return l10n.translate('modern');
      case TemplateType.executive:
        return l10n.translate('executive');
      case TemplateType.creative:
        return l10n.translate('creative');
      case TemplateType.minimal:
        return l10n.translate('minimal');
      case TemplateType.tech:
        return l10n.translate('tech');
    }
  }
}