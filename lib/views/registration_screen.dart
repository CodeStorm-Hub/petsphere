import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/auth_controller.dart';


class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      ref.read(authProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the terms and conditions.'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
// //     final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dark theme background (no light dot grid)
          Container(color: theme.scaffoldBackgroundColor),
          // Subtle ambient blur orbs using theme colors
          Positioned(
            top: 80,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withAlpha(13),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withAlpha(13),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            Icon(Icons.arrow_back, color: colorScheme.primary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'PetSphere',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Visual anchor
                            Text(
                              'Create Account',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Join our community of mindful pet companions\nand nurturing homes.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Social proof badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F3ED),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  ...List.generate(
                                      3,
                                      (i) => Align(
                                            widthFactor: i == 0 ? 1 : 0.65,
                                            child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: [
                                                const Color(0xFFFFE087),
                                                colorScheme.secondaryContainer,
                                                colorScheme.tertiaryContainer,
                                              ][i],
                                              child: Icon(
                                                Icons.pets,
                                                size: 13,
                                                color: [
                                                  const Color(0xFF745C00),
                                                  colorScheme.onSecondaryContainer,
                                                  colorScheme.onTertiaryContainer,
                                                ][i],
                                              ),
                                            ),
                                          )),
                                  const SizedBox(width: 12),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontSize: 13),
                                      children: [
                                        TextSpan(
                                          text: 'Join 2,400+ ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.onSurface),
                                        ),
                                        TextSpan(
                                          text:
                                              'pet lovers already\nnurturing their best lives.',
                                          style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            if (authState.error != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      colorScheme.errorContainer.withAlpha(30),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.error.withAlpha(40),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: colorScheme.error, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authState.error!,
                                        style: TextStyle(
                                            color: colorScheme.error,
                                            fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline,
                                    color: colorScheme.onSurfaceVariant),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter name'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: colorScheme.onSurfaceVariant),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter email';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: colorScheme.onSurfaceVariant),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setState(() =>
                                        _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _register(),
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: colorScheme.onSurfaceVariant),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setState(() =>
                                        _obscureConfirm = !_obscureConfirm);
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (val) {
                                    setState(() {
                                      _agreeToTerms = val ?? false;
                                    });
                                  },
                                  activeColor: colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant),
                                      children: [
                                        TextSpan(
                                          text: 'I agree to the ',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => setState(() =>
                                                _agreeToTerms = !_agreeToTerms),
                                        ),
                                        TextSpan(
                                          text: 'Terms',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => launchUrl(Uri.parse(
                                                'https://petsphere.app/terms')),
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => launchUrl(Uri.parse(
                                                'https://petsphere.app/privacy')),
                                        ),
                                        const TextSpan(text: '.'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            ElevatedButton(
                              onPressed: authState.isLoading ? null : _register,
                              child: authState.isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: colorScheme.onPrimary,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text('Create Account'),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account?',
                                    style: TextStyle(
                                        color: colorScheme.onSurfaceVariant)),
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
