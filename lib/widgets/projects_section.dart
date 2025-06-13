import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/project_model.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = AppConstants.sampleProjects
        .map((data) => ProjectModel.fromJson(data))
        .toList();

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppConstants.paddingXLarge * 2,
        horizontal: Responsive.getPadding(context).horizontal,
      ),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade50
          : Colors.grey.shade900,
      child: Column(
        children: [
          _buildSectionTitle(context),
          const SizedBox(height: AppConstants.paddingXLarge),
          _buildProjectsGrid(context, projects),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: AppConstants.mediumAnimation,
      child: SlideAnimation(
        verticalOffset: 30.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              Text(
                'My Projects',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'Here are some of my recent projects that showcase my skills and experience',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsGrid(BuildContext context, List<ProjectModel> projects) {
    final crossAxisCount = Responsive.getCrossAxisCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppConstants.paddingLarge,
          mainAxisSpacing: AppConstants.paddingLarge,
          childAspectRatio: Responsive.isMobile(context) ? 0.8 : 0.75,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: AppConstants.mediumAnimation,
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildProjectCard(context, projects[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project) {
    return Card(
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.phone_android,
                  size: 80,
                  color: Colors.white,
                ),
                // Replace with actual project image:
                // Image.asset(
                //   project.imageUrl,
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            
            // Project Details
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Title
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    
                    // Project Description
                    Expanded(
                      child: Text(
                        project.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Technologies
                    Wrap(
                      spacing: AppConstants.paddingSmall,
                      runSpacing: AppConstants.paddingSmall,
                      children: project.technologies.take(3).map((tech) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                          child: Text(
                            tech,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Action Buttons
                    Row(
                      children: [
                        if (project.liveUrl != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _launchUrl(project.liveUrl!),
                              icon: const Icon(Icons.launch, size: 16),
                              label: const Text('Live'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        if (project.liveUrl != null && project.githubUrl != null)
                          const SizedBox(width: AppConstants.paddingSmall),
                        if (project.githubUrl != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _launchUrl(project.githubUrl!),
                              icon: const FaIcon(FontAwesomeIcons.github, size: 16),
                              label: const Text('Code'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
