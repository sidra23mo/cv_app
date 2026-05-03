// lib/data/blocs/resume_event.dart
import 'package:equatable/equatable.dart';
import '../data/models/resume.dart';

abstract class ResumeEvent extends Equatable {
  const ResumeEvent();

  @override
  List<Object> get props => [];
}

class LoadResumes extends ResumeEvent {}

class LoadResume extends ResumeEvent {
  final String id;
  const LoadResume(this.id);

  @override
  List<Object> get props => [id];
}

class CreateResume extends ResumeEvent {
  final TemplateType template;
  const CreateResume(this.template);

  @override
  List<Object> get props => [template];
}

// 🔥 NEW: Event to update template in real-time
class UpdateTemplate extends ResumeEvent {
  final TemplateType template;
  const UpdateTemplate(this.template);

  @override
  List<Object> get props => [template];
}

class UpdateResume extends ResumeEvent {
  final Resume resume;
  const UpdateResume(this.resume);

  @override
  List<Object> get props => [resume];
}

class UpdatePersonalInfo extends ResumeEvent {
  final PersonalInfo personalInfo;
  const UpdatePersonalInfo(this.personalInfo);

  @override
  List<Object> get props => [personalInfo];
}

class AddExperience extends ResumeEvent {
  final Experience experience;
  const AddExperience(this.experience);

  @override
  List<Object> get props => [experience];
}

class UpdateExperience extends ResumeEvent {
  final Experience experience;
  const UpdateExperience(this.experience);

  @override
  List<Object> get props => [experience];
}

class RemoveExperience extends ResumeEvent {
  final String experienceId;
  const RemoveExperience(this.experienceId);

  @override
  List<Object> get props => [experienceId];
}

class AddEducation extends ResumeEvent {
  final Education education;
  const AddEducation(this.education);

  @override
  List<Object> get props => [education];
}

class UpdateEducation extends ResumeEvent {
  final Education education;
  const UpdateEducation(this.education);

  @override
  List<Object> get props => [education];
}

class RemoveEducation extends ResumeEvent {
  final String educationId;
  const RemoveEducation(this.educationId);

  @override
  List<Object> get props => [educationId];
}

class AddSkill extends ResumeEvent {
  final Skill skill;
  const AddSkill(this.skill);

  @override
  List<Object> get props => [skill];
}

class UpdateSkill extends ResumeEvent {
  final Skill skill;
  const UpdateSkill(this.skill);

  @override
  List<Object> get props => [skill];
}

class RemoveSkill extends ResumeEvent {
  final String skillId;
  const RemoveSkill(this.skillId);

  @override
  List<Object> get props => [skillId];
}

class AddProject extends ResumeEvent {
  final Project project;
  const AddProject(this.project);

  @override
  List<Object> get props => [project];
}

class UpdateProject extends ResumeEvent {
  final Project project;
  const UpdateProject(this.project);

  @override
  List<Object> get props => [project];
}

class RemoveProject extends ResumeEvent {
  final String projectId;
  const RemoveProject(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class DeleteResume extends ResumeEvent {
  final String id;
  const DeleteResume(this.id);

  @override
  List<Object> get props => [id];
}

class GenerateAISummary extends ResumeEvent {}

class GenerateAIAchievements extends ResumeEvent {
  final Experience experience;
  const GenerateAIAchievements(this.experience);

  @override
  List<Object> get props => [experience];
}

class AddCertification extends ResumeEvent {
  final Certification certification;
  const AddCertification(this.certification);

  @override
  List<Object> get props => [certification];
}

class UpdateCertification extends ResumeEvent {
  final Certification certification;
  const UpdateCertification(this.certification);

  @override
  List<Object> get props => [certification];
}

class RemoveCertification extends ResumeEvent {
  final String certificationId;
  const RemoveCertification(this.certificationId);

  @override
  List<Object> get props => [certificationId];
}

class AddLanguage extends ResumeEvent {
  final Language language;
  const AddLanguage(this.language);

  @override
  List<Object> get props => [language];
}

class UpdateLanguage extends ResumeEvent {
  final Language language;
  const UpdateLanguage(this.language);

  @override
  List<Object> get props => [language];
}

class RemoveLanguage extends ResumeEvent {
  final String languageId;
  const RemoveLanguage(this.languageId);

  @override
  List<Object> get props => [languageId];
}

// AI Contextual Events
class GenerateAISummaryWithContext extends ResumeEvent {
  final String industry;
  final int yearsOfExperience;
  final List<String> keySkills;

  const GenerateAISummaryWithContext({
    required this.industry,
    required this.yearsOfExperience,
    required this.keySkills,
  });

  @override
  List<Object> get props => [industry, yearsOfExperience, keySkills];
}

class GenerateAIAchievementsWithContext extends ResumeEvent {
  final String experienceId;
  final String industry;
  final List<String> responsibilities;

  const GenerateAIAchievementsWithContext({
    required this.experienceId,
    required this.industry,
    required this.responsibilities,
  });

  @override
  List<Object> get props => [experienceId, industry, responsibilities];
}

class GenerateSkillSuggestions extends ResumeEvent {
  final String industry;
  final String position;

  const GenerateSkillSuggestions({
    required this.industry,
    required this.position,
  });

  @override
  List<Object> get props => [industry, position];
}

class ClearAllResumes extends ResumeEvent {
  const ClearAllResumes();

  @override
  List<Object> get props => [];
}

class UpdateDefaultTemplate extends ResumeEvent {
  final TemplateType template;
  const UpdateDefaultTemplate(this.template);
  @override
  List<Object> get props => [template];
}