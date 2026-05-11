import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/core/theme/spacing.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    const OnboardingPageData(
      title: 'Welcome to PetFolio',
      description: 'Your all-in-one companion for pet care, health, and social life.',
      image: 'assets/images/onboarding_1.png', // Fallback to icon if missing
      icon: Icons.pets,
    ),
    const OnboardingPageData(
      title: 'Health Tracking',
      description: 'Monitor vitals, vaccinations, and medications with ease.',
      image: 'assets/images/onboarding_2.png',
      icon: Icons.health_and_safety,
    ),
    const OnboardingPageData(
      title: 'Community & Marketplace',
      description: 'Connect with other pet parents and shop for the best products.',
      image: 'assets/images/onboarding_3.png',
      icon: Icons.shopping_bag,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        page.icon,
                        size: 100,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      page.title,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 48,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? colorScheme.primary
                            : colorScheme.primary.withAlpha(50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Skip'),
                    ),
                    const Spacer(),
                    PillButton(
                      onPressed: _onNext,
                      child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });

  final String title;
  final String description;
  final String image;
  final IconData icon;
}
