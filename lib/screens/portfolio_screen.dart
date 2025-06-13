import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/certificates_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/footer_section.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(scrollController: _scrollController),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero Section
            AutoScrollTag(
              key: const ValueKey(0),
              controller: _scrollController,
              index: 0,
              child: HeroSection(scrollController: _scrollController),
            ),
            
            // About Section
            AutoScrollTag(
              key: const ValueKey(1),
              controller: _scrollController,
              index: 1,
              child: const AboutSection(),
            ),
            
            // Projects Section
            AutoScrollTag(
              key: const ValueKey(2),
              controller: _scrollController,
              index: 2,
              child: const ProjectsSection(),
            ),
            
            // Certificates Section
            AutoScrollTag(
              key: const ValueKey(3),
              controller: _scrollController,
              index: 3,
              child: const CertificatesSection(),
            ),
            
            // Contact Section
            AutoScrollTag(
              key: const ValueKey(4),
              controller: _scrollController,
              index: 4,
              child: const ContactSection(),
            ),
            
            // Footer Section
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
