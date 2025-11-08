import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AutoScrollController scrollController;

  const CustomAppBar({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: Responsive.getPadding(context),
          child: Row(
            children: [
              // Logo/Name
              Text(
                AppConstants.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              
              // Navigation Items (Desktop/Tablet)
              if (!Responsive.isMobile(context)) ...[
                ...AppConstants.navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton(
                      onPressed: () => _scrollToSection(index),
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 16),
              ],
              
              // Theme Toggle
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return IconButton(
                    onPressed: themeProvider.toggleTheme,
                    icon: Icon(
                      themeProvider.isDarkMode 
                          ? Icons.light_mode 
                          : Icons.dark_mode,
                    ),
                    tooltip: themeProvider.isDarkMode 
                        ? 'Switch to Light Mode' 
                        : 'Switch to Dark Mode',
                  );
                },
              ),
              
              // Mobile Menu Button
              if (Responsive.isMobile(context))
                IconButton(
                  onPressed: () => _showMobileMenu(context),
                  icon: const Icon(Icons.menu),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToSection(int index) {
    scrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: AppConstants.mediumAnimation,
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Navigation items
            ...AppConstants.navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                title: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToSection(index);
                },
              );
            }),
            
            const SizedBox(height: AppConstants.paddingMedium),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
