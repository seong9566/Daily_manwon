import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../settings/data/datasources/settings_local_datasource.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await GetIt.instance<SettingsLocalDatasource>()
          .setIsOnboardingCompleted(value: true);
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('온보딩 완료 저장 실패: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                children: [
                  _OnboardingPage(
                    isDark: isDark,
                    icon: null,
                    heroText: '하루 만원',
                    subtitle: '하루 1만원으로 살아보기',
                    description: null,
                    buttonLabel: '시작하기 →',
                    onPressed: _nextPage,
                  ),
                  _OnboardingPage(
                    isDark: isDark,
                    icon: '💰',
                    heroText: '매일 만원,\n얼마나 쓸 수 있을까요?',
                    subtitle: null,
                    description:
                        '남은 돈이 줄어들수록 숫자가 달라져요\n성공하면 도토리를 모을 수 있어요',
                    buttonLabel: '다음 →',
                    onPressed: _nextPage,
                  ),
                  _OnboardingPage(
                    isDark: isDark,
                    icon: '🌱',
                    heroText: '준비됐나요?',
                    subtitle: null,
                    description: '오늘부터 하루 만원 생활을 시작해요',
                    buttonLabel: '바로 시작 →',
                    onPressed: _isLoading ? null : _completeOnboarding,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            _DotIndicator(
              count: 3,
              currentIndex: _currentPage,
              isDark: isDark,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.isDark,
    required this.icon,
    required this.heroText,
    required this.subtitle,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.isLoading = false,
  });

  final bool isDark;
  final String? icon;
  final String heroText;
  final String? subtitle;
  final String? description;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final primaryColor = isDark ? AppColors.white : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 24),
          ],
          Text(
            heroText,
            style: AppTypography.displayLarge.copyWith(
              color: textMain,
              fontSize: icon == null ? 48 : 32,
              height: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: AppTypography.bodyLarge.copyWith(color: textSub),
            ),
          ],
          if (description != null) ...[
            const SizedBox(height: 20),
            Text(
              description!,
              style: AppTypography.bodyMedium.copyWith(
                color: textSub,
                height: 1.8,
              ),
            ),
          ],
          const SizedBox(height: 56),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? AppColors.primary : AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? AppColors.primary : AppColors.white,
                      ),
                    )
                  : Text(
                      buttonLabel,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark ? AppColors.primary : AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.count,
    required this.currentIndex,
    required this.isDark,
  });

  final int count;
  final int currentIndex;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.white : AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.darkDivider : AppColors.border;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
