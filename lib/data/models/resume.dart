// lib/data/models/resume.dart
import 'package:equatable/equatable.dart';

enum TemplateType {
  modern,
  executive,
  creative,
  minimal,
  tech,
}

enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

enum LanguageProficiency {
  basic,
  conversational,
  fluent,
  native,
}

class PersonalInfo extends Equatable {
  final String? id;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String linkedin;
  final String portfolio;
  final String title;
  final String professionalSummary;

  const PersonalInfo({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.linkedin,
    required this.portfolio,
    required this.title,
    required this.professionalSummary,
  });

  PersonalInfo copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? linkedin,
    String? portfolio,
    String? title,
    String? professionalSummary,
  }) {
    return PersonalInfo(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      linkedin: linkedin ?? this.linkedin,
      portfolio: portfolio ?? this.portfolio,
      title: title ?? this.title,
      professionalSummary: professionalSummary ?? this.professionalSummary,
    );
  }

  factory PersonalInfo.empty() {
    return PersonalInfo(
      fullName: '',
      email: '',
      phone: '',
      location: '',
      linkedin: '',
      portfolio: '',
      title: '',
      professionalSummary: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedin': linkedin,
      'portfolio': portfolio,
      'title': title,
      'professionalSummary': professionalSummary,
    };
  }

  factory PersonalInfo.fromMap(Map<String, dynamic> map) {
    return PersonalInfo(
      id: map['id'],
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      linkedin: map['linkedin'] ?? '',
      portfolio: map['portfolio'] ?? '',
      title: map['title'] ?? '',
      professionalSummary: map['professionalSummary'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    location,
    linkedin,
    portfolio,
    title,
    professionalSummary,
  ];
}

class Experience extends Equatable {
  final String? id;
  final String company;
  final String position;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool current;
  final List<String> achievements;

  const Experience({
    this.id,
    required this.company,
    required this.position,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.current,
    required this.achievements,
  });

  Experience copyWith({
    String? id,
    String? company,
    String? position,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? current,
    List<String>? achievements,
  }) {
    return Experience(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      current: current ?? this.current,
      achievements: achievements ?? this.achievements,
    );
  }

  factory Experience.empty() {
    return Experience(
      company: '',
      position: '',
      location: '',
      startDate: DateTime.now(),
      current: false,
      achievements: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'current': current,
      'achievements': achievements,
    };
  }

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      id: map['id'],
      company: map['company'] ?? '',
      position: map['position'] ?? '',
      location: map['location'] ?? '',
      startDate: DateTime.parse(map['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      current: map['current'] ?? false,
      achievements: List<String>.from(map['achievements'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
    id,
    company,
    position,
    location,
    startDate,
    endDate,
    current,
    achievements,
  ];
}

class Education extends Equatable {
  final String? id;
  final String institution;
  final String degree;
  final String field;
  final String location;
  final DateTime graduationDate;
  final String? gpa;

  const Education({
    this.id,
    required this.institution,
    required this.degree,
    required this.field,
    required this.location,
    required this.graduationDate,
    this.gpa,
  });

  Education copyWith({
    String? id,
    String? institution,
    String? degree,
    String? field,
    String? location,
    DateTime? graduationDate,
    String? gpa,
  }) {
    return Education(
      id: id ?? this.id,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      field: field ?? this.field,
      location: location ?? this.location,
      graduationDate: graduationDate ?? this.graduationDate,
      gpa: gpa ?? this.gpa,
    );
  }

  factory Education.empty() {
    return Education(
      institution: '',
      degree: '',
      field: '',
      location: '',
      graduationDate: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institution': institution,
      'degree': degree,
      'field': field,
      'location': location,
      'graduationDate': graduationDate.toIso8601String(),
      'gpa': gpa,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      id: map['id'],
      institution: map['institution'] ?? '',
      degree: map['degree'] ?? '',
      field: map['field'] ?? '',
      location: map['location'] ?? '',
      graduationDate: DateTime.parse(map['graduationDate'] ?? DateTime.now().toIso8601String()),
      gpa: map['gpa'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    institution,
    degree,
    field,
    location,
    graduationDate,
    gpa,
  ];
}

class Skill extends Equatable {
  final String? id;
  final String name;
  final SkillLevel level;

  const Skill({
    this.id,
    required this.name,
    required this.level,
  });

  Skill copyWith({
    String? id,
    String? name,
    SkillLevel? level,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }

  factory Skill.empty() {
    return Skill(
      name: '',
      level: SkillLevel.beginner,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level.index,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'],
      name: map['name'] ?? '',
      level: SkillLevel.values[map['level'] ?? 0],
    );
  }

  @override
  List<Object?> get props => [id, name, level];
}

class Project extends Equatable {
  final String? id;
  final String name;
  final String description;
  final String technologies;
  final String link;

  const Project({
    this.id,
    required this.name,
    required this.description,
    required this.technologies,
    required this.link,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? technologies,
    String? link,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      link: link ?? this.link,
    );
  }

  factory Project.empty() {
    return Project(
      name: '',
      description: '',
      technologies: '',
      link: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'technologies': technologies,
      'link': link,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      technologies: map['technologies'] ?? '',
      link: map['link'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    technologies,
    link,
  ];
}

class Certification extends Equatable {
  final String? id;
  final String name;
  final String issuer;
  final DateTime date;
  final String credentialId;

  const Certification({
    this.id,
    required this.name,
    required this.issuer,
    required this.date,
    required this.credentialId,
  });

  Certification copyWith({
    String? id,
    String? name,
    String? issuer,
    DateTime? date,
    String? credentialId,
  }) {
    return Certification(
      id: id ?? this.id,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      date: date ?? this.date,
      credentialId: credentialId ?? this.credentialId,
    );
  }

  factory Certification.empty() {
    return Certification(
      name: '',
      issuer: '',
      date: DateTime.now(),
      credentialId: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'date': date.toIso8601String(),
      'credentialId': credentialId,
    };
  }

  factory Certification.fromMap(Map<String, dynamic> map) {
    return Certification(
      id: map['id'],
      name: map['name'] ?? '',
      issuer: map['issuer'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      credentialId: map['credentialId'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    issuer,
    date,
    credentialId,
  ];
}

class Language extends Equatable {
  final String? id;
  final String language;
  final LanguageProficiency proficiency;

  const Language({
    this.id,
    required this.language,
    required this.proficiency,
  });

  Language copyWith({
    String? id,
    String? language,
    LanguageProficiency? proficiency,
  }) {
    return Language(
      id: id ?? this.id,
      language: language ?? this.language,
      proficiency: proficiency ?? this.proficiency,
    );
  }

  factory Language.empty() {
    return Language(
      language: '',
      proficiency: LanguageProficiency.basic,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language': language,
      'proficiency': proficiency.index,
    };
  }

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      id: map['id'],
      language: map['language'] ?? '',
      proficiency: LanguageProficiency.values[map['proficiency'] ?? 0],
    );
  }

  @override
  List<Object?> get props => [id, language, proficiency];
}

class Resume extends Equatable {
  final String id;
  final TemplateType template;
  final PersonalInfo personalInfo;
  final List<Experience> experience;
  final List<Education> education;
  final List<Skill> skills;
  final List<Project> projects;
  final List<Certification> certifications;
  final List<Language> languages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fileName;

  const Resume({
    required this.id,
    required this.template,
    required this.personalInfo,
    required this.experience,
    required this.education,
    required this.skills,
    required this.projects,
    required this.certifications,
    required this.languages,
    required this.createdAt,
    required this.updatedAt,
    this.fileName,
  });

  Resume copyWith({
    String? id,
    TemplateType? template,
    PersonalInfo? personalInfo,
    List<Experience>? experience,
    List<Education>? education,
    List<Skill>? skills,
    List<Project>? projects,
    List<Certification>? certifications,
    List<Language>? languages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fileName,
  }) {
    return Resume(
      id: id ?? this.id,
      template: template ?? this.template,
      personalInfo: personalInfo ?? this.personalInfo,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      languages: languages ?? this.languages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fileName: fileName ?? this.fileName,
    );
  }

  factory Resume.empty() {
    final now = DateTime.now();
    return Resume(
      id: '',
      template: TemplateType.modern,
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
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template': template.index,
      'personalInfo': personalInfo.toMap(),
      'experience': experience.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'skills': skills.map((s) => s.toMap()).toList(),
      'projects': projects.map((p) => p.toMap()).toList(),
      'certifications': certifications.map((c) => c.toMap()).toList(),
      'languages': languages.map((l) => l.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fileName': fileName,
    };
  }

  factory Resume.fromMap(Map<String, dynamic> map) {
    return Resume(
      id: map['id'] ?? '',
      template: TemplateType.values[map['template'] ?? 0],
      personalInfo: PersonalInfo.fromMap(map['personalInfo'] ?? {}),
      experience: (map['experience'] as List<dynamic>?)
          ?.map((e) => Experience.fromMap(e))
          .toList() ??
          [],
      education: (map['education'] as List<dynamic>?)
          ?.map((e) => Education.fromMap(e))
          .toList() ??
          [],
      skills: (map['skills'] as List<dynamic>?)
          ?.map((s) => Skill.fromMap(s))
          .toList() ??
          [],
      projects: (map['projects'] as List<dynamic>?)
          ?.map((p) => Project.fromMap(p))
          .toList() ??
          [],
      certifications: (map['certifications'] as List<dynamic>?)
          ?.map((c) => Certification.fromMap(c))
          .toList() ??
          [],
      languages: (map['languages'] as List<dynamic>?)
          ?.map((l) => Language.fromMap(l))
          .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      fileName: map['fileName'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    template,
    personalInfo,
    experience,
    education,
    skills,
    projects,
    certifications,
    languages,
    createdAt,
    updatedAt,
    fileName,
  ];
}