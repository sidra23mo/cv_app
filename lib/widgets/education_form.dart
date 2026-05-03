import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/resume.dart';
import '../theme/theme_helper.dart';
import '../l10n/app_localizations.dart';

class EducationForm extends StatefulWidget {
  final List<Education> education;
  final ValueChanged<Education> onAdd;
  final ValueChanged<Education> onUpdate;
  final ValueChanged<String> onRemove;

  const EducationForm({
    super.key,
    required this.education,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  final List<TextEditingController> _institutionControllers = [];
  final List<int> _degreeIndices = [];
  final List<TextEditingController> _fieldControllers = [];
  final List<TextEditingController> _locationControllers = [];
  final List<TextEditingController> _gpaControllers = [];
  final List<DateTime?> _graduationDates = [];

  final List<String> _degreeKeys = ['high_school', 'associate', 'bachelor', 'master', 'doctorate', 'other'];

  List<String> _degreeOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _degreeKeys.map((key) => l10n.translate(key)).toList();
  }

  int _getDegreeIndex(String degree) {
    final enDegrees = ['High School', 'Associate', 'Bachelor', 'Master', 'Doctorate', 'Other'];
    final index = enDegrees.indexOf(degree);
    return index >= 0 ? index : 0;
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant EducationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _initControllers() {
    _institutionControllers.clear();
    _degreeIndices.clear();
    _fieldControllers.clear();
    _locationControllers.clear();
    _gpaControllers.clear();
    _graduationDates.clear();

    for (var edu in widget.education) {
      _institutionControllers.add(TextEditingController(text: edu.institution));
      _degreeIndices.add(_getDegreeIndex(edu.degree));
      _fieldControllers.add(TextEditingController(text: edu.field));
      _locationControllers.add(TextEditingController(text: edu.location));
      _gpaControllers.add(TextEditingController(text: edu.gpa ?? ''));
      _graduationDates.add(edu.graduationDate);
    }
  }

  void _syncControllers() {
    if (widget.education.length != _institutionControllers.length) {
      for (var c in _institutionControllers) c.dispose();
      for (var c in _fieldControllers) c.dispose();
      for (var c in _locationControllers) c.dispose();
      for (var c in _gpaControllers) c.dispose();
      _initControllers();
    }
  }

  @override
  void dispose() {
    for (var c in _institutionControllers) c.dispose();
    for (var c in _fieldControllers) c.dispose();
    for (var c in _locationControllers) c.dispose();
    for (var c in _gpaControllers) c.dispose();
    super.dispose();
  }

  void _addNew() => widget.onAdd(Education.empty());

  void _update(int i) {
    final enDegrees = ['High School', 'Associate', 'Bachelor', 'Master', 'Doctorate', 'Other'];
    widget.onUpdate(Education(
      id: widget.education[i].id,
      institution: _institutionControllers[i].text,
      degree: enDegrees[_degreeIndices[i]],
      field: _fieldControllers[i].text,
      location: _locationControllers[i].text,
      graduationDate: _graduationDates[i] ?? DateTime.now(),
      gpa: _gpaControllers[i].text.isNotEmpty ? _gpaControllers[i].text : null,
    ));
  }

  Future<void> _pickDate(int i) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _graduationDates[i] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _graduationDates[i] = date);
      _update(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncControllers();
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('education'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.translate('add_education_background'), style: TextStyle(fontSize: 15, color: ThemeHelper.getSecondaryTextColor(context))),
          const SizedBox(height: 32),
          if (widget.education.isEmpty)
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
                    Icon(Icons.school_outlined, size: 48, color: ThemeHelper.getSecondaryTextColor(context)),
                    const SizedBox(height: 16),
                    Text(l10n.translate('no_education_added'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(l10n.translate('click_add_education'), style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context))),
                  ],
                ),
              ),
            )
          else
            ...widget.education.asMap().entries.map((e) => _buildCard(e.key)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNew,
              icon: const Icon(Icons.add),
              label: Text(l10n.translate('add_education_history')),
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
              Text('${l10n.translate('education')} ${i + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => widget.onRemove(widget.education[i].id ?? ''),
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(l10n.translate('institution'), _institutionControllers[i], l10n.translate('institution'), i),
          const SizedBox(height: 16),
          _buildDegreeDropdown(i),
          const SizedBox(height: 16),
          _buildField(l10n.translate('field_of_study'), _fieldControllers[i], l10n.translate('field_of_study'), i),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildField(l10n.translate('location'), _locationControllers[i], l10n.translate('location'), i)),
              const SizedBox(width: 16),
              Expanded(child: _buildField(l10n.translate('gpa'), _gpaControllers[i], '3.8/4.0', i)),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('graduation_date'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickDate(i),
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
                      Text(_graduationDates[i] != null ? DateFormat('MMM yyyy').format(_graduationDates[i]!) : l10n.translate('select_date')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDegreeDropdown(int i) {
    final l10n = AppLocalizations.of(context);
    final options = _degreeOptions(context);
    final currentIndex = _degreeIndices.length > i ? _degreeIndices[i] : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.translate('degree'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: currentIndex,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: ThemeHelper.getInputFillColor(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: List.generate(options.length, (index) {
            return DropdownMenuItem(value: index, child: Text(options[index], overflow: TextOverflow.ellipsis));
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() => _degreeIndices[i] = value);
              _update(i);
            }
          },
        ),
      ],
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
          onChanged: (_) => _update(i),
        ),
      ],
    );
  }
}
