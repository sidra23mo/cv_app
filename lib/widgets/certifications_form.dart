import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/resume.dart';
import '../theme/theme_helper.dart';
import '../l10n/app_localizations.dart';

class CertificationsForm extends StatefulWidget {
  final List<Certification> certifications;
  final ValueChanged<Certification> onAdd;
  final ValueChanged<Certification> onUpdate;
  final ValueChanged<String> onRemove;

  const CertificationsForm({
    super.key,
    required this.certifications,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<CertificationsForm> createState() => _CertificationsFormState();
}

class _CertificationsFormState extends State<CertificationsForm> {
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _issuerControllers = [];
  final List<DateTime?> _dates = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant CertificationsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _initControllers() {
    _nameControllers.clear();
    _issuerControllers.clear();
    _dates.clear();
    for (var cert in widget.certifications) {
      _nameControllers.add(TextEditingController(text: cert.name));
      _issuerControllers.add(TextEditingController(text: cert.issuer));
      _dates.add(cert.date);
    }
  }

  void _syncControllers() {
    if (widget.certifications.length != _nameControllers.length) {
      for (var c in _nameControllers) c.dispose();
      for (var c in _issuerControllers) c.dispose();
      _initControllers();
    }
  }

  @override
  void dispose() {
    for (var c in _nameControllers) c.dispose();
    for (var c in _issuerControllers) c.dispose();
    super.dispose();
  }

  void _addNew() => widget.onAdd(Certification.empty());

  void _update(int i) {
    widget.onUpdate(Certification(
      id: widget.certifications[i].id,
      name: _nameControllers[i].text,
      issuer: _issuerControllers[i].text,
      date: _dates[i] ?? DateTime.now(),
      credentialId: widget.certifications[i].credentialId,
    ));
  }

  Future<void> _pickDate(int i) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dates[i] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _dates[i] = date);
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
          Text(l10n.translate('certifications'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.translate('add_certifications_licenses'), style: TextStyle(fontSize: 15, color: ThemeHelper.getSecondaryTextColor(context))),
          const SizedBox(height: 32),
          if (widget.certifications.isEmpty)
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
                    Icon(Icons.verified_outlined, size: 48, color: ThemeHelper.getSecondaryTextColor(context)),
                    const SizedBox(height: 16),
                    Text(l10n.translate('no_certifications_added'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(l10n.translate('click_add_certifications'), style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context))),
                  ],
                ),
              ),
            )
          else
            ...widget.certifications.asMap().entries.map((e) => _buildCard(e.key)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNew,
              icon: const Icon(Icons.add),
              label: Text(l10n.translate('add_certification')),
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
              Text('${l10n.translate('certification_name')} ${i + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => widget.onRemove(widget.certifications[i].id ?? ''),
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(l10n.translate('certification_name'), _nameControllers[i], l10n.translate('certification_name'), i),
          const SizedBox(height: 16),
          _buildField(l10n.translate('issuing_org'), _issuerControllers[i], l10n.translate('issuing_org'), i),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('issue_date'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                      Text(_dates[i] != null ? DateFormat('MMM yyyy').format(_dates[i]!) : l10n.translate('select_date')),
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
