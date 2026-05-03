import 'package:flutter/material.dart';
import '../data/models/resume.dart';
import '../theme/theme_helper.dart';
import '../l10n/app_localizations.dart';

class LanguagesForm extends StatefulWidget {
  final List<Language> languages;
  final ValueChanged<Language> onAdd;
  final ValueChanged<Language> onUpdate;
  final ValueChanged<String> onRemove;

  const LanguagesForm({
    super.key,
    required this.languages,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<LanguagesForm> createState() => _LanguagesFormState();
}

class _LanguagesFormState extends State<LanguagesForm> {
  final List<TextEditingController> _nameControllers = [];
  final List<LanguageProficiency> _proficiencies = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant LanguagesForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _initControllers() {
    _nameControllers.clear();
    _proficiencies.clear();
    for (var lang in widget.languages) {
      _nameControllers.add(TextEditingController(text: lang.language));
      _proficiencies.add(lang.proficiency);
    }
  }

  void _syncControllers() {
    if (widget.languages.length != _nameControllers.length) {
      for (var c in _nameControllers) c.dispose();
      _initControllers();
    }
  }

  @override
  void dispose() {
    for (var c in _nameControllers) c.dispose();
    super.dispose();
  }

  void _addNew() => widget.onAdd(Language.empty());

  void _update(int i) {
    widget.onUpdate(Language(
      id: widget.languages[i].id,
      language: _nameControllers[i].text,
      proficiency: _proficiencies[i],
    ));
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
          Text(l10n.translate('languages'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.translate('add_language_proficiency'), style: TextStyle(fontSize: 15, color: ThemeHelper.getSecondaryTextColor(context))),
          const SizedBox(height: 32),
          if (widget.languages.isEmpty)
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
                    Icon(Icons.language, size: 48, color: ThemeHelper.getSecondaryTextColor(context)),
                    const SizedBox(height: 16),
                    Text(l10n.translate('no_languages_added'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(l10n.translate('click_add_languages'), style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context))),
                  ],
                ),
              ),
            )
          else
            ...widget.languages.asMap().entries.map((e) => _buildCard(e.key)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNew,
              icon: const Icon(Icons.add),
              label: Text(l10n.translate('add_language')),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${l10n.translate('language_name')} ${i + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => widget.onRemove(widget.languages[i].id ?? ''),
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.translate('language_name'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameControllers[i],
            decoration: InputDecoration(
              hintText: l10n.translate('language_hint'),
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            onChanged: (_) => _update(i),
          ),
          const SizedBox(height: 16),
          Text(l10n.translate('proficiency'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<LanguageProficiency>(
            value: _proficiencies[i],
            decoration: InputDecoration(
              filled: true,
              fillColor: ThemeHelper.getInputFillColor(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            items: LanguageProficiency.values.map((prof) {
              return DropdownMenuItem(value: prof, child: Text(_getLabel(prof)));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _proficiencies[i] = value);
                _update(i);
              }
            },
          ),
        ],
      ),
    );
  }

  String _getLabel(LanguageProficiency prof) {
    final l10n = AppLocalizations.of(context);
    switch (prof) {
      case LanguageProficiency.basic:
        return l10n.translate('basic');
      case LanguageProficiency.conversational:
        return l10n.translate('conversational');
      case LanguageProficiency.fluent:
        return l10n.translate('fluent');
      case LanguageProficiency.native:
        return l10n.translate('native');
    }
  }
}
