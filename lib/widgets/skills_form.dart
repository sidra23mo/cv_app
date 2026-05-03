import 'package:flutter/material.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme_helper.dart';

class SkillsForm extends StatefulWidget {
  final List<Skill> skills;
  final ValueChanged<Skill> onAdd;
  final ValueChanged<Skill> onUpdate;
  final ValueChanged<String> onRemove;

  const SkillsForm({
    super.key,
    required this.skills,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<SkillsForm> createState() => _SkillsFormState();
}

class _SkillsFormState extends State<SkillsForm> {
  final List<TextEditingController> _skillControllers = [];
  final List<SkillLevel> _skillLevels = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant SkillsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllersWithSkills();
  }

  void _initializeControllers() {
    _skillControllers.clear();
    _skillLevels.clear();
    for (var skill in widget.skills) {
      _skillControllers.add(TextEditingController(text: skill.name));
      _skillLevels.add(skill.level);
    }
  }

  void _syncControllersWithSkills() {
    if (widget.skills.length != _skillControllers.length) {
      for (var controller in _skillControllers) {
        controller.dispose();
      }
      _initializeControllers();
      return;
    }
    for (int i = 0; i < widget.skills.length; i++) {
      if (_skillControllers[i].text != widget.skills[i].name) {
        _skillControllers[i].text = widget.skills[i].name;
      }
      _skillLevels[i] = widget.skills[i].level;
    }
  }

  @override
  void dispose() {
    for (var controller in _skillControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewSkill() => widget.onAdd(Skill.empty());

  void _updateSkill(int index) {
    widget.onUpdate(Skill(
      id: widget.skills[index].id,
      name: _skillControllers[index].text,
      level: _skillLevels[index],
    ));
  }

  void _removeSkill(int index) => widget.onRemove(widget.skills[index].id ?? '');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _syncControllersWithSkills();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('skills'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.translate('add_key_skills'), style: TextStyle(fontSize: 15, color: ThemeHelper.getSecondaryTextColor(context))),
          const SizedBox(height: 32),
          if (widget.skills.isEmpty)
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
                    Icon(Icons.star_outline, size: 48, color: ThemeHelper.getSecondaryTextColor(context)),
                    const SizedBox(height: 16),
                    Text(l10n.translate('no_skills_added'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(l10n.translate('click_add_first'), style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context))),
                  ],
                ),
              ),
            )
          else
            ...widget.skills.asMap().entries.map((e) => _buildSkillCard(e.key)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNewSkill,
              icon: const Icon(Icons.add),
              label: Text(l10n.translate('add_skill')),
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

  Widget _buildSkillCard(int index) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${l10n.translate('skill')} ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => _removeSkill(index),
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.translate('skill_name'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _skillControllers[index],
            decoration: InputDecoration(
              hintText: 'e.g., JavaScript, Leadership',
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => _updateSkill(index),
          ),
          const SizedBox(height: 16),
          Text(l10n.translate('level'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<SkillLevel>(
            value: _skillLevels[index],
            decoration: InputDecoration(
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: SkillLevel.values.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(_getLevelLabel(level)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _skillLevels[index] = value);
                _updateSkill(index);
              }
            },
          ),
        ],
      ),
    );
  }

  String _getLevelLabel(SkillLevel level) {
    final l10n = AppLocalizations.of(context);
    switch (level) {
      case SkillLevel.beginner:
        return l10n.translate('beginner');
      case SkillLevel.intermediate:
        return l10n.translate('intermediate');
      case SkillLevel.advanced:
        return l10n.translate('advanced');
      case SkillLevel.expert:
        return l10n.translate('expert');
    }
  }
}
