import 'package:flutter/material.dart';
import '../data/models/resume.dart';

class TemplateCard extends StatelessWidget {
  final TemplateType templateType;
  final String name;
  final String description;
  final Color color;
  final String bestFor;
  final VoidCallback onTap;
  final bool isSelected; // Add selection state

  const TemplateCard({
    super.key,
    required this.templateType,
    required this.name,
    required this.description,
    required this.color,
    required this.bestFor,
    required this.onTap,
    this.isSelected = false, // Default to not selected
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final descriptionColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.15 : 0.08),
              blurRadius: isSelected ? 30 : 20,
              spreadRadius: isSelected ? 2 : 1,
              offset: Offset(0, isSelected ? 10 : 5),
            ),
          ],
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Preview Header with Gradient
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: isSelected
                    ? Border(
                  bottom: BorderSide(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                )
                    : null,
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Template Icon Container
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            _darkenColor(color, 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _getTemplateIcon(templateType),
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),

                  // Selected Badge
                  if (isSelected)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outlined,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Selected',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Template Information
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template Name and Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getTemplateTypeLabel(templateType),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getDifficultyLabel(templateType),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: descriptionColor,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Best For Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_outline,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Best For',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                bestFor,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Quick Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        Icons.people_outline,
                        _getSuitability(templateType),
                        color,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      _buildStatItem(
                        Icons.style_outlined,
                        _getStyle(templateType),
                        color,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      _buildStatItem(
                        Icons.timeline_outlined,
                        _getPopularity(templateType),
                        color,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Select Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.05)
                    : (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.arrow_forward_outlined,
                    color: isSelected ? color : descriptionColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSelected ? 'Currently Selected' : 'Select Template',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : textColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: color.withOpacity(0.7),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getTemplateIcon(TemplateType type) {
    switch (type) {
      case TemplateType.modern:
        return Icons.design_services_outlined;
      case TemplateType.executive:
        return Icons.business_center_outlined;
      case TemplateType.creative:
        return Icons.brush_outlined;
      case TemplateType.minimal:
        return Icons.format_clear_outlined;
      case TemplateType.tech:
        return Icons.code_outlined;
    }
  }

  String _getTemplateTypeLabel(TemplateType type) {
    switch (type) {
      case TemplateType.modern:
        return 'Modern Design';
      case TemplateType.executive:
        return 'Executive Style';
      case TemplateType.creative:
        return 'Creative Layout';
      case TemplateType.minimal:
        return 'Minimal Design';
      case TemplateType.tech:
        return 'Technical Template';
    }
  }

  String _getDifficultyLabel(TemplateType type) {
    switch (type) {
      case TemplateType.modern:
        return 'EASY';
      case TemplateType.executive:
        return 'MEDIUM';
      case TemplateType.creative:
        return 'ADVANCED';
      case TemplateType.minimal:
        return 'EASY';
      case TemplateType.tech:
        return 'MEDIUM';
    }
  }

  String _getSuitability(TemplateType type) {
    switch (type) {
      case TemplateType.modern:
        return 'General';
      case TemplateType.executive:
        return 'Executive';
      case TemplateType.creative:
        return 'Creative';
      case TemplateType.minimal:
        return 'All Roles';
      case TemplateType.tech:
        return 'Tech Roles';
    }
  }

  String _getStyle(TemplateType type) {
    switch (type) {
      case TemplateType.modern:
        return 'Clean';
      case TemplateType.executive:
        return 'Formal';
      case TemplateType.creative:
        return 'Visual';
      case TemplateType.minimal:
        return 'Simple';
      case TemplateType.tech:
        return 'Technical';
    }
  }

  String _getPopularity(TemplateType type) {
    switch (type) {
      case TemplateType.modern:
        return '80%';
      case TemplateType.executive:
        return '65%';
      case TemplateType.creative:
        return '45%';
      case TemplateType.minimal:
        return '75%';
      case TemplateType.tech:
        return '60%';
    }
  }

  Color _darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}