import 'package:equatable/equatable.dart';

import '../data/models/resume.dart';


enum ResumeStatus { initial, loading, success, failure }

class ResumeState extends Equatable {
  final ResumeStatus status;
  final List<Resume> resumes;
  final Resume? currentResume;
  final String errorMessage;
  final bool isSaving;
  final List<String> skillSuggestions;  // Add this line
  final TemplateType defaultTemplate; // 👈 ADD THIS

  const ResumeState({
    this.status = ResumeStatus.initial,
    this.resumes = const [],
    this.currentResume,
    this.errorMessage = '',
    this.isSaving = false,
    this.skillSuggestions = const [],  // Add this line
    this.defaultTemplate = TemplateType.modern, // 👈 DEFAULT VALUE
  });

  ResumeState copyWith({
    ResumeStatus? status,
    List<Resume>? resumes,
    Resume? currentResume,
    String? errorMessage,
    bool? isSaving,
    List<String>? skillSuggestions,
    TemplateType? defaultTemplate,// Add this line

  }) {
    return ResumeState(
      status: status ?? this.status,
      resumes: resumes ?? this.resumes,
      currentResume: currentResume ?? this.currentResume,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      skillSuggestions: skillSuggestions ?? this.skillSuggestions,  // Add this line
      defaultTemplate: defaultTemplate ?? this.defaultTemplate, // 👈 ADD THIS

    );
  }

  @override
  List<Object?> get props => [
    status,
    resumes,
    currentResume,
    errorMessage,
    isSaving,
    skillSuggestions,
    defaultTemplate,// Add this line
  ];
}