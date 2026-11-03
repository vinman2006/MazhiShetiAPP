import 'package:flutter/material.dart';
import '../models/farmer_profile.dart';

// ============================================================================
// BRAND COLOR SYSTEM FOR ONBOARDING
// ============================================================================
class MazhiColors {
  static const Color primary = Color(0xFF0F3D2E); // Deep Trust Green
  static const Color secondary = Color(0xFFA7F070); // Fresh Sprout Green
  static const Color background = Color(0xFFE8FAD9); // Clean Calm Tint
  static const Color textMain = Color(0xFF1F2937); // Dark Charcoal
  static const Color muted = Color(0xFF9CA3AF); // Neutral Gray
  static const Color accent = Color(0xFFFFC64D); // Harvest Amber
  static const Color alert = Color(0xFFFF6B6B); // Coral Alert

  static const Color phoneSurface = Color(0xFFFDFFFA);
  static const Color liveBrighterGreen = Color(0xFF287D29);
  static const Color bodySubtle = Color(0xFF374151);
  static const Color captionSubtle = Color(0xFF4B5563);
  static const Color checklistCardBg = Color(0xFFF8FBF4);
  static const Color checklistCardBorder = Color(0xFFE6EFE0);
  static const Color checklistIconBox = Color(0xFFE3F6D3);
  static const Color weatherTopBlue = Color(0xFFE6F4FE);
  static const Color weatherBotBlue = Color(0xFFF2FAFF);
  static const Color weatherDivider = Color(0xFFD5E9F8);
  static const Color irrigationCardBg = Color(0xFFEAF6E4);
  static const Color irrigationIconBox = Color(0xFFD6F0C6);
  static const Color dotInactive = Color(0xFFD0D7CD);
}

// ============================================================================
// FIELD ITEM MODEL FOR INTERACTIVE ONBOARDING SCREEN 2
// ============================================================================
class OnboardingFieldItem {
  final String id;
  final String name;
  final double acres;
  final String crop;
  final String soilStatus;

  const OnboardingFieldItem({
    required this.id,
    required this.name,
    required this.acres,
    required this.crop,
    required this.soilStatus,
  });
}

// ============================================================================
// NATURAL ONBOARDING FLOW WIDGET (SCREENS 1 TO 6)
// ============================================================================
class OnboardingFlowWidget extends StatefulWidget {
  final FarmerProfileState profileState;
  final VoidCallback onProceedToSignUp;
  final VoidCallback onSkipToApp;

  const OnboardingFlowWidget({
    super.key,
    required this.profileState,
    required this.onProceedToSignUp,
    required this.onSkipToApp,
  });

  @override
  State<OnboardingFlowWidget> createState() => _OnboardingFlowWidgetState();
}

class _OnboardingFlowWidgetState extends State<OnboardingFlowWidget> {
  late final PageController _pageController;
  int _selectedFieldIndex = 0;

  final List<OnboardingFieldItem> _fields = const [
    OnboardingFieldItem(
      id: 'f1',
      name: 'Field 1',
      acres: 2.4,
      crop: 'Soybean (JS-9305)',
      soilStatus: 'Ideal soil moisture (68%)',
    ),
    OnboardingFieldItem(
      id: 'f2',
      name: 'Field 2',
      acres: 1.8,
      crop: 'Cotton (Bt Hybrid)',
      soilStatus: 'Scheduled irrigation 06:00 AM',
    ),
    OnboardingFieldItem(
      id: 'f3',
      name: 'Field 3',
      acres: 3.2,
      crop: 'Nagpur Mandarin Orange',
      soilStatus: 'Optimal NPK nutrient balance',
    ),
    OnboardingFieldItem(
      id: 'f4',
      name: 'Field 4',
      acres: 1.5,
      crop: 'Tur / Pigeon Pea',
      soilStatus: 'Healthy canopy growth',
    ),
    OnboardingFieldItem(
      id: 'f5',
      name: 'Field 5',
      acres: 2.1,
      crop: 'Sharbati Wheat',
      soilStatus: 'Pre-sowing prepared',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _cycleField() {
    setState(() {
      _selectedFieldIndex = (_selectedFieldIndex + 1) % _fields.length;
    });
  }

  void _animateTo(int page) {
    final target = page.clamp(0, 5);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MazhiColors.phoneSurface,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: [
            // Screen 1: Welcome Farmhouse & Rolling Hills
            Screen1WelcomeView(
              onNext: () => _animateTo(1),
              onSkip: widget.onProceedToSignUp,
            ),
            // Screen 2: 3D Isometric Field Map
            Screen2MapFieldsView(
              field: _fields[_selectedFieldIndex],
              onCycleField: _cycleField,
              onBack: () => _animateTo(0),
              onNext: () => _animateTo(2),
              onSkip: widget.onProceedToSignUp,
            ),
            // Screen 3: Smartphone Crop Leaf-Spot Scanner
            Screen3DetectCropView(
              onBack: () => _animateTo(1),
              onNext: () => _animateTo(3),
              onSkip: widget.onProceedToSignUp,
            ),
            // Screen 4: Stay Ahead with Weather
            Screen4WeatherView(
              onBack: () => _animateTo(2),
              onNext: () => _animateTo(4),
              onSkip: widget.onProceedToSignUp,
            ),
            // Screen 5: Plan, Track and Manage
            Screen5PlanTrackView(
              onBack: () => _animateTo(3),
              onNext: () => _animateTo(5),
              onSkip: widget.onProceedToSignUp,
            ),
            // Screen 6: A Greener Tomorrow
            Screen6GreenerTomorrowView(
              onBack: () => _animateTo(4),
              onGetStarted: widget.onProceedToSignUp,
              onSkip: widget.onProceedToSignUp,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED MOBILE TOP NAVIGATION ROW
// ============================================================================
class MobileTopNavRow extends StatelessWidget {
  final bool showBack;
  final bool showSkip;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  const MobileTopNavRow({
    super.key,
    this.showBack = true,
    this.showSkip = true,
    this.onBack,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showBack
              ? InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 26,
                      color: MazhiColors.primary,
                    ),
                  ),
                )
              : const SizedBox(width: 36),
          showSkip
              ? InkWell(
                  onTap: onSkip,
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2F4F3E),
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ============================================================================
// INDICATOR DOTS
// ============================================================================
class MobileIndicatorDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const MobileIndicatorDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (idx) {
        final active = idx == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: active ? MazhiColors.primary : MazhiColors.dotInactive,
          ),
        );
      }),
    );
  }
}

// ============================================================================
// SHARED MOBILE BOTTOM NAVIGATION ROW
// ============================================================================
class MobileBottomNavRow extends StatelessWidget {
  final int dotCount;
  final int activeDot;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

  const MobileBottomNavRow({
    super.key,
    required this.dotCount,
    required this.activeDot,
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                'Back',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MazhiColors.primary,
                ),
              ),
            ),
          ),
          MobileIndicatorDots(count: dotCount, activeIndex: activeDot),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: MazhiColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nextLabel,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CHECKLIST CARD WIDGET
// ============================================================================
class MobileChecklistCard extends StatelessWidget {
  final List<MobileChecklistItem> items;

  const MobileChecklistCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: MazhiColors.checklistCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MazhiColors.checklistCardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (idx) {
          final item = items[idx];
          return Padding(
            padding: EdgeInsets.only(bottom: idx == items.length - 1 ? 0 : 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: item.boxColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    size: 17,
                    color: item.iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: MazhiColors.textMain,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class MobileChecklistItem {
  final IconData icon;
  final String label;
  final Color boxColor;
  final Color iconColor;

  const MobileChecklistItem({
    required this.icon,
    required this.label,
    this.boxColor = MazhiColors.checklistIconBox,
    this.iconColor = MazhiColors.liveBrighterGreen,
  });
}

// ============================================================================
// EMBEDDED HIGH-RESOLUTION ILLUSTRATION LOADER WITH FALLBACK
// ============================================================================
class AppIllustrationImage extends StatelessWidget {
  final String assetPath;
  final CustomPainter fallbackPainter;
  final BoxFit fit;
  final Alignment alignment;

  const AppIllustrationImage({
    super.key,
    required this.assetPath,
    required this.fallbackPainter,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => CustomPaint(
        painter: fallbackPainter,
        size: Size.infinite,
      ),
    );
  }
}

// ============================================================================
// SCREEN 1: GROW BETTER, LIVE BRIGHTER (WELCOME)
// ============================================================================
class Screen1WelcomeView extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const Screen1WelcomeView({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileTopNavRow(
          showBack: false,
          showSkip: true,
          onSkip: onSkip,
        ),
        const SizedBox(height: 8),
        const Center(
          child: SizedBox(
            width: 88,
            height: 88,
            child: CustomPaint(painter: MazhiLogoPainter()),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Mazhi Sheti',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: MazhiColors.primary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Row(
            children: [
              Expanded(
                child: Container(height: 1, color: const Color(0xFFD5DDD2)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Smart Farming for\na Better Tomorrow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    color: MazhiColors.captionSubtle,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFD5DDD2)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grow Better,',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  color: MazhiColors.primary,
                  height: 1.12,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Live Brighter',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  color: MazhiColors.liveBrighterGreen,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Technology in the hands\nof every farmer.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: MazhiColors.bodySubtle,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Expanded(
          child: AppIllustrationImage(
            assetPath: 'assets/images/screen_1_bg.jpg',
            fallbackPainter: HillsFarmhousePainter(),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        Container(
          color: MazhiColors.phoneSurface,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MazhiColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const MobileIndicatorDots(count: 6, activeIndex: 0),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SCREEN 2: MAP YOUR FIELDS (INTERACTIVE FIELD CYCLING)
// ============================================================================
class Screen2MapFieldsView extends StatelessWidget {
  final OnboardingFieldItem field;
  final VoidCallback onCycleField;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const Screen2MapFieldsView({
    super.key,
    required this.field,
    required this.onCycleField,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MobileTopNavRow(onBack: onBack, onSkip: onSkip),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Map Your Fields',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: MazhiColors.primary,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Mark your land, measure area\nand keep all your fields in\none place.',
                style: TextStyle(
                  fontSize: 14,
                  color: MazhiColors.bodySubtle,
                  height: 1.36,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Stack(
            children: [
              const Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: AppIllustrationImage(
                    assetPath: 'assets/images/screen_2_bg.jpg',
                    fallbackPainter: IsometricFieldPainter(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Interactive Callout Bubble (Tapping cycles through fields!)
              Positioned(
                top: 10,
                right: 28,
                child: GestureDetector(
                  onTap: onCycleField,
                  child: CustomPaint(
                    painter: const SpeechBubbleCalloutPainter(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 14, 18),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${field.acres.toStringAsFixed(1)} acres',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: MazhiColors.textMain,
                                ),
                              ),
                              Text(
                                '${field.name} • ${field.crop}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: MazhiColors.captionSubtle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: MazhiColors.textMain,
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
        const MobileChecklistCard(
          items: [
            MobileChecklistItem(
              icon: Icons.location_on_rounded,
              label: 'Map field boundaries',
            ),
            MobileChecklistItem(
              icon: Icons.bar_chart_rounded,
              label: 'Calculate area automatically',
            ),
            MobileChecklistItem(
              icon: Icons.description_rounded,
              label: 'Save multiple fields',
            ),
          ],
        ),
        const SizedBox(height: 6),
        MobileBottomNavRow(
          dotCount: 6,
          activeDot: 1,
          onBack: onBack,
          onNext: onNext,
        ),
      ],
    );
  }
}

// ============================================================================
// SCREEN 3: DETECT CROP PROBLEMS (INTERACTIVE AI DIAGNOSIS BOTTOM SHEET)
// ============================================================================
class Screen3DetectCropView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const Screen3DetectCropView({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  void _openDiagnosisSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: MazhiColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.eco_rounded,
                      color: MazhiColors.liveBrighterGreen),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Possible Leaf Spot',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: MazhiColors.textMain,
                      ),
                    ),
                    Text(
                      'Confidence 92% • Cercospora Leaf Blight',
                      style: TextStyle(
                        fontSize: 13,
                        color: MazhiColors.captionSubtle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'AI Treatment Recommendation:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: MazhiColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Apply Neem Oil 1500 ppm (3 ml/L) or Copper Oxychloride (2.5 g/L) foliar spray in early morning. Avoid overhead sprinkler irrigation for 48 hours.',
              style: TextStyle(
                fontSize: 13.5,
                color: MazhiColors.bodySubtle,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MazhiColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Got It'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MobileTopNavRow(onBack: onBack, onSkip: onSkip),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detect Crop\nProblems',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: MazhiColors.primary,
                  height: 1.14,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Take a photo, get AI-powered\nsuggestions and protect\nyour yield.',
                style: TextStyle(
                  fontSize: 14,
                  color: MazhiColors.bodySubtle,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              const Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: AppIllustrationImage(
                    assetPath: 'assets/images/screen_3_bg.jpg',
                    fallbackPainter: CropScannerPainter(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Interactive Scanner Pill (Opens AI diagnosis recommendation!)
              Positioned(
                bottom: 10,
                left: 28,
                right: 28,
                child: GestureDetector(
                  onTap: () => _openDiagnosisSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: MazhiColors.checklistIconBox,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            size: 19,
                            color: MazhiColors.liveBrighterGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Possible Leaf Spot',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: MazhiColors.textMain,
                                ),
                              ),
                              Text(
                                'Confidence 92% • Tap for AI diagnosis ›',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: MazhiColors.captionSubtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: MazhiColors.textMain,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const MobileChecklistCard(
          items: [
            MobileChecklistItem(
              icon: Icons.camera_alt_rounded,
              label: 'Scan crops with your camera',
            ),
            MobileChecklistItem(
              icon: Icons.lightbulb_rounded,
              label: 'Get instant AI suggestions',
            ),
            MobileChecklistItem(
              icon: Icons.description_rounded,
              label: 'Learn treatment options',
            ),
          ],
        ),
        const SizedBox(height: 6),
        MobileBottomNavRow(
          dotCount: 6,
          activeDot: 2,
          onBack: onBack,
          onNext: onNext,
        ),
      ],
    );
  }
}

// ============================================================================
// SCREEN 4: STAY AHEAD WITH WEATHER
// ============================================================================
class Screen4WeatherView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const Screen4WeatherView({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MobileTopNavRow(onBack: onBack, onSkip: onSkip),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stay Ahead\nwith Weather',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: MazhiColors.primary,
                  height: 1.14,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Get real-time weather updates,\nalerts and smart recommendations\nfor your fields.',
                style: TextStyle(
                  fontSize: 13.8,
                  color: MazhiColors.bodySubtle,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Two-Tone Weather Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: MazhiColors.weatherBotBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: MazhiColors.weatherTopBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 66,
                      height: 52,
                      child: Stack(
                        children: [
                          Positioned(
                            right: 6,
                            top: 0,
                            child: Icon(
                              Icons.wb_sunny_rounded,
                              size: 30,
                              color: Color(0xFFFFB800),
                            ),
                          ),
                          Positioned(
                            left: 4,
                            bottom: 0,
                            child: Icon(
                              Icons.cloud_rounded,
                              size: 42,
                              color: Color(0xFF38BDF8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today, Nagpur',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: MazhiColors.bodySubtle,
                          ),
                        ),
                        Text(
                          '32°C',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: MazhiColors.textMain,
                            height: 1.12,
                          ),
                        ),
                        Text(
                          'Partly cloudy',
                          style: TextStyle(
                            fontSize: 13,
                            color: MazhiColors.bodySubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const _WeatherStatColumn(
                      icon: Icons.water_drop_rounded,
                      value: '20%',
                      label: 'Rain Chance',
                    ),
                    Container(
                      width: 1,
                      height: 26,
                      color: MazhiColors.weatherDivider,
                    ),
                    const _WeatherStatColumn(
                      icon: Icons.air_rounded,
                      value: '14 km/h',
                      label: 'Wind',
                    ),
                    Container(
                      width: 1,
                      height: 26,
                      color: MazhiColors.weatherDivider,
                    ),
                    const _WeatherStatColumn(
                      icon: Icons.thermostat_rounded,
                      value: '31°C',
                      label: 'Feels like',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Irrigation advisory card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: MazhiColors.irrigationCardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: MazhiColors.irrigationIconBox,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 19,
                  color: MazhiColors.liveBrighterGreen,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good day for irrigation',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: MazhiColors.textMain,
                    ),
                  ),
                  Text(
                    'Ideal soil moisture levels (68%).',
                    style: TextStyle(
                      fontSize: 12,
                      color: MazhiColors.captionSubtle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Expanded(
          child: SizedBox(
            width: double.infinity,
            child: AppIllustrationImage(
              assetPath: 'assets/images/screen_4_bg.jpg',
              fallbackPainter: WeatherHillsPainter(),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
        MobileBottomNavRow(
          dotCount: 6,
          activeDot: 3,
          onBack: onBack,
          onNext: onNext,
        ),
      ],
    );
  }
}

class _WeatherStatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherStatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF0284C7)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: MazhiColors.textMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: MazhiColors.captionSubtle,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SCREEN 5: PLAN, TRACK AND MANAGE
// ============================================================================
class Screen5PlanTrackView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const Screen5PlanTrackView({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MobileTopNavRow(onBack: onBack, onSkip: onSkip),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 52,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan, Track\nand Manage',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: MazhiColors.primary,
                          height: 1.14,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Set reminders, manage tasks\nand keep track of all your\nfarming activities.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: MazhiColors.bodySubtle,
                          height: 1.38,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 48,
                  child: AppIllustrationImage(
                    assetPath: 'assets/images/screen_5_bg.jpg',
                    fallbackPainter: ClipboardSproutPainter(),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
        const MobileChecklistCard(
          items: [
            MobileChecklistItem(
              icon: Icons.notifications_rounded,
              label: 'Set reminders (irrigation, fertilizer, etc.)',
            ),
            MobileChecklistItem(
              icon: Icons.bar_chart_rounded,
              boxColor: Color(0xFFE5EFEA),
              iconColor: Color(0xFF1E5E3A),
              label: 'Track farm activities',
            ),
            MobileChecklistItem(
              icon: Icons.calendar_month_rounded,
              label: 'Plan your farming calendar',
            ),
          ],
        ),
        const SizedBox(height: 8),
        MobileBottomNavRow(
          dotCount: 6,
          activeDot: 4,
          onBack: onBack,
          onNext: onNext,
        ),
      ],
    );
  }
}

// ============================================================================
// SCREEN 6: A GREENER TOMORROW (WITH GET STARTED BUTTON)
// ============================================================================
class Screen6GreenerTomorrowView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  const Screen6GreenerTomorrowView({
    super.key,
    required this.onBack,
    required this.onGetStarted,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MobileTopNavRow(onBack: onBack, onSkip: onSkip),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 52,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A Greener\nTomorrow',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: MazhiColors.primary,
                          height: 1.14,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Together, let's build\nsustainable farming for\nhealthier farms and\nbrighter communities.",
                        style: TextStyle(
                          fontSize: 13.5,
                          color: MazhiColors.bodySubtle,
                          height: 1.38,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 48,
                  child: AppIllustrationImage(
                    assetPath: 'assets/images/screen_6_bg.jpg',
                    fallbackPainter: HandSaplingPainter(),
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ],
            ),
          ),
        ),
        const MobileChecklistCard(
          items: [
            MobileChecklistItem(
              icon: Icons.spa_rounded,
              label: 'Higher productivity',
            ),
            MobileChecklistItem(
              icon: Icons.water_drop_rounded,
              boxColor: Color(0xFFE0F2FE),
              iconColor: Color(0xFF0284C7),
              label: 'Lower resource use',
            ),
            MobileChecklistItem(
              icon: Icons.groups_rounded,
              label: 'Healthier communities',
            ),
          ],
        ),
        const SizedBox(height: 8),
        MobileBottomNavRow(
          dotCount: 6,
          activeDot: 5,
          onBack: onBack,
          onNext: onGetStarted,
          nextLabel: 'Get Started',
        ),
      ],
    );
  }
}

// ============================================================================
// VECTOR FALLBACK PAINTERS
// ============================================================================
class SpeechBubbleCalloutPainter extends CustomPainter {
  const SpeechBubbleCalloutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height - 8;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(16),
    );
    final path = Path()
      ..addRRect(rrect)
      ..moveTo(w * 0.28, h)
      ..lineTo(w * 0.34, h + 9)
      ..lineTo(w * 0.42, h)
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.14), 8, true);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MazhiLogoPainter extends CustomPainter {
  final bool darkMode;
  const MazhiLogoPainter({this.darkMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final sunPaint = Paint()..color = const Color(0xFFFDB933);
    final sunPath = Path()
      ..moveTo(w * 0.25, h * 0.26)
      ..arcToPoint(
        Offset(w * 0.78, h * 0.34),
        radius: Radius.circular(w * 0.27),
        clockwise: true,
      )
      ..quadraticBezierTo(w * 0.63, h * 0.39, w * 0.53, h * 0.48)
      ..quadraticBezierTo(w * 0.42, h * 0.32, w * 0.25, h * 0.26)
      ..close();
    canvas.drawPath(sunPath, sunPaint);

    final ulOuterColor = darkMode ? const Color(0xFFE8FAD9) : const Color(0xFF3B942A);
    final ulInnerColor = darkMode ? const Color(0xFFD2F4B8) : const Color(0xFF156726);

    final ulOuter = Path()
      ..moveTo(w * 0.08, h * 0.23)
      ..quadraticBezierTo(w * 0.06, h * 0.47, w * 0.38, h * 0.56)
      ..lineTo(w * 0.49, h * 0.48)
      ..close();
    canvas.drawPath(ulOuter, Paint()..color = ulOuterColor);

    final ulInner = Path()
      ..moveTo(w * 0.08, h * 0.23)
      ..quadraticBezierTo(w * 0.38, h * 0.29, w * 0.49, h * 0.48)
      ..close();
    canvas.drawPath(ulInner, Paint()..color = ulInnerColor);

    final mlWedge = Path()
      ..moveTo(w * 0.08, h * 0.51)
      ..quadraticBezierTo(w * 0.24, h * 0.57, w * 0.36, h * 0.62)
      ..quadraticBezierTo(w * 0.23, h * 0.68, w * 0.13, h * 0.72)
      ..quadraticBezierTo(w * 0.08, h * 0.62, w * 0.08, h * 0.51)
      ..close();
    canvas.drawPath(mlWedge, Paint()..color = ulOuterColor);

    final urInnerColor = darkMode ? const Color(0xFF68C93E) : const Color(0xFF156726);
    final urOuterColor = darkMode ? const Color(0xFFA7F070) : const Color(0xFF3B942A);

    final urInner = Path()
      ..moveTo(w * 0.92, h * 0.34)
      ..quadraticBezierTo(w * 0.62, h * 0.39, w * 0.40, h * 0.64)
      ..lineTo(w * 0.92, h * 0.34)
      ..close();
    canvas.drawPath(urInner, Paint()..color = urInnerColor);

    final urOuter = Path()
      ..moveTo(w * 0.92, h * 0.34)
      ..quadraticBezierTo(w * 0.94, h * 0.55, w * 0.87, h * 0.68)
      ..quadraticBezierTo(w * 0.65, h * 0.61, w * 0.40, h * 0.64)
      ..close();
    canvas.drawPath(urOuter, Paint()..color = urOuterColor);

    final band1Color = darkMode ? const Color(0xFFE8FAD9) : const Color(0xFF298229);
    final band1 = Path()
      ..moveTo(w * 0.16, h * 0.77)
      ..quadraticBezierTo(w * 0.48, h * 0.63, w * 0.82, h * 0.70)
      ..quadraticBezierTo(w * 0.54, h * 0.75, w * 0.33, h * 0.91)
      ..quadraticBezierTo(w * 0.22, h * 0.86, w * 0.16, h * 0.77)
      ..close();
    canvas.drawPath(band1, Paint()..color = band1Color);

    final band2Color = darkMode ? const Color(0xFFD2F4B8) : const Color(0xFF156726);
    final band2 = Path()
      ..moveTo(w * 0.41, h * 0.94)
      ..quadraticBezierTo(w * 0.60, h * 0.78, w * 0.84, h * 0.75)
      ..quadraticBezierTo(w * 0.69, h * 0.96, w * 0.41, h * 0.94)
      ..close();
    canvas.drawPath(band2, Paint()..color = band2Color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HillsFarmhousePainter extends CustomPainter {
  const HillsFarmhousePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = MazhiColors.phoneSurface);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IsometricFieldPainter extends CustomPainter {
  const IsometricFieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = MazhiColors.phoneSurface);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CropScannerPainter extends CustomPainter {
  const CropScannerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = MazhiColors.phoneSurface);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WeatherHillsPainter extends CustomPainter {
  const WeatherHillsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = MazhiColors.phoneSurface);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ClipboardSproutPainter extends CustomPainter {
  const ClipboardSproutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = MazhiColors.phoneSurface);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HandSaplingPainter extends CustomPainter {
  const HandSaplingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = MazhiColors.phoneSurface);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
