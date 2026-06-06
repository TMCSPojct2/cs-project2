import 'package:flutter/material.dart';
import '../data/language_controller.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPage(
      titleEn: 'NABIH\nis with you.',
      titleAr: 'نبيه\nمعاك.',
      bodyEn: 'Schedules, grades, maps and announcements — all in one place.',
      bodyAr: 'الجداول والدرجات والخرائط والإعلانات — كلها في مكان واحد.',
      image: 'assets/branding/onboard1.jpg',
    ),
    _OnboardPage(
      titleEn: 'Never get lost\non campus.',
      titleAr: 'لا تضيع أبداً\nداخل الجامعة.',
      bodyEn: 'Tap any class and get step-by-step directions to the exact room.',
      bodyAr: 'اضغط على أي مادة واحصل على الاتجاهات للقاعة الصحيحة خطوة بخطوة.',
      image: 'assets/branding/onboard2.jpg',
    ),
    _OnboardPage(
      titleEn: 'A smart assistant\nalways ready.',
      titleAr: 'مساعد ذكي\nدائماً جاهز.',
      bodyEn: 'Ask NABIH anything — class times, GPA, directions, or campus news.',
      bodyAr: 'اسأل نبيه عن أي شيء — مواعيد المحاضرات أو المعدل أو مسارات الجامعة أو الأخبار.',
      image: 'assets/branding/onboard3.jpg',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 380), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _LocaleToggle(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _page == i ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _page == i
                                ? Colors.white
                                : Colors.white.withValues(alpha: .3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22)),
                          elevation: 0,
                        ),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: LanguageController.isArabic,
                          builder: (_, isAr, __) {
                            final isLast = _page == _pages.length - 1;
                            return Text(
                              isLast
                                  ? (isAr ? 'ابدأ الآن' : 'Get Started')
                                  : (isAr ? 'التالي' : 'Next'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_page < _pages.length - 1)
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/auth'),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: LanguageController.isArabic,
                          builder: (_, isAr, __) => Text(
                            isAr ? 'تخطي' : 'Skip',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: .55),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String titleEn, titleAr, bodyEn, bodyAr;
  final String image;
  const _OnboardPage({
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.image,
  });
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const controlsH = 8.0
                    + 28.0
                    + 56.0
                    + 14.0
                    + 44.0
                    + 32.0;
    final reservedBottom = controlsH + bottomInset;

    return ValueListenableBuilder<bool>(
      valueListenable: LanguageController.isArabic,
      builder: (_, isAr, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              page.image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .45),
                    Colors.black.withValues(alpha: .82),
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isAr ? page.titleAr : page.titleEn,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isAr ? page.bodyAr : page.bodyEn,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.white.withValues(alpha: .80),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: reservedBottom),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LocaleToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageController.isArabic,
      builder: (_, isAr, __) {
        return GestureDetector(
          onTap: () => LanguageController.toggle(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAr ? 'English' : 'العربية',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}
