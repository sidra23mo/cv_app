import 'dart:ui';

import 'package:flutter/material.dart';

import 'data/models/resume.dart';

class AppConstants {
  // App Info
  static const String appName = 'Professional Resume Builder';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF06B6D4);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  // Templates
  static const Map<TemplateType, Map<String, dynamic>> templates = {
    TemplateType.modern: {
      'name': 'Modern',
      'description': 'Clean, contemporary design for all industries',
      'color': Color(0xFF2563EB),
      'icon': Icons.design_services,
    },
    TemplateType.executive: {
      'name': 'Executive',
      'description': 'Sophisticated design for leadership roles',
      'color': Color(0xFF1E293B),
      'icon': Icons.business_center,
    },
    TemplateType.creative: {
      'name': 'Creative',
      'description': 'Bold gradient design for creative professionals',
      'color': Color(0xFF7C3AED),
      'icon': Icons.palette,
    },
    TemplateType.minimal: {
      'name': 'Minimal',
      'description': 'Ultra-clean design for traditional industries',
      'color': Colors.black,
      'icon': Icons.format_align_left,
    },
    TemplateType.tech: {
      'name': 'Tech',
      'description': 'Dark theme for developers and tech professionals',
      'color': Color(0xFF0F172A),
      'icon': Icons.code,
    },
  };

  // Default resume content
  static const Map<String, dynamic> defaultResumeContent = {
    'personalInfo': {
      'fullName': '',
      'email': '',
      'phone': '',
      'location': '',
      'linkedin': '',
      'portfolio': '',
      'title': '',
      'professionalSummary': '',
    },
    'sections': [
      'Personal Info',
      'Summary',
      'Experience',
      'Education',
      'Skills',
      'Projects',
      'Certifications',
      'Languages',
    ],
  };

  // AI Configuration
  static const Map<String, dynamic> aiConfig = {
    'maxSummaryLength': 500,
    'maxAchievementsPerJob': 5,
    'maxSkills': 15,
    'defaultIndustry': 'Technology',
  };

  // Export Settings
  static const Map<String, dynamic> exportSettings = {
    'defaultFormat': 'pdf',
    'availableFormats': ['pdf', 'txt', 'html'],
    'maxResumeSizeMB': 10,
    'printQuality': 'high',
  };

  // Storage Limits
  static const Map<String, dynamic> storageLimits = {
    'maxResumes': 50,
    'maxResumeSizeKB': 1024,
    'maxImages': 20,
    'maxImageSizeMB': 5,
  };
}