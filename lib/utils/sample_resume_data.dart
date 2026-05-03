import '../data/models/resume.dart';

class SampleResumeData {
  static Resume getSampleResume() {
    return Resume(
      id: 'sample',
      template: TemplateType.modern,
      personalInfo: PersonalInfo(
        fullName: 'John Doe',
        title: 'Senior Software Engineer',
        email: 'john.doe@example.com',
        phone: '+1 (555) 123-4567',
        location: 'San Francisco, CA',
        linkedin: 'linkedin.com/in/johndoe',
        portfolio: 'johndoe.dev',
        professionalSummary: 'Experienced software engineer with 8+ years of expertise in full-stack development, cloud architecture, and team leadership.',
      ),
      experience: [
        Experience(
          position: 'Senior Software Engineer',
          company: 'Tech Corp',
          location: 'San Francisco, CA',
          startDate: DateTime(2020, 1),
          endDate: null,
          current: true,
          achievements: [
            'Led development of microservices architecture serving 10M+ users',
            'Reduced system latency by 40% through optimization',
            'Mentored team of 5 junior developers',
            'Implemented CI/CD pipeline reducing deployment time by 60%',
          ],
        ),
        Experience(
          position: 'Software Engineer',
          company: 'StartUp Inc',
          location: 'New York, NY',
          startDate: DateTime(2017, 6),
          endDate: DateTime(2019, 12),
          current: false,
          achievements: [
            'Built RESTful APIs using Node.js and Express',
            'Developed responsive web applications with React',
            'Collaborated with cross-functional teams',
          ],
        ),
        Experience(
          position: 'Junior Developer',
          company: 'Digital Agency',
          location: 'Los Angeles, CA',
          startDate: DateTime(2015, 8),
          endDate: DateTime(2017, 5),
          current: false,
          achievements: [
            'Created custom WordPress themes and plugins',
            'Maintained client websites and fixed bugs',
          ],
        ),
      ],
      education: [
        Education(
          degree: 'Bachelor of Science',
          field: 'Computer Science',
          institution: 'University of California',
          location: 'Berkeley, CA',
          graduationDate: DateTime(2017, 5),
          gpa: '3.8',
        ),
      ],
      skills: [
        Skill(name: 'JavaScript', level: SkillLevel.expert),
        Skill(name: 'Python', level: SkillLevel.advanced),
        Skill(name: 'React', level: SkillLevel.expert),
        Skill(name: 'AWS', level: SkillLevel.advanced),
      ],
      projects: [
        Project(
          name: 'E-Commerce Platform',
          description: 'Built scalable e-commerce platform',
          technologies: 'React, Node.js, AWS',
          link: 'github.com/johndoe/ecommerce',
        ),
      ],
      languages: [
        Language(language: 'English', proficiency: LanguageProficiency.native),
        Language(language: 'Spanish', proficiency: LanguageProficiency.fluent),
        Language(language: 'French', proficiency: LanguageProficiency.conversational),
        Language(language: 'German', proficiency: LanguageProficiency.basic),
      ],
      certifications: [
        Certification(
          name: 'AWS Certified Solutions Architect',
          issuer: 'Amazon Web Services',
          date: DateTime(2022, 3),
          credentialId: 'AWS-12345',
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
