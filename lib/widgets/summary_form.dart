// lib/widgets/summary_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/resume_bloc.dart';
import '../blocs/resume_event.dart';

class SummaryForm extends StatefulWidget {
  final String summary;
  final ValueChanged<String> onChanged;

  const SummaryForm({
    super.key,
    required this.summary,
    required this.onChanged,
  });

  @override
  State<SummaryForm> createState() => _SummaryFormState();
}

class _SummaryFormState extends State<SummaryForm> {
  late TextEditingController _summaryController;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(text: widget.summary);
  }

  @override
  void didUpdateWidget(covariant SummaryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllerWithSummary(); // 🔥 Sync on update
  }

  // 🔥 NEW: Sync controller with latest summary
  void _syncControllerWithSummary() {
    if (_summaryController.text != widget.summary) {
      _summaryController.text = widget.summary;
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _generateAISummary() async {
    setState(() {
      _isGenerating = true;
    });

    // Dispatch AI event — UI will update automatically via Bloc
    context.read<ResumeBloc>().add(GenerateAISummary());

    // Optional: Listen for AI completion (not required if Bloc emits new state)
    // We'll just reset loading after a delay for UX
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncControllerWithSummary(); // 🔥 Ensure controller is up-to-date

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Professional Summary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Write a compelling summary that highlights your key qualifications',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateAISummary,
              icon: _isGenerating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, size: 20),
              label: Text(_isGenerating ? 'Generating...' : 'AI Suggest Summary'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple.withOpacity(0.1),
                foregroundColor: Colors.purple,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _summaryController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Write a 2-3 sentence summary highlighting your key achievements, skills, and career goals...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.purple, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${_summaryController.text.length} characters',
                style: TextStyle(
                  fontSize: 14,
                  color: _summaryController.text.length > 500 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.purple[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Best Practices for Professional Summaries',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '✅ Keep it concise (2-3 sentences)\n'
                      '✅ Start with your job title and years of experience\n'
                      '✅ Highlight key skills and achievements\n'
                      '✅ Use action verbs and quantifiable results\n'
                      '✅ Tailor to the specific role you\'re targeting\n'
                      '✅ Mention your career goals or value proposition\n'
                      '❌ Avoid generic phrases like "team player"\n'
                      '❌ Don\'t repeat information from other sections',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}