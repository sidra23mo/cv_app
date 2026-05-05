// lib/services/ai_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/models/resume.dart';

class AIService {
  /// API key configuration for different build modes
  static String get _apiKey {
    const key = String.fromEnvironment('GEMINI_API_KEY');
    return key;
  }

  /// Prefer a stable, currently supported model first.
  static const List<String> _modelCandidates = <String>[
    'gemini-2.5-flash',
    'gemini-flash-latest',
    'gemini-1.5-flash-latest', // kept as last fallback for older accounts
  ];

  static GenerativeModel _makeModel(String modelName) =>
      GenerativeModel(model: modelName, apiKey: _apiKey);

  static Future<String> _generate(String prompt) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_ACTUAL_GEMINI_API_KEY_HERE') {
      throw StateError(
        'GEMINI_API_KEY is not configured. Please set your API key in ai_service.dart',
      );
    }

    debugPrint('🔑 Using API Key: ${apiKey.substring(0, 8)}...');
    debugPrint('📝 Prompt length: ${prompt.length}');

    final content = <Content>[Content.text(prompt)];
    Object? lastError;

    for (final modelName in _modelCandidates) {
      try {
        debugPrint('🤖 AI: Generating with model: $modelName');
        final model = GenerativeModel(model: modelName, apiKey: apiKey);
        final response = await model.generateContent(content);
        final text = response.text?.trim() ?? '';
        if (text.isNotEmpty) {
          debugPrint('✅ AI: Response received from $modelName');
          return text;
        }
        lastError ??= Exception('Empty response from $modelName');
      } catch (e) {
        lastError = e;
        debugPrint('❌ AI: API call failed for $modelName - $e');
        if (e.toString().contains('API_KEY_INVALID') ||
            e.toString().contains('403')) {
          throw Exception('Invalid API key or insufficient permissions');
        }
        if (e.toString().contains('QUOTA_EXCEEDED') ||
            e.toString().contains('429')) {
          throw Exception('API quota exceeded. Check your billing settings.');
        }
        // Try next model candidate
      }
    }

    throw Exception('All Gemini model attempts failed. Last error: $lastError');
  }

  static Future<String> generateBasicProfessionalSummary({
    required String fullName,
    required String title,
  }) async {
    final prompt = '''Generate a concise professional summary for a resume.
Name: $fullName
Professional Title: $title

Requirements:
- 2-3 sentences only
- Start with the job title
- Highlight expertise and value proposition
- Use professional, ATS-friendly language
- No markdown, no explanations
- Return only the summary text''';

    final response = await _generate(prompt);
    return _cleanResponse(response);
  }

  static Future<String> generateProfessionalSummary({
    required String fullName,
    required String title,
    required String industry,
    required List<String> keySkills,
    required int yearsOfExperience,
  }) async {
    if (industry.isEmpty && keySkills.isEmpty && yearsOfExperience == 0) {
      return generateBasicProfessionalSummary(fullName: fullName, title: title);
    }

    final prompt = '''Generate a professional summary for a resume:
- Name: $fullName
- Professional Title: $title
- Industry: ${industry.isEmpty ? 'general professional' : industry}
- Key Skills: ${keySkills.isEmpty ? 'various professional skills' : keySkills.join(', ')}
- Years of Experience: $yearsOfExperience

Requirements:
- 2-3 sentences only
- Start with job title and experience
- Highlight key skills and achievements
- Use professional, ATS-friendly language
- No markdown, no explanations
- Return only the summary text''';

    final response = await _generate(prompt);
    return _cleanResponse(response);
  }

  static String _cleanResponse(String response) {
    return response
        .replaceAll(RegExp(r'^Summary[:\s]*', caseSensitive: false), '')
        .replaceAll(
          RegExp(r'^Professional Summary[:\s]*', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'^Here is.*?:\s*', caseSensitive: false), '')
        .trim();
  }

  static Future<List<String>> generateAchievements({
    required String position,
    required String company,
    required String industry,
    required List<String> responsibilities,
  }) async {
    final prompt = '''Generate 3-4 professional achievements for a resume:
- Position: $position
- Company: $company
- Industry: $industry
- Key Responsibilities: ${responsibilities.join(', ')}

Requirements:
- Write clear, action-oriented bullet points
- Focus on impact and results
- Use strong action verbs (Led, Developed, Implemented, etc.)
- Be specific and concrete
- NO percentages or numbers unless realistic
- Each achievement should be 1-2 lines
- Format: Start each line with "- "

Example format:
- Led cross-functional team to deliver project ahead of schedule
- Developed new system that improved workflow efficiency
- Implemented best practices that enhanced team productivity''';

    final response = await _generate(prompt);

    final lines =
        response
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim())
            .where(
              (line) =>
                  line.startsWith('-') ||
                  line.startsWith('•') ||
                  line.startsWith('*'),
            )
            .map((line) {
              if (line.startsWith('- ')) return line.substring(2);
              if (line.startsWith('• ')) return line.substring(2);
              if (line.startsWith('* ')) return line.substring(2);
              return line;
            })
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

    if (lines.isEmpty) {
      throw Exception('Could not parse achievements');
    }
    return lines.take(4).toList();
  }

  static Future<List<String>> generateSkillSuggestions({
    required String industry,
    required String position,
    required List<String> existingSkills,
  }) async {
    final prompt =
        '''Suggest 8 relevant skills for a $position in the $industry industry.
Existing skills: ${existingSkills.join(', ')}
Return only new skills as comma-separated list.''';

    final response = await _generate(prompt);

    final suggestions =
        response
            .split(',')
            .map((skill) => skill.trim())
            .where((skill) => skill.isNotEmpty)
            .where(
              (skill) =>
                  !existingSkills.any(
                    (existing) =>
                        existing.toLowerCase().contains(skill.toLowerCase()) ||
                        skill.toLowerCase().contains(existing.toLowerCase()),
                  ),
            )
            .toList();

    if (suggestions.isEmpty) {
      throw Exception('Could not parse skills');
    }
    return suggestions.take(8).toList();
  }

  static Future<String> analyzeResumeATSScore({
    required Resume resume,
    required String targetPosition,
    required List<String> jobKeywords,
  }) async {
    final prompt = '''Analyze this resume for ATS compatibility:
- Name: ${resume.personalInfo.fullName}
- Target Position: $targetPosition
- Experience: ${resume.experience.length} entries
- Skills: ${resume.skills.length} skills
- Job Keywords: ${jobKeywords.join(', ')}

Return in format:
ATS Score: [score]/100

Strengths:
- [strength 1]
- [strength 2]

Suggestions:
- [suggestion 1]
- [suggestion 2]''';

    final response = await _generate(prompt);
    return response.isNotEmpty ? response : 'Unable to generate analysis';
  }

  static Future<String> translateToArabic(String text) async {
    final prompt =
        '''Translate the following text to Arabic. Keep the same structure and formatting:

$text

Return only the Arabic translation, no explanations.''';

    final response = await _generate(prompt);
    return response.isNotEmpty ? response : text;
  }

  static Future<List<Map<String, dynamic>>> generateQuestionsFromJobDescription(
    String jobDescription,
  ) async {
    final prompt =
        '''Analyze this job description and generate 15 targeted yes/no questions to build an ATS-optimized CV:

$jobDescription

Generate specific questions covering:
- Relevant work experience (3-4 questions)
- Required technical skills (3-4 questions)
- Soft skills and competencies (2-3 questions)
- Education and certifications (2 questions)
- Project and leadership experience (2-3 questions)

Make questions specific to the job requirements. Format each question on a new line starting with "Q: "

Example:
Q: Do you have 3+ years of experience in software development?
Q: Are you proficient in React and Node.js?
Q: Have you led cross-functional teams?
Q: Do you hold a Bachelor's degree in Computer Science or related field?''';

    final response = await _generate(prompt);
    final lines =
        response
            .split('\n')
            .where((line) => line.trim().startsWith('Q:'))
            .toList();

    if (lines.isEmpty) throw Exception('Could not generate questions');

    return lines
        .take(15)
        .map(
          (line) => {
            'question': line.replaceFirst('Q:', '').trim(),
            'category': 'general',
          },
        )
        .toList();
  }

  static Future<Resume> generateCompleteResume({
    required String jobDescription,
    required List<Map<String, dynamic>> questions,
    required Map<int, bool> answers,
    required String name,
    required String email,
    required String phone,
    required String location,
  }) async {
    final answeredQuestions = questions
        .asMap()
        .entries
        .where((e) => answers[e.key] == true)
        .map((e) => e.value['question'])
        .join('\n- ');

    final prompt =
        '''Generate a complete ATS-optimized professional resume based on:

Job Description:
$jobDescription

User's Qualifications (answered YES to):
- $answeredQuestions

IMPORTANT REQUIREMENTS:
1. Extract keywords from job description and incorporate them naturally
2. Create 2-3 relevant work experiences with quantifiable achievements
3. Include education matching job requirements
4. List 8-12 relevant technical and soft skills from job description
5. Add 1-2 relevant certifications if applicable
6. Use action verbs: Led, Developed, Implemented, Managed, Designed
7. Make achievements specific and measurable
8. Ensure 90%+ ATS compatibility

Generate in this exact JSON format:
{
  "title": "Professional Title matching job",
  "summary": "Compelling 3-sentence professional summary with keywords",
  "experience": [
    {
      "position": "Relevant Job Title",
      "company": "Company Name",
      "location": "City, Country",
      "startYear": 2021,
      "startMonth": 3,
      "endYear": 2024,
      "endMonth": 1,
      "current": false,
      "achievements": [
        "Led team of 5 developers to deliver project 2 weeks ahead of schedule",
        "Implemented automated testing reducing bugs by 40%",
        "Developed scalable microservices architecture serving 100K+ users"
      ]
    }
  ],
  "education": [
    {
      "degree": "Bachelor of Science",
      "field": "Computer Science",
      "institution": "University Name",
      "location": "City, Country",
      "year": 2020,
      "month": 6,
      "gpa": "3.7"
    }
  ],
  "skills": ["Skill1", "Skill2", "Skill3", "Skill4", "Skill5", "Skill6", "Skill7", "Skill8"],
  "certifications": [
    {
      "name": "Relevant Certification",
      "issuer": "Issuing Organization",
      "year": 2023,
      "month": 8
    }
  ],
  "projects": [
    {
      "name": "Project Name",
      "description": "Brief description of impactful project",
      "technologies": "Tech1, Tech2, Tech3",
      "link": ""
    }
  ]
}

Return ONLY valid JSON, no markdown, no explanations.''';

    final response = await _generate(prompt);
    debugPrint('📝 AI Response received, length: ${response.length}');

    var jsonStr = response.trim();

    // Remove all markdown code blocks more aggressively
    jsonStr = jsonStr.replaceAll(RegExp(r'^```json\s*', multiLine: true), '');
    jsonStr = jsonStr.replaceAll(RegExp(r'^```\s*', multiLine: true), '');
    jsonStr = jsonStr.replaceAll(RegExp(r'\s*```\s*$', multiLine: true), '');
    jsonStr = jsonStr.trim();

    debugPrint('📝 Cleaned JSON length: ${jsonStr.length}');

    try {
      debugPrint('📝 Parsing JSON response...');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      debugPrint('✅ JSON parsed successfully');

      return Resume(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        template: TemplateType.modern,
        personalInfo: PersonalInfo(
          fullName: name,
          title: data['title'] ?? 'Professional',
          email: email,
          phone: phone,
          location: location,
          linkedin: '',
          portfolio: '',
          professionalSummary: data['summary'] ?? '',
        ),
        experience:
            (data['experience'] as List?)
                ?.map(
                  (e) => Experience(
                    position: e['position'] ?? '',
                    company: e['company'] ?? '',
                    location: e['location'] ?? '',
                    startDate: DateTime(
                      e['startYear'] ?? 2020,
                      e['startMonth'] ?? 1,
                    ),
                    endDate:
                        e['current'] == true
                            ? null
                            : DateTime(
                              e['endYear'] ?? 2023,
                              e['endMonth'] ?? 12,
                            ),
                    current: e['current'] ?? false,
                    achievements:
                        (e['achievements'] as List?)?.cast<String>() ?? [],
                  ),
                )
                .toList() ??
            [],
        education:
            (data['education'] as List?)
                ?.map(
                  (e) => Education(
                    degree: e['degree'] ?? '',
                    field: e['field'] ?? '',
                    institution: e['institution'] ?? '',
                    location: e['location'] ?? '',
                    graduationDate: DateTime(
                      e['year'] ?? 2020,
                      e['month'] ?? 5,
                    ),
                    gpa: e['gpa'],
                  ),
                )
                .toList() ??
            [],
        skills:
            (data['skills'] as List?)
                ?.map(
                  (s) => Skill(name: s.toString(), level: SkillLevel.advanced),
                )
                .toList() ??
            [],
        certifications:
            (data['certifications'] as List?)
                ?.map(
                  (c) => Certification(
                    name: c['name'] ?? '',
                    issuer: c['issuer'] ?? '',
                    date: DateTime(c['year'] ?? 2022, c['month'] ?? 1),
                    credentialId: '',
                  ),
                )
                .toList() ??
            [],
        projects:
            (data['projects'] as List?)
                ?.map(
                  (p) => Project(
                    name: p['name'] ?? '',
                    description: p['description'] ?? '',
                    technologies: p['technologies'] ?? '',
                    link: p['link'] ?? '',
                  ),
                )
                .toList() ??
            [],
        languages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ JSON Parse Error: $e');
      debugPrint('📝 Raw JSON String: $jsonStr');
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
