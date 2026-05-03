import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/resume_bloc.dart';
import '../blocs/resume_event.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_service.dart';
import '../theme/theme_helper.dart';

class AICVBuilderScreen extends StatefulWidget {
  const AICVBuilderScreen({super.key});

  @override
  State<AICVBuilderScreen> createState() => _AICVBuilderScreenState();
}

class _AICVBuilderScreenState extends State<AICVBuilderScreen> {
  final _jobDescController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isAnalyzing = false;
  bool _isGenerating = false;
  bool _showQuestions = false;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  Map<int, bool> _answers = {};

  @override
  void dispose() {
    _jobDescController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _analyzeJobDescription() async {
    if (_jobDescController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('please_fill_fields'),
          ),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final questions = await AIService.generateQuestionsFromJobDescription(
        _jobDescController.text,
      );
      setState(() {
        _questions = questions;
        _showQuestions = true;
        _currentQuestionIndex = 0;
        _answers.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('ai_error_vpn'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _answerQuestion(bool answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _generateCV();
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  Future<void> _generateCV() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('please_fill_fields'),
          ),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      debugPrint('🔵 Starting CV generation...');
      final resume = await AIService.generateCompleteResume(
        jobDescription: _jobDescController.text,
        questions: _questions,
        answers: _answers,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        location: _locationController.text,
      );
      debugPrint('✅ CV generated successfully');

      if (mounted) {
        context.read<ResumeBloc>().add(UpdateResume(resume));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('cv_generated_success'),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/builder');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error generating CV: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Generation Error'),
            content: SingleChildScrollView(
              child: Text(e.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.getCardColor(context),
        title: Text(
          l10n.translate('ai_cv_builder'),
          style: TextStyle(color: ThemeHelper.getTextColor(context)),
        ),
        iconTheme: IconThemeData(color: ThemeHelper.getIconColor(context)),
      ),
      body: _showQuestions ? _buildQuestionsView() : _buildJobDescriptionView(),
    );
  }

  Widget _buildJobDescriptionView() {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('ai_cv_builder_title'),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ThemeHelper.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('ai_cv_builder_desc'),
            style: TextStyle(
              fontSize: 15,
              color: ThemeHelper.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            l10n.translate('contact_info'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeHelper.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.translate('full_name'),
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.translate('email'),
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: l10n.translate('phone'),
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: l10n.translate('location'),
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            l10n.translate('job_description'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeHelper.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _jobDescController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: l10n.translate('paste_job_desc'),
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeJobDescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.getButtonColor(context),
                foregroundColor: ThemeHelper.getButtonTextColor(context),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isAnalyzing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text(l10n.translate('start_ai_questions')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsView() {
    final l10n = AppLocalizations.of(context);
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: ThemeHelper.getButtonColor(context),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentQuestionIndex > 0)
                      TextButton.icon(
                        onPressed: _previousQuestion,
                        icon: const Icon(Icons.arrow_back),
                        label: Text(l10n.translate('back')),
                      )
                    else
                      const SizedBox(),
                    Text(
                      '${_currentQuestionIndex + 1}/${_questions.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                    const SizedBox(width: 80),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ThemeHelper.getCardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ThemeHelper.getBorderColor(context),
                    ),
                  ),
                  child: Text(
                    question['question'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.getTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isGenerating ? null : () => _answerQuestion(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.translate('no'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isGenerating ? null : () => _answerQuestion(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.translate('yes'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isGenerating) ...[
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('generating_cv'),
                    style: TextStyle(
                      color: ThemeHelper.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('ai_cv_wait'),
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeHelper.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
