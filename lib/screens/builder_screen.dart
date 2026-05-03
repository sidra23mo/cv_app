import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../blocs/resume_bloc.dart';
import '../blocs/resume_event.dart';
import '../blocs/resume_state.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../services/pdf_service.dart';
import '../widgets/personal_info_form.dart';
import '../widgets/experience_form.dart';
import '../widgets/education_form.dart';
import '../widgets/skills_form.dart';
import '../widgets/projects_form.dart';
import '../widgets/certifications_form.dart';
import '../widgets/languages_form.dart';
import '../theme/theme_helper.dart';

class BuilderPage extends StatefulWidget {
  const BuilderPage({super.key});

  @override
  State<BuilderPage> createState() => _BuilderPageState();
}

class _BuilderPageState extends State<BuilderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ResumeBloc, ResumeState>(
      builder: (context, state) {
        if (state.currentResume == null) {
          return Scaffold(
            backgroundColor: ThemeHelper.getBackgroundColor(context),
            appBar: AppBar(
              backgroundColor: ThemeHelper.getCardColor(context),
              elevation: 0,
              title: Text(
                l10n.translate('resume_builder'),
                style: TextStyle(
                  color: ThemeHelper.getTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Center(child: Text(l10n.translate('no_resume_loaded'), style: TextStyle(color: ThemeHelper.getTextColor(context)))),
          );
        }

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
            title: Text(
              l10n.translate('resume_builder'),
              style: TextStyle(
                color: ThemeHelper.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.download_outlined, color: ThemeHelper.getIconColor(context)),
                onPressed: () => _exportPDF(context, state.currentResume!),
                tooltip: l10n.translate('download'),
              ),
              PopupMenuButton<TemplateType>(
                icon: Icon(Icons.palette_outlined, color: ThemeHelper.getIconColor(context)),
                tooltip: l10n.translate('template'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (template) => _showTemplatePreview(context, state.currentResume!, template),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: TemplateType.modern,
                    child: Text(l10n.translate('modern')),
                  ),
                  PopupMenuItem(
                    value: TemplateType.executive,
                    child: Text(l10n.translate('executive')),
                  ),
                  PopupMenuItem(
                    value: TemplateType.creative,
                    child: Text(l10n.translate('creative')),
                  ),
                  PopupMenuItem(
                    value: TemplateType.minimal,
                    child: Text(l10n.translate('minimal')),
                  ),
                  PopupMenuItem(
                    value: TemplateType.tech,
                    child: Text(l10n.translate('tech')),
                  ),
                ],
              ),
            ],
          ),
          body: _buildEditor(),
        );
      },
    );
  }

  Widget _buildEditor() {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ResumeBloc, ResumeState>(
      builder: (context, state) {
        if (state.currentResume == null) return const SizedBox();

        return Column(
          children: [
            Container(
              color: ThemeHelper.getCardColor(context),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: ThemeHelper.getTextColor(context),
                unselectedLabelColor: ThemeHelper.getSecondaryTextColor(context),
                indicatorColor: ThemeHelper.getButtonColor(context),
                indicatorWeight: 2,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: l10n.translate('personal')),
                  Tab(text: l10n.translate('experience')),
                  Tab(text: l10n.translate('education')),
                  Tab(text: l10n.translate('skills')),
                  Tab(text: l10n.translate('projects')),
                  Tab(text: l10n.translate('certifications')),
                  Tab(text: l10n.translate('languages')),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PersonalInfoForm(
                    personalInfo: state.currentResume!.personalInfo,
                    onChanged: (info) => context.read<ResumeBloc>().add(UpdatePersonalInfo(info)),
                  ),
                  ExperienceForm(
                    experiences: state.currentResume!.experience,
                    onAdd: (exp) => context.read<ResumeBloc>().add(AddExperience(exp)),
                    onUpdate: (exp) => context.read<ResumeBloc>().add(UpdateExperience(exp)),
                    onRemove: (id) => context.read<ResumeBloc>().add(RemoveExperience(id)),
                  ),
                  EducationForm(
                    education: state.currentResume!.education,
                    onAdd: (edu) => context.read<ResumeBloc>().add(AddEducation(edu)),
                    onUpdate: (edu) => context.read<ResumeBloc>().add(UpdateEducation(edu)),
                    onRemove: (id) => context.read<ResumeBloc>().add(RemoveEducation(id)),
                  ),
                  SkillsForm(
                    skills: state.currentResume!.skills,
                    onAdd: (skill) => context.read<ResumeBloc>().add(AddSkill(skill)),
                    onUpdate: (skill) => context.read<ResumeBloc>().add(UpdateSkill(skill)),
                    onRemove: (id) => context.read<ResumeBloc>().add(RemoveSkill(id)),
                  ),
                  ProjectsForm(
                    projects: state.currentResume!.projects,
                    onAdd: (proj) => context.read<ResumeBloc>().add(AddProject(proj)),
                    onUpdate: (proj) => context.read<ResumeBloc>().add(UpdateProject(proj)),
                    onRemove: (id) => context.read<ResumeBloc>().add(RemoveProject(id)),
                  ),
                  CertificationsForm(
                    certifications: state.currentResume!.certifications,
                    onAdd: (cert) => context.read<ResumeBloc>().add(AddCertification(cert)),
                    onUpdate: (cert) => context.read<ResumeBloc>().add(UpdateCertification(cert)),
                    onRemove: (id) => context.read<ResumeBloc>().add(RemoveCertification(id)),
                  ),
                  LanguagesForm(
                    languages: state.currentResume!.languages,
                    onAdd: (lang) => context.read<ResumeBloc>().add(AddLanguage(lang)),
                    onUpdate: (lang) => context.read<ResumeBloc>().add(UpdateLanguage(lang)),
                    onRemove: (id) => context.read<ResumeBloc>().add(RemoveLanguage(id)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _exportPDF(BuildContext context, Resume resume) async {
    try {
      await PdfService.generateAndPrintResume(resume);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  void _showTemplatePreview(BuildContext context, Resume resume, TemplateType template) async {
    try {
      final pdfBytes = await PdfService.generatePdfWithTemplate(resume, template);
      if (context.mounted) {
        await Printing.layoutPdf(
          onLayout: (format) => pdfBytes,
          name: '${resume.personalInfo.fullName}_${template.name}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error previewing template: $e')),
        );
      }
    }
  }
}