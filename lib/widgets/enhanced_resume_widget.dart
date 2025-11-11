import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animate_do/animate_do.dart';
import '../services/resume_generator_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';

class EnhancedResumeWidget extends StatefulWidget {
  const EnhancedResumeWidget({super.key});

  @override
  State<EnhancedResumeWidget> createState() => _EnhancedResumeWidgetState();
}

class _EnhancedResumeWidgetState extends State<EnhancedResumeWidget>
    with TickerProviderStateMixin {
  bool _isGenerating = false;
  String _status = '';
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  /// Generate and Download Resume
  Future<void> _generateAndDownload() async {
    setState(() {
      _isGenerating = true;
      _status = 'Generating resume from your portfolio data...';
    });

    try {
      // Generate PDF from Firebase data
      setState(() => _status = 'Fetching your portfolio data...');
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _status = 'Creating professional PDF resume...');
      final pdfBytes = await ResumeGeneratorService
          .generateResumeFromFirebase();

      setState(() => _status = 'Preparing download...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Save/Download PDF
      final filePath = await ResumeGeneratorService.savePDFToDevice(pdfBytes);

      if (filePath != null) {
        setState(() => _status = 'Resume generated successfully! ✅');

        // Show success dialog
        if (mounted) {
          _showSuccessDialog(pdfBytes);
        }
      } else {
        throw Exception('Failed to save PDF');
      }
    } catch (e) {
      setState(() => _status = 'Error generating resume: ${e.toString()}');

      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      setState(() => _isGenerating = false);

      // Clear status after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _status = '');
        }
      });
    }
  }

  /// Preview Resume
  Future<void> _previewResume() async {
    setState(() {
      _isGenerating = true;
      _status = 'Preparing resume preview...';
    });

    try {
      final pdfBytes = await ResumeGeneratorService
          .generateResumeFromFirebase();
      await ResumeGeneratorService.previewPDF(pdfBytes);
      setState(() => _status = 'Preview opened! ✅');
    } catch (e) {
      setState(() => _status = 'Error previewing resume: ${e.toString()}');
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isGenerating = false);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _status = '');
      });
    }
  }

  /// Share Resume
  Future<void> _shareResume() async {
    setState(() {
      _isGenerating = true;
      _status = 'Preparing resume for sharing...';
    });

    try {
      final pdfBytes = await ResumeGeneratorService
          .generateResumeFromFirebase();
      await ResumeGeneratorService.sharePDF(pdfBytes);
      setState(() => _status = 'Sharing options opened! ✅');
    } catch (e) {
      setState(() => _status = 'Error sharing resume: ${e.toString()}');
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isGenerating = false);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _status = '');
      });
    }
  }

  /// Show success dialog with options
  void _showSuccessDialog(Uint8List pdfBytes) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                      Icons.check_circle, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('Resume Generated!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your professional resume has been generated successfully from your portfolio data.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'What would you like to do next?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ResumeGeneratorService.previewPDF(pdfBytes);
                },
                child: const Text('Preview'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ResumeGeneratorService.sharePDF(pdfBytes);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Share'),
              ),
            ],
          ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.error, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('Generation Failed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Unable to generate resume. Please try again.'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                        fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _generateAndDownload();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.accentColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(
                                _glowAnimation.value),
                            AppTheme.accentColor.withOpacity(
                                _glowAnimation.value * 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(
                                _glowAnimation.value * 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Professional Resume',
                        style: AppTheme.headingStyle.copyWith(
                          fontSize: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generated from your portfolio data',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Features List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildFeatureItem(
                    Icons.auto_awesome,
                    'Auto-Generated',
                    'Uses your latest portfolio data',
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    Icons.design_services,
                    'Professional Design',
                    'Clean, ATS-friendly layout',
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    Icons.picture_as_pdf,
                    'PDF Format',
                    'Ready for download & sharing',
                    Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status Display
            if (_status.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _status.contains('Error') || _status.contains('Failed')
                      ? Colors.red.withOpacity(0.1)
                      : _status.contains('✅')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _status.contains('Error') ||
                        _status.contains('Failed')
                        ? Colors.red.withOpacity(0.3)
                        : _status.contains('✅')
                        ? Colors.green.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    if (_isGenerating && !_status.contains('✅') &&
                        !_status.contains('Error'))
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        _status.contains('Error') || _status.contains('Failed')
                            ? Icons.error
                            : _status.contains('✅')
                            ? Icons.check_circle
                            : Icons.info,
                        size: 16,
                        color: _status.contains('Error') ||
                            _status.contains('Failed')
                            ? Colors.red
                            : _status.contains('✅')
                            ? Colors.green
                            : Colors.blue,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _status.contains('Error') || _status.contains(
                              'Failed')
                              ? Colors.red[700]
                              : _status.contains('✅')
                              ? Colors.green[700]
                              : Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            if (Responsive.isMobile(context))
              Column(
                children: [
                  _buildActionButton(
                    onPressed: _isGenerating ? null : _generateAndDownload,
                    icon: Icons.download,
                    label: 'Generate & Download',
                    isPrimary: true,
                    isLoading: _isGenerating,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          onPressed: _isGenerating ? null : _previewResume,
                          icon: Icons.preview,
                          label: 'Preview',
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          onPressed: _isGenerating ? null : _shareResume,
                          icon: Icons.share,
                          label: 'Share',
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildActionButton(
                      onPressed: _isGenerating ? null : _generateAndDownload,
                      icon: Icons.download,
                      label: 'Generate & Download',
                      isPrimary: true,
                      isLoading: _isGenerating,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      onPressed: _isGenerating ? null : _previewResume,
                      icon: Icons.preview,
                      label: 'Preview',
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      onPressed: _isGenerating ? null : _shareResume,
                      icon: Icons.share,
                      label: 'Share',
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle,
      Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppTheme.primaryColor : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppTheme.primaryColor,
          elevation: isPrimary ? 4 : 1,
          side: isPrimary ? null : BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading && isPrimary
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}