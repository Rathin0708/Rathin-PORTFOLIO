import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../models/user_analytics_model.dart';
import '../../utils/app_theme.dart';
import 'users_management_screen.dart';
import 'skills_management_screen.dart';
import 'certificates_management_screen.dart';
import 'contacts_management_screen.dart';
import 'app_settings_screen.dart';
import 'profile_management_screen.dart';
import 'about_management_screen.dart';
import 'projects_management_screen.dart';
import '../portfolio_screen.dart';
import 'local_profile_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  UserAnalytics? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAnalytics();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  Future<void> _loadAnalytics() async {
    try {
      print('🔍 Loading analytics for admin dashboard...');
      print('🔐 Current user: ${AdminService.currentUser?.email}');
      print('🛡️ Is admin: ${AdminService.isAdmin()}');

      final analytics = await AdminService.getUserAnalytics();
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });

      print('✅ Analytics loaded successfully');
    } catch (e) {
      print('❌ Error loading analytics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.accentColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildDashboardContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0), // Reduced from 24 to 16
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 24), // Reduced from 32 to 24
                      _buildAnalyticsCards(),
                      const SizedBox(height: 24), // Reduced from 32 to 24
                      _buildQuickActions(),
                      const SizedBox(height: 24), // Reduced from 32 to 24
                      _buildManagementSections(),
                      const SizedBox(height: 24), // Added bottom padding
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          FadeInLeft(
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.accentColor],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Dashboard',
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: 24,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'Portfolio Management System',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FadeInRight(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 400),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PortfolioScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  tooltip: 'View Portfolio',
                ),
                const SizedBox(width: 8),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return IconButton(
                      onPressed: () async {
                        await authProvider.signOut();
                      },
                      icon: const Icon(Icons.logout),
                      tooltip: 'Sign Out',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.accentColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Rathin! 👋',
                    style: AppTheme.headingStyle.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your portfolio, users, and content from this dashboard.',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.dashboard,
              size: 60,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    if (_analytics == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 800),
          child: Text(
            'Analytics Overview',
            style: AppTheme.headingStyle.copyWith(
              fontSize: 20,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2, // Increased from 1.8 to 2.2 to reduce height further
          children: [
            _buildAnalyticsCard(
              'Total Users',
              _analytics!.totalUsers.toString(),
              Icons.people,
              Colors.blue,
              delay: 1000,
            ),
            _buildAnalyticsCard(
              'Total Contacts',
              _analytics!.totalContacts.toString(),
              Icons.contact_mail,
              Colors.green,
              delay: 1200,
            ),
            _buildAnalyticsCard(
              'Google Users',
              '${_analytics!.googleUsers} (${_analytics!.googleUserPercentage.toStringAsFixed(1)}%)',
              Icons.g_mobiledata,
              Colors.red,
              delay: 1400,
            ),
            _buildAnalyticsCard(
              'Recent Activity',
              '${_analytics!.recentUsers} users, ${_analytics!.recentContacts} contacts',
              Icons.trending_up,
              Colors.orange,
              delay: 1600,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
    {int delay = 0}
  ) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: Duration(milliseconds: delay),
      child: Container(
        padding: const EdgeInsets.all(12), // Reduced from 20 to 12
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Reduced from 8 to 6
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16), // Reduced from 20 to 16
                ),
                const Spacer(),
                Icon(Icons.more_vert, color: Colors.grey[400], size: 14), // Reduced from 16 to 14
              ],
            ),
            const SizedBox(height: 8), // Reduced from 12 to 8
            Flexible( // Added Flexible to prevent overflow
              child: Text(
                title,
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10, // Reduced from 12 to 10
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2), // Reduced from 4 to 2
            Flexible( // Added Flexible to prevent overflow
              child: Text(
                value,
                style: AppTheme.headingStyle.copyWith(
                  fontSize: 14, // Reduced from 16 to 14
                  color: AppTheme.primaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 1800),
          child: Text(
            'Quick Actions',
            style: AppTheme.headingStyle.copyWith(
              fontSize: 20,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                'Add Skill',
                Icons.add_circle,
                Colors.blue,
                () => _navigateToSkillsManagement(),
                delay: 2000,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionButton(
                'Add Certificate',
                Icons.card_membership,
                Colors.green,
                () => _navigateToCertificatesManagement(),
                delay: 2200,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    {int delay = 0}
  ) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16), // Reduced from 20 to 16
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20), // Reduced from 24 to 20
              ),
              const SizedBox(height: 8), // Reduced from 12 to 8
              Flexible( // Added Flexible to prevent overflow
                child: Text(
                  title,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    fontSize: 12, // Added explicit font size
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 2400),
          child: Text(
            'Management Sections',
            style: AppTheme.headingStyle.copyWith(
              fontSize: 20,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          // Changed from 2 to 3 for better layout
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          // Adjusted for 3-column layout
          children: [
            _buildManagementCard(
              'Users',
              'Manage user accounts',
              Icons.people_outline,
              Colors.blue,
              () => _navigateToUsersManagement(),
              delay: 2600,
            ),
            _buildManagementCard(
              'Skills',
              'Add & edit skills',
              Icons.star_outline,
              Colors.orange,
              () => _navigateToSkillsManagement(),
              delay: 2800,
            ),
            _buildManagementCard(
              'Certificates',
              'Manage certificates',
              Icons.card_membership_outlined,
              Colors.green,
              () => _navigateToCertificatesManagement(),
              delay: 3000,
            ),
            _buildManagementCard(
              'Contacts',
              'View messages',
              Icons.contact_mail_outlined,
              Colors.purple,
              () => _navigateToContactsManagement(),
              delay: 3200,
            ),
            _buildManagementCard(
              'About',
              'Manage about section',
              Icons.info,
              Colors.pink,
                  () => _navigateToAboutManagement(),
              delay: 3400,
            ),
            _buildManagementCard(
              'Profile',
              'Manage profile section',
              Icons.person,
              Colors.teal,
                  () => _navigateToProfileManagement(),
              delay: 3600,
            ),
            _buildManagementCard(
              'Projects',
              'Manage projects section',
              Icons.folder,
              Colors.brown,
                  () => _navigateToProjectsManagement(),
              delay: 3800,
            ),
            _buildManagementCard(
              'Local Profile',
              'Manage local profile',
              Icons.account_circle,
              Colors.purple,
                  () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (
                          context) => const LocalProfileManagementScreen(),
                    ),
                  ),
              delay: 4000,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    {int delay = 0}
  ) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12), // Reduced from 20 to 12
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced from 12 to 8
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20), // Reduced from 24 to 20
              ),
              const SizedBox(height: 8), // Reduced from 16 to 8
              Flexible( // Added Flexible to prevent overflow
                child: Text(
                  title,
                  style: AppTheme.headingStyle.copyWith(
                    fontSize: 14, // Reduced from 16 to 14
                    color: AppTheme.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2), // Reduced from 4 to 2
              Flexible( // Added Flexible to prevent overflow
                child: Text(
                  subtitle,
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.grey[600],
                    fontSize: 10, // Reduced from 12 to 10
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToUsersManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsersManagementScreen(),
      ),
    );
  }

  void _navigateToSkillsManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SkillsManagementScreen(),
      ),
    );
  }

  void _navigateToCertificatesManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CertificatesManagementScreen(),
      ),
    );
  }

  void _navigateToContactsManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactsManagementScreen(),
      ),
    );
  }

  void _navigateToAboutManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutManagementScreen(),
      ),
    );
  }

  void _navigateToProfileManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileManagementScreen(),
      ),
    );
  }

  void _navigateToProjectsManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectsManagementScreen(),
      ),
    );
  }

  void _navigateToAppSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppSettingsScreen(),
      ),
    );
  }
}
