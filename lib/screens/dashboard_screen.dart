import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/resume_bloc.dart';
import '../blocs/resume_event.dart';
import '../blocs/resume_state.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../services/pdf_service.dart';
import '../widgets/resume_card.dart';
import '../theme/theme_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ResumeBloc>().add(LoadResumes());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: ThemeHelper.getCardColor(context),
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.translate('dashboard_title'), style: TextStyle(color: ThemeHelper.getTextColor(context), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(l10n.translate('manage_resumes'), style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context), fontSize: 13, fontWeight: FontWeight.normal)),
            ],
          ),
          actions: [],
        ),
      ),
      body: BlocBuilder<ResumeBloc, ResumeState>(
        builder: (context, state) {
          if (state.status == ResumeStatus.loading) {
            return Center(child: CircularProgressIndicator(color: ThemeHelper.getButtonColor(context)));
          }

          if (state.status == ResumeStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.translate('failed_load'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(state.errorMessage, textAlign: TextAlign.center, style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context))),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<ResumeBloc>().add(LoadResumes()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeHelper.getButtonColor(context),
                        foregroundColor: ThemeHelper.getButtonTextColor(context),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(l10n.translate('try_again')),
                    ),
                  ],
                ),
              ),
            );
          }

          final resumes = state.resumes;
          if (resumes.isEmpty) return _buildEmptyState(context);
          return _buildResumeContent(context, resumes);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: ThemeHelper.getButtonColor(context),
        foregroundColor: ThemeHelper.getButtonTextColor(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.translate('create_new')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ThemeHelper.getInputFillColor(context),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.description_outlined, size: 64, color: ThemeHelper.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 32),
            Text(l10n.translate('no_resumes'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ThemeHelper.getTextColor(context))),
            const SizedBox(height: 12),
            Text(l10n.translate('create_first'), textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: ThemeHelper.getSecondaryTextColor(context))),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.getButtonColor(context),
                foregroundColor: ThemeHelper.getButtonTextColor(context),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(l10n.translate('create_first_resume')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeContent(BuildContext context, List<Resume> resumes) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(resumes),
          const SizedBox(height: 32),
          Text(l10n.translate('your_resumes'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeHelper.getTextColor(context))),
          const SizedBox(height: 16),
          _buildResumeGrid(context, resumes),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<Resume> resumes) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final isWide = MediaQuery.of(context).size.width > 600;
        final isDark = ThemeHelper.isDarkMode(context);
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(l10n.translate('total_resumes'), resumes.length.toString(), Icons.description_outlined, isDark ? Colors.white : Colors.black, isWide),
            _buildStatCard(l10n.translate('templates_used'), resumes.map((r) => r.template).toSet().length.toString(), Icons.palette_outlined, isDark ? Colors.grey[300]! : Colors.grey[800]!, isWide),
            _buildStatCard(l10n.translate('last_updated'), resumes.isNotEmpty ? DateFormat('MMM dd').format(resumes.first.updatedAt) : '-', Icons.update, isDark ? Colors.grey[400]! : Colors.grey[700]!, isWide),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isWide) {
    return Container(
      width: isWide ? null : double.infinity,
      constraints: isWide ? const BoxConstraints(minWidth: 180) : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: isWide ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ThemeHelper.getTextColor(context))),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 13, color: ThemeHelper.getSecondaryTextColor(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeGrid(BuildContext context, List<Resume> resumes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        double childAspectRatio = 1.2;
        
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          childAspectRatio = 1.2;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
          childAspectRatio = 1.2;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: resumes.length,
          itemBuilder: (context, index) {
            final resume = resumes[index];
            return ResumeCard(
              resume: resume,
              onEdit: () => _navigateToBuilder(context, resume),
              onDownload: () => _downloadResume(context, resume),
              onDelete: () => _showDeleteDialog(context, resume),
            );
          },
        );
      },
    );
  }

  void _navigateToBuilder(BuildContext context, Resume resume) {
    context.read<ResumeBloc>().add(LoadResume(resume.id));
    Navigator.of(context).pushNamed('/builder');
  }

  // ✅ PDF export is OK here (uses saved resume)
  void _downloadResume(BuildContext context, Resume resume) async {
    final l10n = AppLocalizations.of(context);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 12),
              Text(l10n.translate('generating_pdf')),
            ],
          ),
        ),
      );

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: FutureBuilder(
              future: () async {
                await PdfService.generateAndPrintResume(resume);
                return true;
              }(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pop(true);
                  });
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('pdf_success')), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.translate('pdf_failed')}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, Resume resume) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeHelper.getCardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n.translate('delete_resume'), style: TextStyle(fontWeight: FontWeight.bold, color: ThemeHelper.getTextColor(context))),
        content: Text('${l10n.translate('delete_confirm')} "${resume.personalInfo.fullName}" ${l10n.translate('delete_confirm_end')}', style: TextStyle(color: ThemeHelper.getTextColor(context))),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            style: TextButton.styleFrom(foregroundColor: ThemeHelper.getSecondaryTextColor(context)),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ResumeBloc>().add(DeleteResume(resume.id));
              Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.translate('resume_deleted')),
                    backgroundColor: ThemeHelper.getButtonColor(context),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );
  }
}

Color _getTemplateColor(TemplateType type) {
  switch (type) {
    case TemplateType.modern: return const Color(0xFF2563EB);
    case TemplateType.executive: return const Color(0xFF1E293B);
    case TemplateType.creative: return const Color(0xFF7C3AED);
    case TemplateType.minimal: return Colors.black;
    case TemplateType.tech: return const Color(0xFF0F172A);
  }
}

String _getTemplateName(TemplateType type) {
  switch (type) {
    case TemplateType.modern: return 'Modern';
    case TemplateType.executive: return 'Executive';
    case TemplateType.creative: return 'Creative';
    case TemplateType.minimal: return 'Minimal';
    case TemplateType.tech: return 'Tech';
  }
}