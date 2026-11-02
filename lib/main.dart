import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models/farmer_profile.dart';
import 'screens/signup_screen.dart';
import 'screens/post_login_app_screen.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const MazhiShetiApp());
}

class MazhiShetiApp extends StatefulWidget {
  const MazhiShetiApp({super.key});

  @override
  State<MazhiShetiApp> createState() => _MazhiShetiAppState();
}

class _MazhiShetiAppState extends State<MazhiShetiApp> {
  final FarmerProfileState profileState = FarmerProfileState();

  @override
  void initState() {
    super.initState();
    profileState.addListener(_onProfileStateChanged);
  }

  void _onProfileStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    profileState.removeListener(_onProfileStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mazhi Sheti - Smart Farming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBFBF6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3B2A),
          primary: const Color(0xFF0D3B2A),
          secondary: const Color(0xFF88C440),
          surface: const Color(0xFFFBFBF6),
        ),
        fontFamily: 'Roboto',
      ),
      home: _buildStageScreen(),
    );
  }

  Widget _buildStageScreen() {
    switch (profileState.activeAppStage) {
      case 1:
        return SignupScreen(
          profileState: profileState,
          onBackToOnboarding: () => profileState.setAppStage(0),
          onRegistrationComplete: () => profileState.setAppStage(2),
        );
      case 2:
        return PostLoginAppScreen(
          profileState: profileState,
          onSignOut: () => profileState.setAppStage(1),
          onBackToOnboarding: () => profileState.setAppStage(0),
        );
      case 0:
      default:
        return OnboardingShell(
          profileState: profileState,
          onProceedToSignUp: () => profileState.setAppStage(1),
          onSkipToApp: () => profileState.setAppStage(2),
        );
    }
  }
}

/// Holds user selections across all 8 onboarding screens.
class OnboardingState extends ChangeNotifier {
  int currentScreen = 0; // 0..7 corresponding to 1/8..8/8
  bool showGridOverview = false;

  // Screen 1: Language
  String selectedLanguage = 'English';

  // Screen 3: Role
  String selectedRole = 'Farmer';

  // Screen 4: Farm Details
  String? selectedState;
  String? selectedDistrict;
  String? selectedFarmSize;
  String? selectedMainCrop;

  // Screen 5: Permissions
  final Set<String> grantedPermissions = {'Location', 'Camera', 'Notifications'};

  // Screen 6: Crops (Multiple selection)
  final Set<String> selectedCrops = {'Rice'};
  final List<CropItemData> availableCrops = [
    const CropItemData('Rice', CropIconType.rice),
    const CropItemData('Wheat', CropIconType.wheat),
    const CropItemData('Soybean', CropIconType.soybean),
    const CropItemData('Cotton', CropIconType.cotton),
    const CropItemData('Sugarcane', CropIconType.sugarcane),
    const CropItemData('Maize', CropIconType.maize),
    const CropItemData('Tur / Pigeon Pea', CropIconType.tur),
    const CropItemData('Groundnut', CropIconType.groundnut),
  ];

  // Screen 7: Location
  String selectedLocation = 'Nagpur, Maharashtra';

  void setLanguage(String lang) {
    selectedLanguage = lang;
    notifyListeners();
  }

  void setRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  void updateFarmDetail({
    String? state,
    String? district,
    String? farmSize,
    String? mainCrop,
  }) {
    if (state != null) selectedState = state;
    if (district != null) selectedDistrict = district;
    if (farmSize != null) selectedFarmSize = farmSize;
    if (mainCrop != null) selectedMainCrop = mainCrop;
    notifyListeners();
  }

  void togglePermission(String perm) {
    if (grantedPermissions.contains(perm)) {
      grantedPermissions.remove(perm);
    } else {
      grantedPermissions.add(perm);
    }
    notifyListeners();
  }

  void toggleCrop(String crop) {
    if (selectedCrops.contains(crop)) {
      if (selectedCrops.length > 1) {
        selectedCrops.remove(crop);
      }
    } else {
      selectedCrops.add(crop);
    }
    notifyListeners();
  }

  void addCustomCrop(String cropName) {
    if (cropName.trim().isEmpty) return;
    final clean = cropName.trim();
    if (!availableCrops.any((c) => c.name.toLowerCase() == clean.toLowerCase())) {
      availableCrops.add(CropItemData(clean, CropIconType.sprout));
    }
    selectedCrops.add(clean);
    notifyListeners();
  }

  void setLocation(String loc) {
    selectedLocation = loc;
    notifyListeners();
  }

  void goToScreen(int index) {
    currentScreen = index.clamp(0, 7);
    showGridOverview = false;
    notifyListeners();
  }

  void toggleOverview() {
    showGridOverview = !showGridOverview;
    notifyListeners();
  }
}

enum CropIconType {
  rice,
  wheat,
  soybean,
  cotton,
  sugarcane,
  maize,
  tur,
  groundnut,
  sprout,
}

class CropItemData {
  final String name;
  final CropIconType iconType;
  const CropItemData(this.name, this.iconType);
}

class OnboardingScope extends InheritedWidget {
  final VoidCallback onSkip;
  final VoidCallback onProceedToSignUp;

  const OnboardingScope({
    super.key,
    required this.onSkip,
    required this.onProceedToSignUp,
    required super.child,
  });

  static OnboardingScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OnboardingScope>();

  @override
  bool updateShouldNotify(covariant OnboardingScope oldWidget) => false;
}

class OnboardingShell extends StatefulWidget {
  final FarmerProfileState? profileState;
  final VoidCallback? onProceedToSignUp;
  final VoidCallback? onSkipToApp;

  const OnboardingShell({
    super.key,
    this.profileState,
    this.onProceedToSignUp,
    this.onSkipToApp,
  });

  @override
  State<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends State<OnboardingShell> {
  final OnboardingState appState = OnboardingState();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    appState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    appState.removeListener(_onStateChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _syncToProfile() {
    if (widget.profileState != null) {
      widget.profileState!.setLanguage(appState.selectedLanguage);
      widget.profileState!.setRole(appState.selectedRole);
      widget.profileState!.updateFarmDetail(
        state: appState.selectedState,
        district: appState.selectedDistrict,
        farmSize: appState.selectedFarmSize,
        mainCrop: appState.selectedMainCrop,
      );
      widget.profileState!.selectedCrops.clear();
      for (final c in appState.selectedCrops) {
        widget.profileState!.selectedCrops.add(c);
      }
      widget.profileState!.setLocation(appState.selectedLocation);
    }
  }

  void _proceedToSignup() {
    _syncToProfile();
    if (widget.onProceedToSignUp != null) {
      widget.onProceedToSignUp!();
    }
  }

  void _animateToPage(int index) {
    appState.goToScreen(index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF6),
      body: SafeArea(
        top: true,
        bottom: true,
        child: OnboardingScope(
          onSkip: _proceedToSignup,
          onProceedToSignUp: _proceedToSignup,
          child: PageView(
            controller: _pageController,
            onPageChanged: (idx) => appState.goToScreen(idx),
            children: List.generate(
              8,
              (index) => _buildScreenByIndex(index, isInteractive: true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenByIndex(int index, {required bool isInteractive}) {
    void goNext() {
      if (!isInteractive) return;
      if (index < 7) {
        _animateToPage(index + 1);
      } else {
        _animateToPage(0);
      }
    }

    switch (index) {
      case 0:
        return Screen1ChooseLanguage(state: appState, onNext: goNext);
      case 1:
        return Screen2WelcomeVineet(state: appState, onNext: goNext);
      case 2:
        return Screen3WhatsYourRole(state: appState, onNext: goNext);
      case 3:
        return Screen4AboutYourFarm(state: appState, onNext: goNext);
      case 4:
        return Screen5EnablePermissions(state: appState, onNext: goNext);
      case 5:
        return Screen6WhichCrops(state: appState, onNext: goNext);
      case 6:
        return Screen7SetLocation(state: appState, onNext: goNext);
      case 7:
      default:
        return Screen8GrowBetter(
          state: appState,
          onRestart: () => _animateToPage(0),
          onProceedToSignUp: _proceedToSignup,
        );
    }
  }
}

// ============================================================================
// SHARED UI COMPONENTS (LOGO, HEADER, PRIMARY BUTTON, BACKGROUND IMAGE LOADER)
// ============================================================================

class ScreenBackgroundWithFallback extends StatelessWidget {
  final String assetPath;
  final CustomPainter fallbackPainter;
  final Widget child;

  const ScreenBackgroundWithFallback({
    super.key,
    required this.assetPath,
    required this.fallbackPainter,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Vector CustomPainter layer ensures the background always renders
        // even before asset bundle compilation.
        CustomPaint(painter: fallbackPainter),
        // High-res generated illustration asset layered on top when present in bundle
        Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
        child,
      ],
    );
  }
}

class MazhiShetiTopHeader extends StatelessWidget {
  final int stepNumber;
  final int totalSteps;
  final bool lightStepText;

  const MazhiShetiTopHeader({
    super.key,
    required this.stepNumber,
    this.totalSteps = 8,
    this.lightStepText = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSkip = OnboardingScope.of(context)?.onSkip;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const MazhiShetiLogo(scale: 1.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$stepNumber / $totalSteps',
                style: TextStyle(
                  color: lightStepText
                      ? const Color(0xFF385545)
                      : const Color(0xFF1F3B2E),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (onSkip != null) ...[
              const SizedBox(width: 8),
              Material(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(14),
                elevation: 1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onSkip,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF0D3B2A),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right, size: 14, color: Color(0xFF0D3B2A)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class MazhiShetiLogo extends StatelessWidget {
  final double scale;
  const MazhiShetiLogo({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(painter: _MazhiShetiEmblemPainter()),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mazhi\nSheti',
                style: TextStyle(
                  color: Color(0xFF0E3826),
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  height: 1.02,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Smart Farming\nfor a Better Tomorrow',
                style: TextStyle(
                  color: Color(0xFF3E594C),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MazhiShetiEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Rising sun (top circle)
    final sunPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF5A623), Color(0xFFD98218)],
      ).createShader(Rect.fromLTWH(w * 0.2, h * 0.04, w * 0.6, h * 0.5));
    canvas.drawCircle(Offset(w * 0.5, h * 0.30), w * 0.26, sunPaint);

    // Left upper green leaf/wing
    final leftLeafPaint = Paint()..color = const Color(0xFF3B8E3E);
    final leftWing = Path()
      ..moveTo(w * 0.04, h * 0.34)
      ..quadraticBezierTo(w * 0.28, h * 0.34, w * 0.48, h * 0.54)
      ..quadraticBezierTo(w * 0.22, h * 0.58, w * 0.04, h * 0.46)
      ..close();
    canvas.drawPath(leftWing, leftLeafPaint);

    // Right upper dark green leaf/wing
    final rightLeafPaint = Paint()..color = const Color(0xFF0F4C32);
    final rightWing = Path()
      ..moveTo(w * 0.96, h * 0.34)
      ..quadraticBezierTo(w * 0.72, h * 0.34, w * 0.52, h * 0.54)
      ..quadraticBezierTo(w * 0.78, h * 0.58, w * 0.96, h * 0.46)
      ..close();
    canvas.drawPath(rightWing, rightLeafPaint);

    // Bottom curved shield base (rolling fields)
    final bottomBasePaint = Paint()..color = const Color(0xFF0E442D);
    final bottomPath = Path()
      ..moveTo(w * 0.05, h * 0.52)
      ..quadraticBezierTo(w * 0.5, h * 0.68, w * 0.95, h * 0.52)
      ..arcToPoint(
        Offset(w * 0.05, h * 0.52),
        radius: Radius.circular(w * 0.46),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(bottomPath, bottomBasePaint);

    // White field furrow accent line inside base
    final furrowPaint = Paint()
      ..color = const Color(0xFFFBFBF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final furrow = Path()
      ..moveTo(w * 0.18, h * 0.78)
      ..quadraticBezierTo(w * 0.52, h * 0.60, w * 0.88, h * 0.67);
    canvas.drawPath(furrow, furrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PrimaryOnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;

  const PrimaryOnboardingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 188,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D3D2B),
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: const Color(0xFF0D3D2B).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 17, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 1 / 8: CHOOSE YOUR LANGUAGE
// ============================================================================

class Screen1ChooseLanguage extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const Screen1ChooseLanguage({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenBackgroundWithFallback(
      assetPath: 'assets/images/screen_1_bg.jpg',
      fallbackPainter: _Screen1Painter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MazhiShetiTopHeader(stepNumber: 1, lightStepText: true),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your\nLanguage',
                        style: TextStyle(
                          color: Color(0xFF0E3826),
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Get started in your preferred language.',
                        style: TextStyle(
                          color: Color(0xFF3E5549),
                          fontSize: 12.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, left: 6),
                    child: Transform.rotate(
                      angle: -0.14,
                      child: const Text(
                        'Better\nFarms\nBrighter\nTomorrows',
                        style: TextStyle(
                          color: Color(0xFF153E2A),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          height: 1.18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Language selector container (left-aligned ~62% width so right hill & house show)
            FractionallySizedBox(
              widthFactor: 0.64,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildLanguageTile(
                      badgeText: 'EN',
                      badgeBg: const Color(0xFF88C440),
                      badgeFg: const Color(0xFF0E3826),
                      title: 'English',
                      isSelected: state.selectedLanguage == 'English',
                      onTap: () => state.setLanguage('English'),
                    ),
                    const SizedBox(height: 8),
                    _buildLanguageTile(
                      badgeText: 'म',
                      badgeBg: const Color(0xFFF6D5B6),
                      badgeFg: const Color(0xFFC56126),
                      title: 'मराठी',
                      isSelected: state.selectedLanguage == 'मराठी',
                      onTap: () => state.setLanguage('मराठी'),
                    ),
                    const SizedBox(height: 8),
                    _buildLanguageTile(
                      badgeText: 'हि',
                      badgeBg: const Color(0xFFD7DEF2),
                      badgeFg: const Color(0xFF394B8C),
                      title: 'हिंदी',
                      isSelected: state.selectedLanguage == 'हिंदी',
                      onTap: () => state.setLanguage('हिंदी'),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            PrimaryOnboardingButton(label: 'Next', onPressed: onNext),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String badgeText,
    required Color badgeBg,
    required Color badgeFg,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2F3D6) : const Color(0xFFF5F6F1),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected ? const Color(0xFFA2D485) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeFg,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF103824),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF0E3D2A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 13, color: Colors.white),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA6B4AC), width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 2 / 8: WELCOME, VINEET!
// ============================================================================

class Screen2WelcomeVineet extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const Screen2WelcomeVineet({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenBackgroundWithFallback(
      assetPath: 'assets/images/screen_2_bg.jpg',
      fallbackPainter: _Screen2Painter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MazhiShetiTopHeader(stepNumber: 2),
            const SizedBox(height: 18),
            const Text(
              'Welcome,\nVineet! 👋',
              style: TextStyle(
                color: Color(0xFF0E3826),
                fontSize: 25,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Let's personalize Mazhi Sheti\nfor a better farming experience.",
              style: TextStyle(
                color: Color(0xFF3E5549),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.65,
              child: Column(
                children: [
                  _buildFeatureCard(
                    icon: Icons.spa_rounded,
                    label: 'Get crop recommendations',
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    icon: Icons.bar_chart_rounded,
                    label: 'Track your farm activities',
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    icon: Icons.notifications_active_rounded,
                    label: 'Receive timely alerts',
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryOnboardingButton(label: 'Next', onPressed: onNext),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF174F35), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1A3A2B),
                fontSize: 12.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SCREEN 3 / 8: WHAT'S YOUR ROLE?
// ============================================================================

class Screen3WhatsYourRole extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const Screen3WhatsYourRole({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenBackgroundWithFallback(
      assetPath: 'assets/images/screen_3_bg.jpg',
      fallbackPainter: _Screen3Painter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MazhiShetiTopHeader(stepNumber: 3),
            const SizedBox(height: 16),
            const Text(
              "What's Your Role?",
              style: TextStyle(
                color: Color(0xFF0E3826),
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tell us how you'll use Mazhi Sheti so we can\npersonalize your experience.",
              style: TextStyle(
                color: Color(0xFF3E5549),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.32,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.22,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildRoleCard(
                    roleKey: 'Farmer',
                    title: 'Farmer',
                    subtitle: 'I grow crops',
                    illustration: CustomPaint(
                      size: const Size(48, 48),
                      painter: _FarmerAvatarPainter(),
                    ),
                    isFarmerCardLayout: true,
                  ),
                  _buildRoleCard(
                    roleKey: 'Land Owner',
                    title: 'Land Owner',
                    subtitle: 'I manage farmland',
                    illustration: CustomPaint(
                      size: const Size(44, 44),
                      painter: _LandOwnerIconPainter(),
                    ),
                  ),
                  _buildRoleCard(
                    roleKey: 'Agriculture Student',
                    title: 'Agriculture Student',
                    subtitle: "I'm learning",
                    illustration: CustomPaint(
                      size: const Size(46, 44),
                      painter: _StudentCapPainter(),
                    ),
                  ),
                  _buildRoleCard(
                    roleKey: 'Advisor / Expert',
                    title: 'Advisor / Expert',
                    subtitle: 'I provide guidance',
                    illustration: CustomPaint(
                      size: const Size(44, 46),
                      painter: _AdvisorAvatarPainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            PrimaryOnboardingButton(label: 'Next', onPressed: onNext),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String title,
    required String subtitle,
    required Widget illustration,
    bool isFarmerCardLayout = false,
  }) {
    final isSelected = state.selectedRole == roleKey;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => state.setRole(roleKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE2F3D6)
              : Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8CC56A)
                : const Color(0xFFE6ECE6),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0E3D2A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 13, color: Colors.white),
                ),
              ),
            Center(
              child: isFarmerCardLayout
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            illustration,
                            const SizedBox(height: 2),
                            const Text(
                              'Farmer',
                              style: TextStyle(
                                color: Color(0xFF0E3826),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Color(0xFF0E3826),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF425A4D),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        illustration,
                        const SizedBox(height: 6),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF0E3826),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF425A4D),
                            fontSize: 10.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 4 / 8: TELL US ABOUT YOUR FARM
// ============================================================================

class Screen4AboutYourFarm extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const Screen4AboutYourFarm({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenBackgroundWithFallback(
      assetPath: 'assets/images/screen_4_bg.jpg',
      fallbackPainter: _Screen4Painter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MazhiShetiTopHeader(stepNumber: 4),
            const SizedBox(height: 16),
            const Text(
              'Tell Us About Your Farm',
              style: TextStyle(
                color: Color(0xFF0E3826),
                fontSize: 22.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'This helps us give you relevant advice and insights.',
              style: TextStyle(
                color: Color(0xFF3E5549),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.70,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _buildSelectorRow(
                      context: context,
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF8B3E22),
                      label: state.selectedState ?? 'Select Your State',
                      options: const [
                        'Maharashtra',
                        'Madhya Pradesh',
                        'Gujarat',
                        'Karnataka',
                        'Punjab',
                        'Uttar Pradesh',
                      ],
                      onSelected: (val) => state.updateFarmDetail(state: val),
                    ),
                    const SizedBox(height: 8),
                    _buildSelectorRow(
                      context: context,
                      icon: Icons.pin_drop_rounded,
                      iconColor: const Color(0xFF144B34),
                      label: state.selectedDistrict ?? 'Select Your District',
                      options: const [
                        'Nagpur',
                        'Pune',
                        'Nashik',
                        'Aurangabad',
                        'Amravati',
                        'Kolhapur',
                      ],
                      onSelected: (val) => state.updateFarmDetail(district: val),
                    ),
                    const SizedBox(height: 8),
                    _buildSelectorRow(
                      context: context,
                      icon: Icons.agriculture_rounded,
                      iconColor: const Color(0xFF144B34),
                      label: state.selectedFarmSize ?? 'Farm Size (in acres)',
                      options: const [
                        'Under 2 Acres',
                        '2 - 5 Acres',
                        '5 - 10 Acres',
                        '10+ Acres',
                      ],
                      onSelected: (val) => state.updateFarmDetail(farmSize: val),
                    ),
                    const SizedBox(height: 8),
                    _buildSelectorRow(
                      context: context,
                      icon: Icons.eco_rounded,
                      iconColor: const Color(0xFF144B34),
                      label: state.selectedMainCrop ?? 'Main Crop (Optional)',
                      options: const [
                        'Rice',
                        'Wheat',
                        'Soybean',
                        'Cotton',
                        'Sugarcane',
                        'Tur / Pigeon Pea',
                      ],
                      onSelected: (val) => state.updateFarmDetail(mainCrop: val),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            PrimaryOnboardingButton(label: 'Next', onPressed: onNext),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFFFBFBF6),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...options.map(
                    (opt) => ListTile(
                      leading: Icon(icon, color: iconColor),
                      title: Text(
                        opt,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0E3826),
                        ),
                      ),
                      onTap: () {
                        onSelected(opt);
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF203A2D),
                  fontSize: 12.2,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF3E5549),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 5 / 8: ENABLE PERMISSIONS
// ============================================================================

class Screen5EnablePermissions extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const Screen5EnablePermissions({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenBackgroundWithFallback(
      assetPath: 'assets/images/screen_5_bg.jpg',
      fallbackPainter: _Screen5Painter(),
      child: Stack(
        children: [
          // Floating speech bubble over phone on right side matching reference design
          Positioned(
            right: 12,
            bottom: 105,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Stay informed.\nGrow confidently.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF173D2B),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MazhiShetiTopHeader(stepNumber: 5),
                const SizedBox(height: 16),
                const Text(
                  'Enable Permissions',
                  style: TextStyle(
                    color: Color(0xFF0E3826),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'We need a few permissions to give you the\nbest experience.',
                  style: TextStyle(
                    color: Color(0xFF3E5549),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.32,
                  ),
                ),
                const SizedBox(height: 14),
                FractionallySizedBox(
                  widthFactor: 0.70,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _buildPermissionCard(
                          permKey: 'Location',
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFF1F5C3F),
                          title: 'Location',
                          subtitle: 'For field mapping, weather\nand local insights',
                        ),
                        const SizedBox(height: 8),
                        _buildPermissionCard(
                          permKey: 'Camera',
                          icon: Icons.camera_alt_rounded,
                          iconColor: const Color(0xFF1F5C3F),
                          title: 'Camera',
                          subtitle: 'To scan plants and capture\nfield photos',
                        ),
                        const SizedBox(height: 8),
                        _buildPermissionCard(
                          permKey: 'Notifications',
                          icon: Icons.notifications_active_rounded,
                          iconColor: const Color(0xFFD95338),
                          title: 'Notifications',
                          subtitle: 'For reminders and important\nalerts',
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                PrimaryOnboardingButton(
                  label: 'Allow & Continue',
                  width: 214,
                  onPressed: onNext,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required String permKey,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final enabled = state.grantedPermissions.contains(permKey);
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () => state.togglePermission(permKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF5F7F2) : const Color(0xFFECEEE9),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0E3826),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF425A4D),
                      fontSize: 10.2,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF3E5549),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 6 / 8: WHICH CROPS DO YOU GROW?
// ============================================================================

class Screen6WhichCrops extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const Screen6WhichCrops({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final items = state.availableCrops.take(8).toList();
    return ScreenBackgroundWithFallback(
      assetPath: 'assets/images/screen_6_bg.jpg',
      fallbackPainter: _Screen6Painter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MazhiShetiTopHeader(stepNumber: 6),
            const SizedBox(height: 12),
            const Text(
              'Which Crops\nDo You Grow?',
              style: TextStyle(
                color: Color(0xFF0E3826),
                fontSize: 23,
                fontWeight: FontWeight.w800,
                height: 1.12,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Select the crops you are interested in.\nYou can choose multiple.',
              style: TextStyle(
                color: Color(0xFF3E5549),
                fontSize: 11.8,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 0.88,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.02,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...items.map((crop) => _buildCropTile(crop)),
                    _buildAddMoreTile(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryOnboardingButton(label: 'Next', onPressed: onNext),
          ],
        ),
      ),
    );
  }

  Widget _buildCropTile(CropItemData crop) {
    final isSelected = state.selectedCrops.contains(crop.name);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => state.toggleCrop(crop.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE2F3D6)
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8CC56A)
                : const Color(0xFFE6ECE6),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0E3D2A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 11, color: Colors.white),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CustomPaint(
                      painter: _CropIllustrationPainter(crop.iconType),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    crop.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF153A28),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoreTile(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        final controller = TextEditingController();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFFFBFBF6),
            title: const Text(
              'Add Another Crop',
              style: TextStyle(
                color: Color(0xFF0E3826),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. Onion, Tomato, Bajra',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3D2B),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  state.addCustomCrop(controller.text);
                  Navigator.pop(ctx);
                },
                child: const Text('Add Crop'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6ECE6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1B4D36), width: 1.5),
              ),
              child: const Icon(Icons.add, color: Color(0xFF1B4D36), size: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add More',
              style: TextStyle(
                color: Color(0xFF153A28),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 7 / 8: SET YOUR LOCATION
// ============================================================================

class Screen7SetLocation extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const Screen7SetLocation({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenBackgroundWithFallback(
      assetPath: 'assets/images/screen_7_bg.jpg',
      fallbackPainter: _Screen7Painter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MazhiShetiTopHeader(stepNumber: 7),
            const SizedBox(height: 14),
            const Text(
              'Set Your Location',
              style: TextStyle(
                color: Color(0xFF0E3826),
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Get local weather, market prices and\narea-specific advice.',
              style: TextStyle(
                color: Color(0xFF3E5549),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.32,
              ),
            ),
            const SizedBox(height: 12),
            FractionallySizedBox(
              widthFactor: 0.68,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  final locations = [
                    'Nagpur, Maharashtra',
                    'Pune, Maharashtra',
                    'Nashik, Maharashtra',
                    'Kolhapur, Maharashtra',
                    'Amravati, Maharashtra',
                  ];
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFFFBFBF6),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (ctx) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: locations
                            .map(
                              (loc) => ListTile(
                                leading: const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF0E3D2A),
                                ),
                                title: Text(
                                  loc,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0E3826),
                                  ),
                                ),
                                onTap: () {
                                  state.setLocation(loc);
                                  Navigator.pop(ctx);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF0E3D2A),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.selectedLocation,
                          style: const TextStyle(
                            color: Color(0xFF0E3826),
                            fontSize: 12.2,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF3E5549),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            // White card over bottom green landscape
            FractionallySizedBox(
              widthFactor: 0.78,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildLocationBenefitRow(
                      Icons.wb_cloudy_rounded,
                      'Accurate weather updates',
                    ),
                    const SizedBox(height: 10),
                    _buildLocationBenefitRow(
                      Icons.bar_chart_rounded,
                      'Local market prices',
                    ),
                    const SizedBox(height: 10),
                    _buildLocationBenefitRow(
                      Icons.eco_rounded,
                      'Region-specific recommendations',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            PrimaryOnboardingButton(
              label: 'Use This Location',
              width: 214,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF174F35), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1A3A2B),
              fontSize: 11.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SCREEN 8 / 8: GROW BETTER, LIVE BRIGHTER
// ============================================================================

class Screen8GrowBetter extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onRestart;
  final VoidCallback onProceedToSignUp;

  const Screen8GrowBetter({
    super.key,
    required this.state,
    required this.onRestart,
    required this.onProceedToSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenBackgroundWithFallback(
      assetPath: 'assets/images/screen_8_bg.jpg',
      fallbackPainter: _Screen8Painter(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Top right 8 / 8 counter
          const Positioned(
            top: 24,
            right: 22,
            child: Text(
              '8 / 8',
              style: TextStyle(
                color: Color(0xFF1F3B2E),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Top centered larger Mazhi Sheti Logo
          const Align(
            alignment: Alignment(0, -0.76),
            child: MazhiShetiLogo(scale: 1.25),
          ),
          // Center white hero typography over deep forest green middle band
          Align(
            alignment: const Alignment(0, -0.02),
            child: GestureDetector(
              onTap: onRestart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Grow Better,\nLive Brighter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Together for a sustainable tomorrow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE8F4EC),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Primary Action Button: Proceed to Sign In / Sign Up
          Align(
            alignment: const Alignment(0, 0.78),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF88C440),
                        foregroundColor: const Color(0xFF0D3B2A),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: onProceedToSignUp,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20, color: Color(0xFF0D3B2A)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRestart,
                    child: const Text(
                      'Replay Onboarding from Screen 1',
                      style: TextStyle(
                        color: Color(0xFF1F3B2E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CUSTOM VECTOR PAINTERS FOR AVATARS, CROPS, AND SCENIC BACKGROUNDS
// ============================================================================

class _FarmerAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Straw hat brim
    final hatPaint = Paint()..color = const Color(0xFFE8B931);
    canvas.drawOval(Rect.fromLTWH(w * 0.12, h * 0.18, w * 0.76, h * 0.20), hatPaint);
    // Hat crown
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.06, w * 0.44, h * 0.18),
        const Radius.circular(8),
      ),
      hatPaint,
    );
    // Hat band
    canvas.drawRect(
      Rect.fromLTWH(w * 0.28, h * 0.20, w * 0.44, h * 0.05),
      Paint()..color = const Color(0xFF9C5124),
    );
    // Face
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.42),
      w * 0.17,
      Paint()..color = const Color(0xFFD68E58),
    );
    // Shoulders / Green shirt
    final shirtPath = Path()
      ..moveTo(w * 0.16, h * 0.92)
      ..quadraticBezierTo(w * 0.2, h * 0.60, w * 0.5, h * 0.60)
      ..quadraticBezierTo(w * 0.8, h * 0.60, w * 0.84, h * 0.92)
      ..close();
    canvas.drawPath(shirtPath, Paint()..color = const Color(0xFF1F6A39));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LandOwnerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromLTWH(0, 0, w, h));
    canvas.clipPath(clipPath);

    // Sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFD8EFE2),
    );
    // Rolling hills
    final hill1 = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.4, h * 0.45, w, h * 0.65)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill1, Paint()..color = const Color(0xFF5FA84E));

    final hill2 = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.6, h * 0.60, w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill2, Paint()..color = const Color(0xFF19583A));

    // Tiny house & tree
    canvas.drawRect(
      Rect.fromLTWH(w * 0.52, h * 0.46, w * 0.22, h * 0.16),
      Paint()..color = const Color(0xFFF6E7D2),
    );
    final roof = Path()
      ..moveTo(w * 0.48, h * 0.46)
      ..lineTo(w * 0.63, h * 0.34)
      ..lineTo(w * 0.78, h * 0.46)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF164C34));
    canvas.drawCircle(
      Offset(w * 0.30, h * 0.45),
      w * 0.11,
      Paint()..color = const Color(0xFF164C34),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StudentCapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final topDiamond = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..lineTo(w * 0.92, h * 0.38)
      ..lineTo(w * 0.5, h * 0.60)
      ..lineTo(w * 0.08, h * 0.38)
      ..close();
    canvas.drawPath(topDiamond, Paint()..color = const Color(0xFF1F6A42));

    final capBase = Path()
      ..moveTo(w * 0.24, h * 0.48)
      ..lineTo(w * 0.24, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.86, w * 0.76, h * 0.72)
      ..lineTo(w * 0.76, h * 0.48)
      ..lineTo(w * 0.5, h * 0.60)
      ..close();
    canvas.drawPath(capBase, Paint()..color = const Color(0xFF0F402A));

    // Gold tassel
    final tasselPaint = Paint()
      ..color = const Color(0xFFE6A825)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final tassel = Path()
      ..moveTo(w * 0.5, h * 0.38)
      ..lineTo(w * 0.80, h * 0.48)
      ..lineTo(w * 0.80, h * 0.75);
    canvas.drawPath(tassel, tasselPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AdvisorAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Hair & Head
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.30),
      w * 0.17,
      Paint()..color = const Color(0xFFD68E58),
    );
    final hair = Path()
      ..moveTo(w * 0.33, h * 0.30)
      ..arcToPoint(
        Offset(w * 0.67, h * 0.30),
        radius: Radius.circular(w * 0.18),
      )
      ..close();
    canvas.drawPath(hair, Paint()..color = const Color(0xFF212B25));

    // Suit shoulders
    final suit = Path()
      ..moveTo(w * 0.16, h * 0.92)
      ..quadraticBezierTo(w * 0.20, h * 0.54, w * 0.5, h * 0.54)
      ..quadraticBezierTo(w * 0.80, h * 0.54, w * 0.84, h * 0.92)
      ..close();
    canvas.drawPath(suit, Paint()..color = const Color(0xFF0F442D));

    // White shirt & tie
    final shirt = Path()
      ..moveTo(w * 0.40, h * 0.54)
      ..lineTo(w * 0.50, h * 0.84)
      ..lineTo(w * 0.60, h * 0.54)
      ..close();
    canvas.drawPath(shirt, Paint()..color = Colors.white);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.48, h * 0.58, w * 0.04, h * 0.24),
      Paint()..color = const Color(0xFFC56126),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CropIllustrationPainter extends CustomPainter {
  final CropIconType type;
  const _CropIllustrationPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    switch (type) {
      case CropIconType.rice:
      case CropIconType.wheat:
        final gold = Paint()
          ..color = type == CropIconType.rice
              ? const Color(0xFFE0A93A)
              : const Color(0xFFD88C28);
        final stem = Paint()
          ..color = const Color(0xFFC88A28)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(w * 0.5, h * 0.92), Offset(w * 0.5, h * 0.15), stem);
        for (int i = 0; i < 4; i++) {
          final y = h * (0.22 + i * 0.15);
          canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.38, y), width: 6, height: 10), gold);
          canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.62, y), width: 6, height: 10), gold);
        }
        break;
      case CropIconType.soybean:
        final green = Paint()..color = const Color(0xFF4C9438);
        canvas.drawOval(Rect.fromLTWH(w * 0.18, h * 0.35, w * 0.64, h * 0.30), green);
        canvas.drawCircle(Offset(w * 0.35, h * 0.50), 4, Paint()..color = const Color(0xFF88C440));
        canvas.drawCircle(Offset(w * 0.52, h * 0.50), 4, Paint()..color = const Color(0xFF88C440));
        canvas.drawCircle(Offset(w * 0.68, h * 0.50), 4, Paint()..color = const Color(0xFF88C440));
        break;
      case CropIconType.cotton:
        final white = Paint()..color = const Color(0xFFF2F4F0);
        final border = Paint()
          ..color = const Color(0xFFD0D5CE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        for (final offset in [
          Offset(w * 0.38, h * 0.42),
          Offset(w * 0.62, h * 0.42),
          Offset(w * 0.50, h * 0.28),
        ]) {
          canvas.drawCircle(offset, w * 0.18, white);
          canvas.drawCircle(offset, w * 0.18, border);
        }
        final calyx = Path()
          ..moveTo(w * 0.28, h * 0.58)
          ..lineTo(w * 0.50, h * 0.85)
          ..lineTo(w * 0.72, h * 0.58)
          ..close();
        canvas.drawPath(calyx, Paint()..color = const Color(0xFF2E6F3E));
        break;
      case CropIconType.sugarcane:
        final stalk = Paint()
          ..color = const Color(0xFF4E9A36)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(w * 0.42, h * 0.88), Offset(w * 0.42, h * 0.25), stalk);
        canvas.drawLine(Offset(w * 0.58, h * 0.88), Offset(w * 0.58, h * 0.25), stalk);
        break;
      case CropIconType.maize:
        canvas.drawOval(
          Rect.fromLTWH(w * 0.34, h * 0.16, w * 0.32, h * 0.58),
          Paint()..color = const Color(0xFFF2B624),
        );
        final husk = Path()
          ..moveTo(w * 0.5, h * 0.86)
          ..quadraticBezierTo(w * 0.18, h * 0.65, w * 0.26, h * 0.35)
          ..quadraticBezierTo(w * 0.40, h * 0.62, w * 0.5, h * 0.78)
          ..quadraticBezierTo(w * 0.60, h * 0.62, w * 0.74, h * 0.35)
          ..quadraticBezierTo(w * 0.82, h * 0.65, w * 0.5, h * 0.86);
        canvas.drawPath(husk, Paint()..color = const Color(0xFF2E7D32));
        break;
      case CropIconType.tur:
        final brown = Paint()..color = const Color(0xFF9E4F24);
        for (int i = 0; i < 5; i++) {
          final angle = (i * 0.6) - 1.2;
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(w * 0.5 + math.sin(angle) * 9, h * 0.45 + math.cos(angle) * 6),
              width: 7,
              height: 12,
            ),
            brown,
          );
        }
        break;
      case CropIconType.groundnut:
        final nutPaint = Paint()..color = const Color(0xFFC68642);
        canvas.drawOval(Rect.fromLTWH(w * 0.22, h * 0.36, w * 0.32, h * 0.42), nutPaint);
        canvas.drawOval(Rect.fromLTWH(w * 0.46, h * 0.26, w * 0.32, h * 0.42), nutPaint);
        break;
      case CropIconType.sprout:
        final leaf = Paint()..color = const Color(0xFF3B8E3E);
        canvas.drawOval(Rect.fromLTWH(w * 0.22, h * 0.32, w * 0.28, h * 0.22), leaf);
        canvas.drawOval(Rect.fromLTWH(w * 0.50, h * 0.24, w * 0.28, h * 0.22), leaf);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// FALLBACK SCENIC VECTOR PAINTERS FOR SCREENS 1 TO 8
// ============================================================================

void _paintCommonHillsAndHouse(
  Canvas canvas,
  Size size, {
  bool showHouse = true,
  bool showTopRightLeaves = true,
}) {
  final w = size.width;
  final h = size.height;

  // Base cream canvas
  canvas.drawRect(
    Rect.fromLTWH(0, 0, w, h),
    Paint()..color = const Color(0xFFFBFBF6),
  );

  // Warm sun glow on right
  final sunGlow = Paint()
    ..shader = RadialGradient(
      colors: [
        const Color(0xFFFBE08B).withValues(alpha: 0.65),
        const Color(0xFFFBFBF6).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(w * 0.85, h * 0.55), radius: w * 0.55));
  canvas.drawCircle(Offset(w * 0.85, h * 0.55), w * 0.55, sunGlow);

  // Distant hill
  final backHill = Path()
    ..moveTo(w * 0.35, h)
    ..quadraticBezierTo(w * 0.65, h * 0.56, w, h * 0.62)
    ..lineTo(w, h)
    ..close();
  canvas.drawPath(backHill, Paint()..color = const Color(0xFF8CC462));

  // Foreground rolling hill
  final frontHill = Path()
    ..moveTo(w * 0.25, h)
    ..quadraticBezierTo(w * 0.68, h * 0.68, w, h * 0.72)
    ..lineTo(w, h)
    ..close();
  canvas.drawPath(frontHill, Paint()..color = const Color(0xFF39853C));

  if (showHouse) {
    final hx = w * 0.74;
    final hy = h * 0.66;
    canvas.drawRect(
      Rect.fromLTWH(hx, hy, 42, 28),
      Paint()..color = const Color(0xFFF3E2C7),
    );
    final roof = Path()
      ..moveTo(hx - 5, hy)
      ..lineTo(hx + 21, hy - 16)
      ..lineTo(hx + 47, hy)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF8C3B2B));
  }

  if (showTopRightLeaves) {
    final leafPaint = Paint()..color = const Color(0xFF388E3C);
    final leaf1 = Path()
      ..moveTo(w, 0)
      ..quadraticBezierTo(w * 0.82, h * 0.03, w * 0.84, h * 0.13)
      ..quadraticBezierTo(w * 0.94, h * 0.09, w, 0)
      ..close();
    canvas.drawPath(leaf1, leafPaint);
  }
}

class _Screen1Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) =>
      _paintCommonHillsAndHouse(canvas, size, showHouse: true, showTopRightLeaves: true);
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Screen2Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintCommonHillsAndHouse(canvas, size, showHouse: false, showTopRightLeaves: true);
    final w = size.width;
    final h = size.height;
    // Soil mound & young sprout on right
    final soil = Path()
      ..moveTo(w * 0.52, h)
      ..quadraticBezierTo(w * 0.78, h * 0.78, w, h)
      ..close();
    canvas.drawPath(soil, Paint()..color = const Color(0xFF5C3818));
    canvas.drawLine(
      Offset(w * 0.78, h * 0.86),
      Offset(w * 0.78, h * 0.56),
      Paint()
        ..color = const Color(0xFF2E7D32)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Screen3Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) =>
      _paintCommonHillsAndHouse(canvas, size, showHouse: false, showTopRightLeaves: false);
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Screen4Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) =>
      _paintCommonHillsAndHouse(canvas, size, showHouse: true, showTopRightLeaves: false);
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Screen5Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintCommonHillsAndHouse(canvas, size, showHouse: false, showTopRightLeaves: false);
    final w = size.width;
    final h = size.height;
    // Phone frame on bottom right
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.72, h * 0.52, w * 0.24, h * 0.42),
      const Radius.circular(14),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF1A2821));
    canvas.drawRRect(
      rect.deflate(4),
      Paint()..color = const Color(0xFF4E9E48),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Screen6Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) =>
      _paintCommonHillsAndHouse(canvas, size, showHouse: false, showTopRightLeaves: false);
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Screen7Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintCommonHillsAndHouse(canvas, size, showHouse: true, showTopRightLeaves: false);
    final w = size.width;
    final h = size.height;
    // Large dark green map pin on hill
    canvas.drawCircle(
      Offset(w * 0.66, h * 0.55),
      20,
      Paint()..color = const Color(0xFF0E442D),
    );
    canvas.drawCircle(
      Offset(w * 0.66, h * 0.55),
      8,
      Paint()..color = const Color(0xFFA6D77B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Screen8Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFFBFBF6),
    );
    // Dark green middle band for hero white text
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.36, w, h * 0.32),
      Paint()..color = const Color(0xFF0B3D28),
    );
    // Lower green rolling hills
    final lowerHill = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.5, h * 0.58, w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(lowerHill, Paint()..color = const Color(0xFF5FA83B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
