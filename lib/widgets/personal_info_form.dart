import 'package:flutter/material.dart';
import '../data/models/resume.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_service.dart';
import '../theme/theme_helper.dart';

class PersonalInfoForm extends StatefulWidget {
  final PersonalInfo personalInfo;
  final ValueChanged<PersonalInfo> onChanged;

  const PersonalInfoForm({
    super.key,
    required this.personalInfo,
    required this.onChanged,
  });

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _linkedinController;
  late TextEditingController _portfolioController;
  late TextEditingController _titleController;
  late TextEditingController _summaryController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant PersonalInfoForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllersWithPersonalInfo(); // 🔥 Sync on widget update
  }

  void _initControllers() {
    _fullNameController = TextEditingController(text: widget.personalInfo.fullName);
    _emailController = TextEditingController(text: widget.personalInfo.email);
    _phoneController = TextEditingController(text: widget.personalInfo.phone);
    _locationController = TextEditingController(text: widget.personalInfo.location);
    _linkedinController = TextEditingController(text: widget.personalInfo.linkedin);
    _portfolioController = TextEditingController(text: widget.personalInfo.portfolio);
    _titleController = TextEditingController(text: widget.personalInfo.title);
    _summaryController = TextEditingController(text: widget.personalInfo.professionalSummary);
  }

  // 🔥 NEW: Sync controller text with latest personalInfo
  void _syncControllersWithPersonalInfo() {
    if (_fullNameController.text != widget.personalInfo.fullName) {
      _fullNameController.text = widget.personalInfo.fullName;
    }
    if (_emailController.text != widget.personalInfo.email) {
      _emailController.text = widget.personalInfo.email;
    }
    if (_phoneController.text != widget.personalInfo.phone) {
      _phoneController.text = widget.personalInfo.phone;
    }
    if (_locationController.text != widget.personalInfo.location) {
      _locationController.text = widget.personalInfo.location;
    }
    if (_linkedinController.text != widget.personalInfo.linkedin) {
      _linkedinController.text = widget.personalInfo.linkedin;
    }
    if (_portfolioController.text != widget.personalInfo.portfolio) {
      _portfolioController.text = widget.personalInfo.portfolio;
    }
    if (_titleController.text != widget.personalInfo.title) {
      _titleController.text = widget.personalInfo.title;
    }
    if (_summaryController.text != widget.personalInfo.professionalSummary) {
      _summaryController.text = widget.personalInfo.professionalSummary;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _updatePersonalInfo() {
    widget.onChanged(
      widget.personalInfo.copyWith(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        location: _locationController.text,
        linkedin: _linkedinController.text,
        portfolio: _portfolioController.text,
        title: _titleController.text,
        professionalSummary: _summaryController.text,
      ),
    );
  }

  Future<void> _generateAISummary() async {
    final l10n = AppLocalizations.of(context);
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('enter_title_first'))),
      );
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
      final summary = await AIService.generateBasicProfessionalSummary(
        fullName: _fullNameController.text,
        title: _titleController.text,
      );
      
      setState(() {
        _summaryController.text = summary;
      });
      _updatePersonalInfo();
      
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
    _syncControllersWithPersonalInfo();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('personal_information'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.translate('fill_contact_info'), style: TextStyle(fontSize: 15, color: ThemeHelper.getSecondaryTextColor(context))),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _fullNameController,
            label: l10n.translate('full_name'),
            hint: 'John Doe',
            icon: Icons.person_outline,
            required: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            label: l10n.translate('email_address'),
            hint: 'john@example.com',
            icon: Icons.email_outlined,
            required: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: l10n.translate('phone'),
                  hint: '+1 234 567 8900',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _locationController,
                  label: l10n.translate('location'),
                  hint: 'San Francisco, CA',
                  icon: Icons.location_on_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _linkedinController,
            label: l10n.translate('linkedin'),
            hint: 'linkedin.com/in/johndoe',
            icon: Icons.link,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _portfolioController,
            label: l10n.translate('portfolio_website'),
            hint: 'github.com/johndoe',
            icon: Icons.language,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _titleController,
            label: l10n.translate('professional_title'),
            hint: 'Senior Software Engineer',
            icon: Icons.work_outline,
            required: true,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Text(l10n.translate('professional_summary'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _generateAISummary,
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
          const SizedBox(height: 12),
          TextField(
            controller: _summaryController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: l10n.translate('write_summary'),
              filled: true,
              fillColor: ThemeHelper.getCardColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ThemeHelper.getBorderColor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ThemeHelper.getBorderColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ThemeHelper.getButtonColor(context), width: 2),
              ),
            ),
            onChanged: (_) => _updatePersonalInfo(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (required) Text(l10n.translate('required_field'), style: const TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: ThemeHelper.getCardColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ThemeHelper.getBorderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ThemeHelper.getBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ThemeHelper.getButtonColor(context), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (_) => _updatePersonalInfo(),
        ),
      ],
    );
  }
}