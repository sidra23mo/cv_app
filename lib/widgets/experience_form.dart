import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/resume_bloc.dart';
import '../blocs/resume_event.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_service.dart';
import '../theme/theme_helper.dart';

class ExperienceForm extends StatefulWidget {
  final List<Experience> experiences;
  final ValueChanged<Experience> onAdd;
  final ValueChanged<Experience> onUpdate;
  final ValueChanged<String> onRemove;

  const ExperienceForm({
    super.key,
    required this.experiences,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  final List<TextEditingController> _companyControllers = [];
  final List<TextEditingController> _positionControllers = [];
  final List<TextEditingController> _locationControllers = [];
  final List<TextEditingController> _achievementControllers = [];
  final List<bool> _currentStatus = [];
  final List<DateTime?> _startDates = [];
  final List<DateTime?> _endDates = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant ExperienceForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _initializeControllers() {
    _companyControllers.clear();
    _positionControllers.clear();
    _locationControllers.clear();
    _achievementControllers.clear();
    _currentStatus.clear();
    _startDates.clear();
    _endDates.clear();

    for (var exp in widget.experiences) {
      _companyControllers.add(TextEditingController(text: exp.company));
      _positionControllers.add(TextEditingController(text: exp.position));
      _locationControllers.add(TextEditingController(text: exp.location));
      _achievementControllers.add(TextEditingController(text: exp.achievements.join('\n')));
      _currentStatus.add(exp.current);
      _startDates.add(exp.startDate);
      _endDates.add(exp.endDate);
    }
  }

  void _syncControllers() {
    if (widget.experiences.length != _companyControllers.length) {
      for (var c in _companyControllers) c.dispose();
      for (var c in _positionControllers) c.dispose();
      for (var c in _locationControllers) c.dispose();
      for (var c in _achievementControllers) c.dispose();
      _initializeControllers();
      return;
    }
    for (int i = 0; i < widget.experiences.length; i++) {
      final exp = widget.experiences[i];
      if (_companyControllers[i].text != exp.company) _companyControllers[i].text = exp.company;
      if (_positionControllers[i].text != exp.position) _positionControllers[i].text = exp.position;
      if (_locationControllers[i].text != exp.location) _locationControllers[i].text = exp.location;
      if (_achievementControllers[i].text != exp.achievements.join('\n')) _achievementControllers[i].text = exp.achievements.join('\n');
      _currentStatus[i] = exp.current;
      _startDates[i] = exp.startDate;
      _endDates[i] = exp.endDate;
    }
  }

  @override
  void dispose() {
    for (var c in _companyControllers) c.dispose();
    for (var c in _positionControllers) c.dispose();
    for (var c in _locationControllers) c.dispose();
    for (var c in _achievementControllers) c.dispose();
    super.dispose();
  }

  void _addNewExperience() => widget.onAdd(Experience.empty());

  void _updateExperience(int index) {
    final achievements = _achievementControllers[index].text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    widget.onUpdate(Experience(
      id: widget.experiences[index].id,
      company: _companyControllers[index].text,
      position: _positionControllers[index].text,
      location: _locationControllers[index].text,
      startDate: _startDates[index] ?? DateTime.now(),
      endDate: _currentStatus[index] ? null : _endDates[index],
      current: _currentStatus[index],
      achievements: achievements,
    ));
  }

  Future<void> _showDatePicker(bool isStart, int index) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDates[index] : _endDates[index]) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => isStart ? _startDates[index] = date : _endDates[index] = date);
      _updateExperience(index);
    }
  }

  void _generateAI(int index) async {
    final l10n = AppLocalizations.of(context);
    final exp = widget.experiences[index];
    if (exp.position.isEmpty || exp.company.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.translate('please_fill_fields'))));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text(l10n.translate('generating_summary')),
          ],
        ),
        duration: const Duration(seconds: 10),
      ),
    );

    try {
      final achievements = await AIService.generateAchievements(
        position: exp.position,
        company: exp.company,
        industry: '',
        responsibilities: [],
      );
      
      final updatedExp = exp.copyWith(achievements: achievements);
      widget.onUpdate(updatedExp);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('summary_generated')), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('ai_error_vpn')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _syncControllers();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('work_experience'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.translate('add_work_history'), style: TextStyle(fontSize: 15, color: ThemeHelper.getSecondaryTextColor(context))),
          const SizedBox(height: 32),
          if (widget.experiences.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeHelper.getBorderColor(context)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.work_outline, size: 48, color: ThemeHelper.getSecondaryTextColor(context)),
                    const SizedBox(height: 16),
                    Text(l10n.translate('no_experience_added'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(l10n.translate('click_add_first'), style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context))),
                  ],
                ),
              ),
            )
          else
            ...widget.experiences.asMap().entries.map((e) => _buildCard(e.key)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNewExperience,
              icon: const Icon(Icons.add),
              label: Text(l10n.translate('add_experience')),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.getButtonColor(context),
                foregroundColor: ThemeHelper.getButtonTextColor(context),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int i) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${l10n.translate('experience')} ${i + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => widget.onRemove(widget.experiences[i].id ?? ''),
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(l10n.translate('company'), _companyControllers[i], 'Google, Microsoft', i),
          const SizedBox(height: 16),
          _buildField(l10n.translate('position'), _positionControllers[i], 'Software Engineer', i),
          const SizedBox(height: 16),
          _buildField(l10n.translate('location'), _locationControllers[i], 'San Francisco, CA', i),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDateField(l10n.translate('start_date'), _startDates[i], () => _showDatePicker(true, i))),
              const SizedBox(width: 16),
              Expanded(child: _buildDateField(l10n.translate('end_date'), _currentStatus[i] ? null : _endDates[i], _currentStatus[i] ? null : () => _showDatePicker(false, i), disabled: _currentStatus[i])),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _currentStatus[i],
                onChanged: (v) {
                  setState(() => _currentStatus[i] = v ?? false);
                  _updateExperience(i);
                },
              ),
              Text(l10n.translate('currently_working')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.translate('responsibilities'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _generateAI(i),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(l10n.translate('ai_generate')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeHelper.getButtonColor(context),
                  foregroundColor: ThemeHelper.getButtonTextColor(context),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _achievementControllers[i],
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '• Increased revenue by 20%\n• Led team of 5 engineers',
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            onChanged: (_) => _updateExperience(i),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: ThemeHelper.getInputFillColor(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          onChanged: (_) => _updateExperience(i),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback? onTap, {bool disabled = false}) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ThemeHelper.getInputFillColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: ThemeHelper.getSecondaryTextColor(context)),
                const SizedBox(width: 8),
                Text(disabled ? l10n.translate('present') : (date != null ? DateFormat('MMM yyyy').format(date) : 'Select date')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
