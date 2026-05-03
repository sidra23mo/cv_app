import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/resume_bloc.dart';
import '../blocs/resume_event.dart';
import '../blocs/resume_state.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/pdf_service.dart';
import '../theme/theme_helper.dart';
import '../utils/sample_resume_data.dart';
import 'dashboard_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ThemeHelper.getCardColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.getCardColor(context),
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: ThemeHelper.getIconColor(context),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: Text(
          l10n.translate('app_name'),
          style: TextStyle(
            color: ThemeHelper.getTextColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                ),
            icon: Icon(
              Icons.dashboard,
              color: ThemeHelper.getIconColor(context),
            ),
          ),
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            icon: Icon(Icons.logout, color: ThemeHelper.getIconColor(context)),
          ),
        ],
      ),
      drawer: _buildAppDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            const SizedBox(height: 80),
            _buildFeatures(),
            const SizedBox(height: 80),
            _buildTemplates(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          Text(
            l10n.translate('build_resume'),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: ThemeHelper.getTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.translate('ai_powered_desc'),
            style: TextStyle(
              fontSize: 20,
              color: ThemeHelper.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              BlocBuilder<ResumeBloc, ResumeState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed:
                        state.isSaving
                            ? null
                            : () {
                              context.read<ResumeBloc>().add(
                                CreateResume(
                                  context
                                      .read<ResumeBloc>()
                                      .state
                                      .defaultTemplate,
                                ),
                              );
                              context.read<ResumeBloc>().stream.first.then(
                                (_) =>
                                    Navigator.of(context).pushNamed('/builder'),
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeHelper.getButtonColor(context),
                      foregroundColor: ThemeHelper.getButtonTextColor(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child:
                        state.isSaving
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ThemeHelper.getButtonTextColor(context),
                              ),
                            )
                            : Text(
                              l10n.translate('create_resume'),
                              style: TextStyle(
                                fontSize: 18,
                                color: ThemeHelper.getButtonTextColor(context),
                              ),
                            ),
                  );
                },
              ),
              OutlinedButton.icon(
                onPressed:
                    () => Navigator.of(context).pushNamed('/ai-cv-builder'),
                icon: const Icon(Icons.auto_awesome),
                label: Text(l10n.translate('ai_cv_builder')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeHelper.getButtonColor(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: BorderSide(
                    color: ThemeHelper.getButtonColor(context),
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final features = [
          {
            'icon': Icons.auto_awesome,
            'title_key': 'ai_powered',
            'desc_key': 'smart_content',
          },
          {
            'icon': Icons.palette,
            'title_key': 'beautiful_templates',
            'desc_key': 'professional_designs',
          },
          {
            'icon': Icons.download,
            'title_key': 'export_pdf',
            'desc_key': 'download_instantly',
          },
          {
            'icon': Icons.speed,
            'title_key': 'fast_easy',
            'desc_key': 'build_minutes',
          },
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children:
                    features
                        .map(
                          (f) => SizedBox(
                            width:
                                constraints.maxWidth > 600
                                    ? (constraints.maxWidth - 72) / 4
                                    : (constraints.maxWidth - 24) / 2,
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: ThemeHelper.getInputFillColor(
                                      context,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    f['icon'] as IconData,
                                    size: 36,
                                    color: ThemeHelper.getIconColor(context),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.translate(f['title_key'] as String),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeHelper.getTextColor(context),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.translate(f['desc_key'] as String),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ThemeHelper.getSecondaryTextColor(
                                      context,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTemplates(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final templates = [
      {
        'type': TemplateType.modern,
        'name_key': 'modern',
        'image': 'assets/templates/modern.jpg',
      },
      {
        'type': TemplateType.executive,
        'name_key': 'executive',
        'image': 'assets/templates/executive.jpg',
      },
      {
        'type': TemplateType.creative,
        'name_key': 'creative',
        'image': 'assets/templates/creative.jpg',
      },
      {
        'type': TemplateType.minimal,
        'name_key': 'minimal',
        'image': 'assets/templates/minmal.jpg',
      },
      {
        'type': TemplateType.tech,
        'name_key': 'tech',
        'image': 'assets/templates/tech.jpg',
      },
    ];

    return Column(
      children: [
        Text(
          l10n.translate('choose_template'),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: ThemeHelper.getTextColor(context),
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  constraints.maxWidth > 900
                      ? 5
                      : constraints.maxWidth > 600
                      ? 3
                      : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final t = templates[index];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final bloc = context.read<ResumeBloc>();
                          bloc.add(
                            UpdateDefaultTemplate(t['type'] as TemplateType),
                          );
                          bloc.add(CreateResume(t['type'] as TemplateType));
                          bloc.stream.first.then(
                            (_) => Navigator.of(context).pushNamed('/builder'),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: ThemeHelper.getCardColor(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ThemeHelper.getSecondaryTextColor(
                                context,
                              ).withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.asset(
                                    t['image'] as String,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Container(
                                          color: ThemeHelper.getInputFillColor(
                                            context,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.description,
                                                size: 48,
                                                color: ThemeHelper.getIconColor(
                                                  context,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                l10n.translate(
                                                  t['name_key'] as String,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      ThemeHelper.getTextColor(
                                                        context,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ThemeHelper.getInputFillColor(context),
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      l10n.translate(t['name_key'] as String),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeHelper.getTextColor(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(Icons.visibility, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.6),
                          ),
                          onPressed: () async {
                            final resume = SampleResumeData.getSampleResume();
                            final pdfBytes =
                                await PdfService.generatePdfWithTemplate(
                                  resume,
                                  t['type'] as TemplateType,
                                );
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder:
                                    (ctx) => Dialog(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 300,
                                          maxHeight: 420,
                                        ),
                                        child: PdfPreview(
                                          build: (format) => pdfBytes,
                                          allowSharing: false,
                                          allowPrinting: false,
                                          canChangePageFormat: false,
                                          canChangeOrientation: false,
                                          canDebug: false,
                                        ),
                                      ),
                                    ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Drawer(
      backgroundColor: ThemeHelper.getCardColor(context),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
            decoration: BoxDecoration(
              color: ThemeHelper.getButtonColor(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: ThemeHelper.getButtonTextColor(context),
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: ThemeHelper.getButtonColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('app_name'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.translate('app_subtitle'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            context,
            Icons.home_outlined,
            l10n.translate('home'),
            Navigator.of(context).pop,
            selected: true,
          ),
          _buildDrawerItem(
            context,
            Icons.auto_awesome,
            l10n.translate('ai_cv_builder'),
            () => Navigator.of(context).pushNamed('/ai-cv-builder'),
          ),
          _buildDrawerItem(
            context,
            Icons.dashboard_outlined,
            l10n.translate('dashboard'),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.analytics_outlined,
            l10n.translate('resume_analysis'),
            () => _showAnalysisSelection(context),
          ),
          const Divider(height: 32),
          _buildDrawerItem(
            context,
            Icons.settings_outlined,
            l10n.translate('settings'),
            () => Navigator.of(context).pushNamed('/settings'),
          ),
          _buildDrawerItem(
            context,
            Icons.help_outline,
            l10n.translate('help_support'),
            () => _showHelpDialog(context),
          ),
          _buildDrawerItem(
            context,
            Icons.share_outlined,
            l10n.translate('share_app'),
            () {},
          ),
          _buildDrawerItem(
            context,
            Icons.star_outline,
            l10n.translate('rate_app'),
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool selected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color:
            selected ? ThemeHelper.getButtonColor(context) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              selected
                  ? ThemeHelper.getButtonTextColor(context)
                  : ThemeHelper.getIconColor(context),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                selected
                    ? ThemeHelper.getButtonTextColor(context)
                    : ThemeHelper.getTextColor(context),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showAnalysisSelection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resumes = context.read<ResumeBloc>().state.resumes;
    if (resumes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('no_resumes_analyze')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeHelper.getCardColor(context),
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
                l10n.translate('select_resume_analyze'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.getTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: resumes.length,
                  itemBuilder: (context, index) {
                    final resume = resumes[index];
                    return ListTile(
                      leading: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getTemplateColor(resume.template),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        resume.personalInfo.fullName.isNotEmpty
                            ? resume.personalInfo.fullName
                            : l10n.translate('untitled_resume'),
                        style: TextStyle(
                          color: ThemeHelper.getTextColor(context),
                        ),
                      ),
                      subtitle: Text(
                        resume.personalInfo.title,
                        style: TextStyle(
                          color: ThemeHelper.getSecondaryTextColor(context),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: ThemeHelper.getIconColor(context),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(
                          context,
                        ).pushNamed('/analysis', arguments: resume);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getTemplateColor(TemplateType type) {
    switch (type) {
      case TemplateType.modern:
        return const Color(0xFF2563EB);
      case TemplateType.executive:
        return const Color(0xFF1E293B);
      case TemplateType.creative:
        return const Color(0xFF7C3AED);
      case TemplateType.minimal:
        return Colors.black;
      case TemplateType.tech:
        return const Color(0xFF0F172A);
    }
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(l10n.translate('help_tutorials')),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.translate('getting_started'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(l10n.translate('help_step1')),
                  Text(l10n.translate('help_step2')),
                  Text(l10n.translate('help_step3')),
                  Text(l10n.translate('help_step4')),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('tips'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(l10n.translate('help_tip1')),
                  Text(l10n.translate('help_tip2')),
                  Text(l10n.translate('help_tip3')),
                  Text(l10n.translate('help_tip4')),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(l10n.translate('close')),
              ),
              ElevatedButton(
                onPressed: () => _sendSupportEmail(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeHelper.getButtonColor(context),
                  foregroundColor: ThemeHelper.getButtonTextColor(context),
                ),
                child: Text(l10n.translate('contact_support')),
              ),
            ],
          ),
    );
  }

  void _sendSupportEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final subject = Uri.encodeComponent('ProfiFlow Support Request');
    final body = Uri.encodeComponent(
      'Hello ProfiFlow Support,\n'
      '\n'
      'I need help with:\n'
      '\n'
      '\n'
      'Please provide details about your issue or question.\n'
      '\n'
      'Thank you!',
    );
    final emailUrl = Uri.parse(
      'mailto:sidra1234m@gmail.com?subject=$subject&body=$body',
    );

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
}
