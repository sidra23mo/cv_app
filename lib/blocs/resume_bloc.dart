// lib/data/blocs/resume_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import '../data/database/database_helper.dart';
import '../data/models/resume.dart';
import '../services/ai_service.dart';
import 'resume_event.dart';
import 'resume_state.dart';


class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  ResumeBloc() : super(const ResumeState()) {
    on<LoadResumes>(_onLoadResumes);
    on<UpdateDefaultTemplate>(_onUpdateDefaultTemplate);
    on<LoadResume>(_onLoadResume);
    on<CreateResume>(_onCreateResume);
    on<UpdateResume>(_onUpdateResume);
    on<ClearAllResumes>(_onClearAllResumes);
    on<UpdatePersonalInfo>(_onUpdatePersonalInfo);
    on<AddExperience>(_onAddExperience);
    on<UpdateExperience>(_onUpdateExperience);
    on<RemoveExperience>(_onRemoveExperience);
    on<AddEducation>(_onAddEducation);
    on<UpdateEducation>(_onUpdateEducation);
    on<RemoveEducation>(_onRemoveEducation);
    on<AddSkill>(_onAddSkill);
    on<UpdateSkill>(_onUpdateSkill);
    on<RemoveSkill>(_onRemoveSkill);
    on<AddProject>(_onAddProject);
    on<UpdateProject>(_onUpdateProject);
    on<RemoveProject>(_onRemoveProject);
    on<DeleteResume>(_onDeleteResume);
    on<GenerateAISummary>(_onGenerateAISummary); // Keep for backward compat, but DEPRECATE
    on<GenerateAIAchievements>(_onGenerateAIAchievements); // Keep but DEPRECATE
    on<AddCertification>(_onAddCertification);
    on<UpdateCertification>(_onUpdateCertification);
    on<RemoveCertification>(_onRemoveCertification);
    on<AddLanguage>(_onAddLanguage);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<RemoveLanguage>(_onRemoveLanguage);
    on<GenerateAISummaryWithContext>(_onGenerateAISummaryWithContext);
    on<GenerateAIAchievementsWithContext>(_onGenerateAIAchievementsWithContext);
    on<GenerateSkillSuggestions>(_onGenerateSkillSuggestions);
    on<UpdateTemplate>(_onUpdateTemplate); // 🔥 NEW: Handle template changes
  }

  // 🔥 NEW: Handle template updates with real-time emission
  Future<void> _onUpdateTemplate(
      UpdateTemplate event,
      Emitter<ResumeState> emit,
      ) async {
    if (state.currentResume == null) return;

    // Emit immediately for real-time preview
    final updatedResume = state.currentResume!.copyWith(
      template: event.template,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(currentResume: updatedResume));

    // Save to DB in background
    unawaited(_databaseHelper.updateResume(updatedResume));
  }
  Future<void> _onUpdateDefaultTemplate(
      UpdateDefaultTemplate event,
      Emitter<ResumeState> emit,
      ) async {
    emit(state.copyWith(defaultTemplate: event.template));
  }
  // ✅ FIXED: Real-time update + background save
  Future<void> _onUpdatePersonalInfo(
      UpdatePersonalInfo event,
      Emitter<ResumeState> emit,
      ) async {
    if (state.currentResume == null) return;

    final updatedResume = state.currentResume!.copyWith(
      personalInfo: event.personalInfo,
      updatedAt: DateTime.now(),
    );

    // 🔥 EMIT IMMEDIATELY for real-time preview
    emit(state.copyWith(currentResume: updatedResume));

    // Save in background
    unawaited(_databaseHelper.updateResume(updatedResume));
  }

  // ✅ Apply same fix to ALL update handlers
  Future<void> _updateResumeOptimistic(Resume updatedResume, Emitter<ResumeState> emit) async {
    emit(state.copyWith(currentResume: updatedResume));
    unawaited(_databaseHelper.updateResume(updatedResume));
  }

  Future<void> _onAddExperience(AddExperience event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final experiences = List<Experience>.from(state.currentResume!.experience)
      ..add(event.experience.copyWith(id: _uuid.v4()));
    final updatedResume = state.currentResume!.copyWith(
      experience: experiences,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onUpdateExperience(UpdateExperience event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final experiences = state.currentResume!.experience.map((exp) {
      return exp.id == event.experience.id ? event.experience : exp;
    }).toList();
    final updatedResume = state.currentResume!.copyWith(
      experience: experiences,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onRemoveExperience(RemoveExperience event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final experiences = state.currentResume!.experience
        .where((exp) => exp.id != event.experienceId)
        .toList();
    final updatedResume = state.currentResume!.copyWith(
      experience: experiences,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  // Repeat same pattern for Education, Skills, Projects, etc.
  // For brevity, I'll show one more and assume others follow

  Future<void> _onAddEducation(AddEducation event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final education = List<Education>.from(state.currentResume!.education)
      ..add(event.education.copyWith(id: _uuid.v4()));
    final updatedResume = state.currentResume!.copyWith(
      education: education,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onUpdateEducation(UpdateEducation event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final education = state.currentResume!.education.map((edu) {
      return edu.id == event.education.id ? event.education : edu;
    }).toList();
    final updatedResume = state.currentResume!.copyWith(
      education: education,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onRemoveEducation(RemoveEducation event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final education = state.currentResume!.education
        .where((edu) => edu.id != event.educationId)
        .toList();
    final updatedResume = state.currentResume!.copyWith(
      education: education,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  // Skills
  Future<void> _onAddSkill(AddSkill event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final skills = List<Skill>.from(state.currentResume!.skills)
      ..add(event.skill.copyWith(id: _uuid.v4()));
    final updatedResume = state.currentResume!.copyWith(
      skills: skills,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onUpdateSkill(UpdateSkill event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final skills = state.currentResume!.skills.map((skill) {
      return skill.id == event.skill.id ? event.skill : skill;
    }).toList();
    final updatedResume = state.currentResume!.copyWith(
      skills: skills,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onRemoveSkill(RemoveSkill event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final skills = state.currentResume!.skills
        .where((skill) => skill.id != event.skillId)
        .toList();
    final updatedResume = state.currentResume!.copyWith(
      skills: skills,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  // Projects
  Future<void> _onAddProject(AddProject event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final projects = List<Project>.from(state.currentResume!.projects)
      ..add(event.project.copyWith(id: _uuid.v4()));
    final updatedResume = state.currentResume!.copyWith(
      projects: projects,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onUpdateProject(UpdateProject event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final projects = state.currentResume!.projects.map((project) {
      return project.id == event.project.id ? event.project : project;
    }).toList();
    final updatedResume = state.currentResume!.copyWith(
      projects: projects,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onRemoveProject(RemoveProject event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final projects = state.currentResume!.projects
        .where((project) => project.id != event.projectId)
        .toList();
    final updatedResume = state.currentResume!.copyWith(
      projects: projects,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  // Certifications
  Future<void> _onAddCertification(AddCertification event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final certifications = List<Certification>.from(state.currentResume!.certifications)
      ..add(event.certification.copyWith(id: _uuid.v4()));
    final updatedResume = state.currentResume!.copyWith(
      certifications: certifications,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onUpdateCertification(UpdateCertification event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final certifications = state.currentResume!.certifications.map((cert) {
      return cert.id == event.certification.id ? event.certification : cert;
    }).toList();
    final updatedResume = state.currentResume!.copyWith(
      certifications: certifications,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onRemoveCertification(RemoveCertification event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final certifications = state.currentResume!.certifications
        .where((cert) => cert.id != event.certificationId)
        .toList();
    final updatedResume = state.currentResume!.copyWith(
      certifications: certifications,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  // Languages
  Future<void> _onAddLanguage(AddLanguage event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final languages = List<Language>.from(state.currentResume!.languages)
      ..add(event.language.copyWith(id: _uuid.v4()));
    final updatedResume = state.currentResume!.copyWith(
      languages: languages,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onUpdateLanguage(UpdateLanguage event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final languages = state.currentResume!.languages.map((lang) {
      return lang.id == event.language.id ? event.language : lang;
    }).toList();
    final updatedResume = state.currentResume!.copyWith(
      languages: languages,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  Future<void> _onRemoveLanguage(RemoveLanguage event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;
    final languages = state.currentResume!.languages
        .where((lang) => lang.id != event.languageId)
        .toList();
    final updatedResume = state.currentResume!.copyWith(
      languages: languages,
      updatedAt: DateTime.now(),
    );
    _updateResumeOptimistic(updatedResume, emit);
  }

  // ✅ IMPROVED: Use contextual AI even in basic events (fallback)
  Future<void> _onGenerateAISummary(GenerateAISummary event, Emitter<ResumeState> emit) async {
    if (state.currentResume == null) return;

    final personalInfo = state.currentResume!.personalInfo;
    if (personalInfo.title.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter your professional title first'));
      return;
    }

    // 🔥 Use the new basic summary method
    final summary = await AIService.generateBasicProfessionalSummary(
      fullName: personalInfo.fullName,
      title: personalInfo.title,
    );

    final updatedPersonalInfo = personalInfo.copyWith(professionalSummary: summary);
    add(UpdatePersonalInfo(updatedPersonalInfo));
  }

  Future<void> _onGenerateAIAchievements(
      GenerateAIAchievements event,
      Emitter<ResumeState> emit,
      ) async {
    try {
      final achievements = await AIService.generateAchievements(
        position: event.experience.position,
        company: event.experience.company,
        industry: '',
        responsibilities: [],
      );

      final updatedExperience = event.experience.copyWith(
        achievements: achievements,
      );
      add(UpdateExperience(updatedExperience));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'AI generation failed'));
      rethrow;
    }
  }

  // Keep other handlers (Load, Create, Delete, etc.) as they are — they're correct
  Future<void> _onLoadResumes(LoadResumes event, Emitter<ResumeState> emit) async {
    emit(state.copyWith(status: ResumeStatus.loading));
    try {
      final resumes = await _databaseHelper.getAllResumes();
      emit(state.copyWith(status: ResumeStatus.success, resumes: resumes));
    } catch (e) {
      emit(state.copyWith(
        status: ResumeStatus.failure,
        errorMessage: 'Failed to load resumes: $e',
      ));
    }
  }

  Future<void> _onLoadResume(LoadResume event, Emitter<ResumeState> emit) async {
    emit(state.copyWith(status: ResumeStatus.loading));
    try {
      final resume = await _databaseHelper.getResume(event.id);
      if (resume != null) {
        emit(state.copyWith(status: ResumeStatus.success, currentResume: resume));
      } else {
        emit(state.copyWith(
          status: ResumeStatus.failure,
          errorMessage: 'Resume not found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ResumeStatus.failure,
        errorMessage: 'Failed to load resume: $e',
      ));
    }
  }

  Future<void> _onCreateResume(CreateResume event, Emitter<ResumeState> emit) async {
    emit(state.copyWith(isSaving: true));
    try {
      final now = DateTime.now();
      final newResume = Resume(
        id: _uuid.v4(),
        template: event.template,
        personalInfo: PersonalInfo.empty(),
        experience: [],
        education: [],
        skills: [],
        projects: [],
        certifications: [],
        languages: [],
        createdAt: now,
        updatedAt: now,
      );
      await _databaseHelper.insertResume(newResume);
      emit(state.copyWith(currentResume: newResume, isSaving: false));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to create resume: $e',
        isSaving: false,
      ));
    }
  }

  Future<void> _onUpdateResume(UpdateResume event, Emitter<ResumeState> emit) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _databaseHelper.updateResume(event.resume);
      final updatedResumes = await _databaseHelper.getAllResumes();
      emit(state.copyWith(
        resumes: updatedResumes,
        currentResume: event.resume,
        isSaving: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update resume: $e',
        isSaving: false,
      ));
    }
  }

  Future<void> _onDeleteResume(DeleteResume event, Emitter<ResumeState> emit) async {
    try {
      await _databaseHelper.deleteResume(event.id);
      final resumes = state.resumes.where((r) => r.id != event.id).toList();
      emit(state.copyWith(
        resumes: resumes,
        currentResume: state.currentResume?.id == event.id ? null : state.currentResume,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete resume: $e'));
    }
  }

  Future<void> _onClearAllResumes(ClearAllResumes event, Emitter<ResumeState> emit) async {
    try {
      await _databaseHelper.deleteAllResumes();
      emit(state.copyWith(resumes: [], currentResume: null));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to clear resumes: $e'));
    }
  }

  // Contextual AI handlers — already correct
  Future<void> _onGenerateAISummaryWithContext(
      GenerateAISummaryWithContext event,
      Emitter<ResumeState> emit,
      ) async {
    if (state.currentResume == null) return;

    final personalInfo = state.currentResume!.personalInfo;
    final summary = await AIService.generateProfessionalSummary(
      fullName: personalInfo.fullName,
      title: personalInfo.title,
      industry: event.industry,
      keySkills: event.keySkills,
      yearsOfExperience: event.yearsOfExperience,
    );

    final updatedPersonalInfo = personalInfo.copyWith(professionalSummary: summary);
    add(UpdatePersonalInfo(updatedPersonalInfo));
  }

  Future<void> _onGenerateAIAchievementsWithContext(
      GenerateAIAchievementsWithContext event,
      Emitter<ResumeState> emit,
      ) async {
    if (state.currentResume == null) return;

    final experience = state.currentResume!.experience
        .firstWhere((exp) => exp.id == event.experienceId, orElse: () => throw Exception('Experience not found'));

    final achievements = await AIService.generateAchievements(
      position: experience.position,
      company: experience.company,
      industry: event.industry,
      responsibilities: event.responsibilities,
    );

    final updatedExperience = experience.copyWith(achievements: achievements);
    add(UpdateExperience(updatedExperience));
  }

  Future<void> _onGenerateSkillSuggestions(
      GenerateSkillSuggestions event,
      Emitter<ResumeState> emit,
      ) async {
    if (state.currentResume == null) return;

    final existingSkills = state.currentResume!.skills.map((s) => s.name).toList();
    final suggestions = await AIService.generateSkillSuggestions(
      industry: event.industry,
      position: event.position,
      existingSkills: existingSkills,
    );
    emit(state.copyWith(skillSuggestions: suggestions));
  }
}