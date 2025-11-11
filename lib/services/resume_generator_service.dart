import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resume_model.dart';
import '../utils/constants.dart';

class ResumeGeneratorService {
  static const String _collection = 'resume_data';

  /// Generate PDF resume from Firebase data
  static Future<Uint8List> generateResumeFromFirebase() async {
    try {
      print('🚀 Starting resume generation from Firebase data...');

      // Get resume data from Firebase
      final resumeData = await _getResumeDataFromFirebase();

      // Generate PDF
      final pdfBytes = await _generatePDF(resumeData);

      print('✅ Resume PDF generated successfully');
      return pdfBytes;
    } catch (e) {
      print('❌ Error generating resume: $e');
      rethrow;
    }
  }

  /// Get resume data from Firebase collections
  static Future<ResumeModel> _getResumeDataFromFirebase() async {
    try {
      print('📊 Fetching resume data from Firebase...');

      // Get profile data
      final profileDoc = await FirebaseFirestore.instance
          .collection('portfolio_settings')
          .doc('profile')
          .get();

      // Get about data
      final aboutDoc = await FirebaseFirestore.instance
          .collection('portfolio_settings')
          .doc('about')
          .get();

      // Get projects data
      final projectsSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .orderBy('createdAt', descending: true)
          .limit(6) // Top 6 projects for resume
          .get();

      // Get certificates data
      final certificatesSnapshot = await FirebaseFirestore.instance
          .collection('certificates')
          .orderBy('completionDate', descending: true)
          .limit(8) // Top 8 certificates
          .get();

      // Get skills data
      final skillsSnapshot = await FirebaseFirestore.instance
          .collection('skills')
          .orderBy('proficiency', descending: true)
          .get();

      // Extract data
      final profileData = profileDoc.exists ? profileDoc.data()! : <
          String,
          dynamic>{};
      final aboutData = aboutDoc.exists ? aboutDoc.data()! : <String, dynamic>{
      };

      // Build PersonalInfo
      final personalInfo = PersonalInfo(
        name: profileData['name'] ?? AppConstants.name,
        email: profileData['email'] ?? AppConstants.email,
        phone: profileData['phone'] ?? AppConstants.phone,
        location: profileData['location'] ?? AppConstants.location,
        website: 'https://rathin-portfolio.web.app',
        // Your portfolio website
        linkedin: _extractSocialLink('LinkedIn', AppConstants.socialLinks),
        github: _extractSocialLink('GitHub', AppConstants.socialLinks),
        profileImage: profileData['profileImage'],
      );

      // Build Projects list
      final projects = projectsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Project(
          id: doc.id,
          name: data['title'] ?? '',
          description: data['description'] ?? '',
          technologies: List<String>.from(data['technologies'] ?? []),
          githubUrl: data['githubUrl'],
          liveUrl: data['liveUrl'],
          completedDate: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
          features: List<String>.from(data['features'] ?? []),
        );
      }).toList();

      // Build Certificates list
      final certificates = certificatesSnapshot.docs.map((doc) {
        final data = doc.data();
        return Certificate(
          id: doc.id,
          name: data['title'] ?? '',
          organization: data['organization'] ?? '',
          issueDate: data['completionDate'] != null
              ? (data['completionDate'] as Timestamp).toDate()
              : DateTime.now(),
          credentialId: data['credentialId'],
          credentialUrl: data['credentialUrl'],
        );
      }).toList();

      // Build Skills list
      final skills = skillsSnapshot.docs
          .map((doc) => doc.data()['name'] as String? ?? '')
          .where((skill) => skill.isNotEmpty)
          .toList();

      // Create sample experience and education (you can extend this to fetch from Firebase)
      final experiences = [
        Experience(
          id: '1',
          company: 'Freelance',
          position: 'Flutter Developer',
          location: 'Remote',
          startDate: DateTime(2023, 1, 1),
          isCurrentRole: true,
          description: 'Developing cross-platform mobile and web applications using Flutter framework.',
          achievements: [
            'Built 10+ production-ready Flutter applications',
            'Implemented Firebase backend integrations',
            'Created responsive UI/UX designs',
            'Delivered projects with 99.9% uptime',
          ],
        ),
      ];

      final educations = [
        Education(
          id: '1',
          institution: 'Your University',
          degree: 'Bachelor of Technology',
          fieldOfStudy: 'Computer Science and Engineering',
          location: 'Chennai, India',
          startDate: DateTime(2020, 6, 1),
          endDate: DateTime(2024, 5, 30),
          achievements: [
            'Specialized in Mobile App Development',
            'Active in coding competitions',
            'Led technical projects team',
          ],
        ),
      ];

      final languages = [
        Language(name: 'English', proficiency: 'Fluent'),
        Language(name: 'Tamil', proficiency: 'Native'),
        Language(name: 'Hindi', proficiency: 'Intermediate'),
      ];

      final interests = [
        'Mobile App Development',
        'UI/UX Design',
        'Open Source Contributing',
        'Tech Blogging',
        'Photography',
      ];

      final resumeModel = ResumeModel(
        personalInfo: personalInfo,
        summary: aboutData['bio'] ?? AppConstants.bio,
        experiences: experiences,
        educations: educations,
        skills: skills.isNotEmpty ? skills : AppConstants.skills,
        projects: projects,
        certificates: certificates,
        languages: languages,
        interests: interests,
      );

      print('✅ Resume data fetched successfully');
      return resumeModel;
    } catch (e) {
      print('❌ Error fetching resume data: $e');
      rethrow;
    }
  }

  /// Extract social media link by platform name
  static String? _extractSocialLink(String platform,
      List<dynamic> socialLinks) {
    try {
      final link = socialLinks.firstWhere(
            (social) =>
        social.platform?.toString().toLowerCase() == platform.toLowerCase(),
        orElse: () => null,
      );
      return link?.url;
    } catch (e) {
      return null;
    }
  }

  /// Generate PDF document
  static Future<Uint8List> _generatePDF(ResumeModel resume) async {
    final pdf = pw.Document();

    // Load fonts
    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();
    final mediumFont = await PdfGoogleFonts.interMedium();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header Section
            _buildHeader(resume.personalInfo, boldFont, regularFont),
            pw.SizedBox(height: 20),

            // Summary Section
            if (resume.summary.isNotEmpty) ...[
              _buildSectionTitle('PROFESSIONAL SUMMARY', boldFont),
              pw.SizedBox(height: 8),
              _buildSummary(resume.summary, regularFont),
              pw.SizedBox(height: 20),
            ],

            // Experience Section
            if (resume.experiences.isNotEmpty) ...[
              _buildSectionTitle('WORK EXPERIENCE', boldFont),
              pw.SizedBox(height: 8),
              ...resume.experiences.map((exp) =>
                  _buildExperience(exp, boldFont, mediumFont, regularFont)),
              pw.SizedBox(height: 20),
            ],

            // Education Section
            if (resume.educations.isNotEmpty) ...[
              _buildSectionTitle('EDUCATION', boldFont),
              pw.SizedBox(height: 8),
              ...resume.educations.map((edu) =>
                  _buildEducation(edu, boldFont, mediumFont, regularFont)),
              pw.SizedBox(height: 20),
            ],

            // Skills Section
            if (resume.skills.isNotEmpty) ...[
              _buildSectionTitle('TECHNICAL SKILLS', boldFont),
              pw.SizedBox(height: 8),
              _buildSkills(resume.skills, regularFont),
              pw.SizedBox(height: 20),
            ],

            // Projects Section
            if (resume.projects.isNotEmpty) ...[
              _buildSectionTitle('KEY PROJECTS', boldFont),
              pw.SizedBox(height: 8),
              ...resume.projects.take(4).map((project) =>
                  _buildProject(project, boldFont, mediumFont, regularFont)),
              pw.SizedBox(height: 20),
            ],

            // Certificates Section
            if (resume.certificates.isNotEmpty) ...[
              _buildSectionTitle('CERTIFICATIONS', boldFont),
              pw.SizedBox(height: 8),
              _buildCertificates(
                  resume.certificates.take(6).toList(), regularFont,
                  mediumFont),
              pw.SizedBox(height: 20),
            ],

            // Languages Section
            if (resume.languages.isNotEmpty) ...[
              _buildSectionTitle('LANGUAGES', boldFont),
              pw.SizedBox(height: 8),
              _buildLanguages(resume.languages, regularFont),
              pw.SizedBox(height: 15),
            ],

            // Interests Section
            if (resume.interests.isNotEmpty) ...[
              _buildSectionTitle('INTERESTS', boldFont),
              pw.SizedBox(height: 8),
              _buildInterests(resume.interests, regularFont),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Build header section with personal info
  static pw.Widget _buildHeader(PersonalInfo info, pw.Font boldFont,
      pw.Font regularFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Name
        pw.Text(
          info.name.toUpperCase(),
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 24,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 4),

        // Contact Info Row
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('📧 ${info.email}',
                      style: pw.TextStyle(font: regularFont, fontSize: 10)),
                  pw.Text('📱 ${info.phone}',
                      style: pw.TextStyle(font: regularFont, fontSize: 10)),
                  pw.Text('📍 ${info.location}',
                      style: pw.TextStyle(font: regularFont, fontSize: 10)),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (info.linkedin != null)
                    pw.Text('💼 LinkedIn: ${info.linkedin}',
                        style: pw.TextStyle(font: regularFont, fontSize: 10)),
                  if (info.github != null)
                    pw.Text('🔗 GitHub: ${info.github}',
                        style: pw.TextStyle(font: regularFont, fontSize: 10)),
                  if (info.website != null)
                    pw.Text('🌐 Portfolio: ${info.website}',
                        style: pw.TextStyle(font: regularFont, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),

        // Divider
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 10),
          height: 2,
          color: PdfColors.blue800,
        ),
      ],
    );
  }

  /// Build section title
  static pw.Widget _buildSectionTitle(String title, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.blue800, width: 1)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 14,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  /// Build summary section
  static pw.Widget _buildSummary(String summary, pw.Font regularFont) {
    return pw.Text(
      summary,
      style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.4),
      textAlign: pw.TextAlign.justify,
    );
  }

  /// Build experience entry
  static pw.Widget _buildExperience(Experience exp, pw.Font boldFont,
      pw.Font mediumFont, pw.Font regularFont) {
    final dateFormat = DateFormat('MMM yyyy');
    final startDate = dateFormat.format(exp.startDate);
    final endDate = exp.endDate != null
        ? dateFormat.format(exp.endDate!)
        : 'Present';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Company and Position
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(exp.position,
                        style: pw.TextStyle(font: mediumFont, fontSize: 12)),
                    pw.Text(exp.company, style: pw.TextStyle(font: boldFont,
                        fontSize: 11,
                        color: PdfColors.blue800)),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('$startDate - $endDate',
                      style: pw.TextStyle(font: regularFont, fontSize: 10)),
                  pw.Text(exp.location,
                      style: pw.TextStyle(font: regularFont, fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 4),

          // Description
          pw.Text(exp.description, style: pw.TextStyle(
              font: regularFont, fontSize: 10, height: 1.3)),

          // Achievements
          if (exp.achievements.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            ...exp.achievements.map((achievement) =>
                pw.Container(
                  margin: const pw.EdgeInsets.only(left: 10, bottom: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ',
                          style: pw.TextStyle(font: regularFont, fontSize: 10)),
                      pw.Expanded(
                        child: pw.Text(achievement, style: pw.TextStyle(
                            font: regularFont, fontSize: 10, height: 1.3)),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  /// Build education entry
  static pw.Widget _buildEducation(Education edu, pw.Font boldFont,
      pw.Font mediumFont, pw.Font regularFont) {
    final dateFormat = DateFormat('MMM yyyy');
    final startDate = dateFormat.format(edu.startDate);
    final endDate = edu.endDate != null
        ? dateFormat.format(edu.endDate!)
        : 'Present';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${edu.degree} in ${edu.fieldOfStudy}',
                        style: pw.TextStyle(font: mediumFont, fontSize: 12)),
                    pw.Text(edu.institution, style: pw.TextStyle(font: boldFont,
                        fontSize: 11,
                        color: PdfColors.blue800)),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('$startDate - $endDate',
                      style: pw.TextStyle(font: regularFont, fontSize: 10)),
                  pw.Text(edu.location,
                      style: pw.TextStyle(font: regularFont, fontSize: 10)),
                ],
              ),
            ],
          ),

          if (edu.gpa != null) ...[
            pw.SizedBox(height: 4),
            pw.Text('GPA: ${edu.gpa}',
                style: pw.TextStyle(font: regularFont, fontSize: 10)),
          ],

          if (edu.achievements.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            ...edu.achievements.map((achievement) =>
                pw.Container(
                  margin: const pw.EdgeInsets.only(left: 10, bottom: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ',
                          style: pw.TextStyle(font: regularFont, fontSize: 10)),
                      pw.Expanded(
                        child: pw.Text(achievement, style: pw.TextStyle(
                            font: regularFont, fontSize: 10)),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  /// Build skills section
  static pw.Widget _buildSkills(List<String> skills, pw.Font regularFont) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 4,
      children: skills.map((skill) =>
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Text(
                skill, style: pw.TextStyle(font: regularFont, fontSize: 9)),
          )).toList(),
    );
  }

  /// Build project entry
  static pw.Widget _buildProject(Project project, pw.Font boldFont,
      pw.Font mediumFont, pw.Font regularFont) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Project name and links
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(project.name,
                    style: pw.TextStyle(font: mediumFont, fontSize: 11)),
              ),
              if (project.githubUrl != null || project.liveUrl != null)
                pw.Text(
                  [
                    if (project.githubUrl != null) 'GitHub',
                    if (project.liveUrl != null) 'Live Demo',
                  ].join(' | '),
                  style: pw.TextStyle(
                      font: regularFont, fontSize: 9, color: PdfColors.blue800),
                ),
            ],
          ),
          pw.SizedBox(height: 3),

          // Description
          pw.Text(project.description, style: pw.TextStyle(
              font: regularFont, fontSize: 10, height: 1.3)),

          // Technologies
          if (project.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Technologies: ${project.technologies.join(', ')}',
              style: pw.TextStyle(
                  font: regularFont, fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  /// Build certificates section
  static pw.Widget _buildCertificates(List<Certificate> certificates,
      pw.Font regularFont, pw.Font mediumFont) {
    return pw.Column(
      children: certificates.map((cert) {
        final dateFormat = DateFormat('MMM yyyy');
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(cert.name,
                        style: pw.TextStyle(font: mediumFont, fontSize: 10)),
                    pw.Text(cert.organization,
                        style: pw.TextStyle(font: regularFont, fontSize: 9)),
                  ],
                ),
              ),
              pw.Text(
                dateFormat.format(cert.issueDate),
                style: pw.TextStyle(font: regularFont, fontSize: 9),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build languages section
  static pw.Widget _buildLanguages(List<Language> languages,
      pw.Font regularFont) {
    return pw.Wrap(
      spacing: 15,
      runSpacing: 4,
      children: languages.map((lang) =>
          pw.Text(
            '${lang.name} (${lang.proficiency})',
            style: pw.TextStyle(font: regularFont, fontSize: 10),
          )).toList(),
    );
  }

  /// Build interests section
  static pw.Widget _buildInterests(List<String> interests,
      pw.Font regularFont) {
    return pw.Text(
      interests.join(' • '),
      style: pw.TextStyle(font: regularFont, fontSize: 10),
    );
  }

  /// Save PDF to device storage (Mobile)
  static Future<String?> savePDFToDevice(Uint8List pdfBytes) async {
    try {
      if (kIsWeb) {
        // For web, download directly
        await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdfBytes);
        return 'Downloaded via browser';
      } else {
        // For mobile/desktop, save to documents
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final fileName = 'Rathin_Resume_$timestamp.pdf';
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        print('✅ Resume saved to: $filePath');
        return filePath;
      }
    } catch (e) {
      print('❌ Error saving PDF: $e');
      return null;
    }
  }

  /// Share PDF (uses printing package)
  static Future<void> sharePDF(Uint8List pdfBytes) async {
    try {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Rathin_Resume_${DateFormat('yyyyMMdd').format(
            DateTime.now())}.pdf',
      );
    } catch (e) {
      print('❌ Error sharing PDF: $e');
      rethrow;
    }
  }

  /// Preview PDF (uses printing package)
  static Future<void> previewPDF(Uint8List pdfBytes) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Rathin Resume Preview',
      );
    } catch (e) {
      print('❌ Error previewing PDF: $e');
      rethrow;
    }
  }

  /// Save resume data to Firebase (for admin)
  static Future<void> saveResumeData(ResumeModel resume) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc('current_resume')
          .set(resume.toJson());

      print('✅ Resume data saved to Firebase');
    } catch (e) {
      print('❌ Error saving resume data: $e');
      rethrow;
    }
  }

  /// Get saved resume data from Firebase
  static Future<ResumeModel?> getSavedResumeData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc('current_resume')
          .get();

      if (doc.exists) {
        return ResumeModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting resume data: $e');
      return null;
    }
  }
}