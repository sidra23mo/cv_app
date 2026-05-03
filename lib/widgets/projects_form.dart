import 'package:flutter/material.dart';
import '../data/models/resume.dart';
import '../theme/theme_helper.dart';
import '../l10n/app_localizations.dart';

class ProjectsForm extends StatefulWidget {
  final List<Project> projects;
  final ValueChanged<Project> onAdd;
  final ValueChanged<Project> onUpdate;
  final ValueChanged<String> onRemove;

  const ProjectsForm({
    super.key,
    required this.projects,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<ProjectsForm> createState() => _ProjectsFormState();
}

class _ProjectsFormState extends State<ProjectsForm> {
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _descriptionControllers = [];
  final List<TextEditingController> _technologiesControllers = [];
  final List<TextEditingController> _linkControllers = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant ProjectsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _initControllers() {
    _nameControllers.clear();
    _descriptionControllers.clear();
    _technologiesControllers.clear();
    _linkControllers.clear();

    for (var proj in widget.projects) {
      _nameControllers.add(TextEditingController(text: proj.name));
      _descriptionControllers.add(TextEditingController(text: proj.description));
      _technologiesControllers.add(TextEditingController(text: proj.technologies));
      _linkControllers.add(TextEditingController(text: proj.link));
    }
  }

  void _syncControllers() {
    if (widget.projects.length != _nameControllers.length) {
      for (var c in _nameControllers) c.dispose();
      for (var c in _descriptionControllers) c.dispose();
      for (var c in _technologiesControllers) c.dispose();
      for (var c in _linkControllers) c.dispose();
      _initControllers();
    }
  }

  @override
  void dispose() {
    for (var c in _nameControllers) c.dispose();
    for (var c in _descriptionControllers) c.dispose();
    for (var c in _technologiesControllers) c.dispose();
    for (var c in _linkControllers) c.dispose();
    super.dispose();
  }

  void _addNew() => widget.onAdd(Project.empty());

  void _update(int i) {
    widget.onUpdate(Project(
      id: widget.projects[i].id,
      name: _nameControllers[i].text,
      description: _descriptionControllers[i].text,
      technologies: _technologiesControllers[i].text,
      link: _linkControllers[i].text,
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
          Text(l10n.translate('projects'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.translate('add_projects_portfolio'), style: TextStyle(fontSize: 15, color: ThemeHelper.getSecondaryTextColor(context))),
          const SizedBox(height: 32),
          if (widget.projects.isEmpty)
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
                    Icon(Icons.assignment_outlined, size: 48, color: ThemeHelper.getSecondaryTextColor(context)),
                    const SizedBox(height: 16),
                    Text(l10n.translate('no_projects_added'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(l10n.translate('click_add_projects'), style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context))),
                  ],
                ),
              ),
            )
          else
            ...widget.projects.asMap().entries.map((e) => _buildCard(e.key)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNew,
              icon: const Icon(Icons.add),
              label: Text(l10n.translate('add_project')),
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
              Text('${l10n.translate('project_name')} ${i + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => widget.onRemove(widget.projects[i].id ?? ''),
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(l10n.translate('project_name'), _nameControllers[i], l10n.translate('project_name'), i),
          const SizedBox(height: 16),
          _buildField(l10n.translate('description'), _descriptionControllers[i], l10n.translate('project_description_hint'), i, maxLines: 4),
          const SizedBox(height: 16),
          _buildField(l10n.translate('technologies'), _technologiesControllers[i], 'React, Node.js, MongoDB', i),
          const SizedBox(height: 16),
          _buildField(l10n.translate('project_url'), _linkControllers[i], 'https://github.com/...', i),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, int i, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
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
