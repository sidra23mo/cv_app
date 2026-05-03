// lib/data/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:convert'; // 👈 ADD THIS

import '../models/resume.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'resume_builder.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE resumes(
        id TEXT PRIMARY KEY,
        template INTEGER NOT NULL,
        personalInfo TEXT NOT NULL,
        experience TEXT NOT NULL,
        education TEXT NOT NULL,
        skills TEXT NOT NULL,
        projects TEXT NOT NULL,
        certifications TEXT NOT NULL,
        languages TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        fileName TEXT
      )
    ''');
  }

  // 🔹 Helper: Convert Resume to DB-ready map (with JSON strings)
  Map<String, dynamic> _resumeToDbMap(Resume resume) {
    final map = resume.toMap();
    return {
      'id': map['id'],
      'template': map['template'],
      'personalInfo': jsonEncode(map['personalInfo']),
      'experience': jsonEncode(map['experience']),
      'education': jsonEncode(map['education']),
      'skills': jsonEncode(map['skills']),
      'projects': jsonEncode(map['projects']),
      'certifications': jsonEncode(map['certifications']),
      'languages': jsonEncode(map['languages']),
      'createdAt': map['createdAt'],
      'updatedAt': map['updatedAt'],
      'fileName': map['fileName'],
    };
  }

  // 🔹 Helper: Reconstruct Resume from DB row
  Resume _resumeFromDbMap(Map<String, dynamic> row) {
    return Resume(
      id: row['id'],
      template: TemplateType.values[row['template']],
      personalInfo: PersonalInfo.fromMap(jsonDecode(row['personalInfo']) as Map<String, dynamic>),
      experience: (jsonDecode(row['experience']) as List<dynamic>)
          .map((e) => Experience.fromMap(e as Map<String, dynamic>))
          .toList(),
      education: (jsonDecode(row['education']) as List<dynamic>)
          .map((e) => Education.fromMap(e as Map<String, dynamic>))
          .toList(),
      skills: (jsonDecode(row['skills']) as List<dynamic>)
          .map((s) => Skill.fromMap(s as Map<String, dynamic>))
          .toList(),
      projects: (jsonDecode(row['projects']) as List<dynamic>)
          .map((p) => Project.fromMap(p as Map<String, dynamic>))
          .toList(),
      certifications: (jsonDecode(row['certifications']) as List<dynamic>)
          .map((c) => Certification.fromMap(c as Map<String, dynamic>))
          .toList(),
      languages: (jsonDecode(row['languages']) as List<dynamic>)
          .map((l) => Language.fromMap(l as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(row['createdAt']),
      updatedAt: DateTime.parse(row['updatedAt']),
      fileName: row['fileName'],
    );
  }

  // Resume CRUD operations
  Future<int> insertResume(Resume resume) async {
    final db = await database;
    return await db.insert(
      'resumes',
      _resumeToDbMap(resume),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Resume>> getAllResumes() async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query('resumes');
    return rows.map((row) => _resumeFromDbMap(row)).toList();
  }

  Future<Resume?> getResume(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      'resumes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isNotEmpty) {
      return _resumeFromDbMap(rows.first);
    }
    return null;
  }

  Future<int> updateResume(Resume resume) async {
    final db = await database;
    return await db.update(
      'resumes',
      _resumeToDbMap(resume.copyWith(updatedAt: DateTime.now())),
      where: 'id = ?',
      whereArgs: [resume.id],
    );
  }

  Future<int> deleteResume(String id) async {
    final db = await database;
    return await db.delete(
      'resumes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllResumes() async {
    final db = await database;
    return await db.delete('resumes');
  }
}