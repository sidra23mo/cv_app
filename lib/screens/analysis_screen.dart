import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/resume_bloc.dart';
import '../blocs/resume_event.dart';
import '../blocs/resume_state.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_service.dart';

class AnalysisPage extends StatefulWidget {
  final Resume resume;

  const AnalysisPage({super.key, required this.resume});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final TextEditingController _targetPositionController = TextEditingController();
  final TextEditingController _jobKeywordsController = TextEditingController();
  String _analysisResult = '';
  bool _isAnalyzing = false;
  bool _isTranslating = false;

  @override
  void dispose() {
    _targetPositionController.dispose();
    _jobKeywordsController.dispose();
    super.dispose();
  }

  Future<void> _analyzeResume() async {
    final l10n = AppLocalizations.of(context);
    if (_targetPositionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('enter_target_position')), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
    });

    try {
      final jobKeywords = _jobKeywordsController.text
          .split(',')
          .map((keyword) => keyword.trim())
          .where((keyword) => keyword.isNotEmpty)
          .toList();

      if (jobKeywords.isEmpty) {
        jobKeywords.addAll(_getDefaultKeywords(_targetPositionController.text));
      }

      final result = await AIService.analyzeResumeATSScore(
        resume: widget.resume,
        targetPosition: _targetPositionController.text,
        jobKeywords: jobKeywords,
      );

      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).translate('analysis_failed')}: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _translateToArabic() async {
    setState(() => _isTranslating = true);
    try {
      final translated = await AIService.translateToArabic(_analysisResult);
      setState(() => _analysisResult = translated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  List<String> _getDefaultKeywords(String position) {
    final positionLower = position.toLowerCase();
    if (positionLower.contains('developer') || positionLower.contains('engineer')) {
      return ['software', 'development', 'programming', 'code', 'debugging', 'testing', 'agile', 'scrum', 'version control', 'ci/cd'];
    } else if (positionLower.contains('manager')) {
      return ['leadership', 'management', 'team', 'budget', 'strategy', 'planning', 'coaching', 'performance', 'operations'];
    } else if (positionLower.contains('sales')) {
      return ['sales', 'revenue', 'clients', 'negotiation', 'relationship', 'growth', 'target', 'pipeline', 'conversion'];
    } else if (positionLower.contains('marketing')) {
      return ['marketing', 'campaign', 'brand', 'digital', 'social media', 'content', 'seo', 'analytics', 'engagement'];
    }
    return ['skills', 'experience', 'achievements', 'leadership', 'teamwork'];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('resume_analysis_title')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resume Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.resume.personalInfo.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    Text(widget.resume.personalInfo.title, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(_getTemplateName(context, widget.resume.template), style: const TextStyle(fontSize: 12)),
                          backgroundColor: _getTemplateColor(widget.resume.template).withOpacity(0.1),
                        ),
                        const SizedBox(width: 8),
                        Chip(label: Text('${widget.resume.experience.length} ${l10n.translate('experiences')}', style: const TextStyle(fontSize: 12))),
                        const SizedBox(width: 8),
                        Chip(label: Text('${widget.resume.skills.length} ${l10n.translate('skills')}', style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Analysis Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.translate('resume_analysis_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(l10n.translate('ats_score_desc'), style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetPositionController,
                      decoration: InputDecoration(
                        labelText: '${l10n.translate('target_position')} *',
                        hintText: l10n.translate('target_position_hint'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.work),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jobKeywordsController,
                      decoration: InputDecoration(
                        labelText: l10n.translate('job_keywords'),
                        hintText: l10n.translate('job_keywords_hint'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.key),
                        helperText: l10n.translate('auto_keywords'),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _analyzeResume,
                        icon: _isAnalyzing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                            : const Icon(Icons.analytics, size: 20),
                        label: Text(_isAnalyzing ? l10n.translate('analyzing') : l10n.translate('analyze_resume')),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Analysis Results
            if (_analysisResult.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.assessment, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(l10n.translate('analysis_results'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                        child: Text(_analysisResult, style: const TextStyle(fontSize: 14, height: 1.6)),
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _analysisResult));
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.translate('analysis_copied'))));
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: Text(l10n.translate('copy_analysis')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isTranslating ? null : _translateToArabic,
                              icon: _isTranslating
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.translate, size: 16),
                              label: Text(l10n.translate('translate_arabic')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // Tips Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.translate('tips_ats'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _buildTipItem(l10n.translate('tip1_title'), l10n.translate('tip1_desc')),
                    _buildTipItem(l10n.translate('tip2_title'), l10n.translate('tip2_desc')),
                    _buildTipItem(l10n.translate('tip3_title'), l10n.translate('tip3_desc')),
                    _buildTipItem(l10n.translate('tip4_title'), l10n.translate('tip4_desc')),
                    _buildTipItem(l10n.translate('tip5_title'), l10n.translate('tip5_desc')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }



  String _getTemplateName(BuildContext context, TemplateType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case TemplateType.modern: return l10n.translate('modern');
      case TemplateType.executive: return l10n.translate('executive');
      case TemplateType.creative: return l10n.translate('creative');
      case TemplateType.minimal: return l10n.translate('minimal');
      case TemplateType.tech: return l10n.translate('tech');
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
}