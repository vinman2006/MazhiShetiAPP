import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/farmer_profile.dart';
import 'screens/onboarding_screens_flow.dart';
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
    _checkAndRestoreActiveSession();
  }

  /// Automatically restores previous session or Google Auth state on app startup
  Future<void> _checkAndRestoreActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool completedOnboarding = prefs.getBool('mazhi_onboarding_completed') ?? false;

      // 1. Check if Firebase / Google User is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        profileState.updateSignUpDetails(
          name: user.displayName ?? (user.email?.split('@').first ?? 'Farmer'),
          mail: user.email,
        );
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          profileState.photoUrl = user.photoURL;
        }
        await FirebaseService.loadFarmerProfile(profileState);
        profileState.setAppStage(2);
        return;
      }

      // 2. Check if local offline user completed registration or skipped
      if (completedOnboarding) {
        final cachedName = prefs.getString('cached_farmer_name');
        final cachedMobile = prefs.getString('cached_farmer_mobile');
        final cachedEmail = prefs.getString('cached_farmer_email');
        if (cachedName != null && cachedName.isNotEmpty) {
          profileState.updateSignUpDetails(
            name: cachedName,
            mobile: cachedMobile,
            mail: cachedEmail,
          );
        }
        profileState.setAppStage(2);
      }
    } catch (e) {
      debugPrint('[Session] Startup session check error: $e');
    }
  }

  void _onProfileStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _persistSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mazhi_onboarding_completed', true);
      if (profileState.fullName.isNotEmpty) {
        await prefs.setString('cached_farmer_name', profileState.fullName);
      }
      if (profileState.mobileNumber.isNotEmpty) {
        await prefs.setString('cached_farmer_mobile', profileState.mobileNumber);
      }
      if (profileState.email.isNotEmpty) {
        await prefs.setString('cached_farmer_email', profileState.email);
      }
    } catch (e) {
      debugPrint('[Session] Persist error: $e');
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await FirebaseService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mazhi_onboarding_completed', false);
      await prefs.remove('cached_farmer_name');
      await prefs.remove('cached_farmer_mobile');
      await prefs.remove('cached_farmer_email');
    } catch (e) {
      debugPrint('[Session] Sign out error: $e');
    }
    profileState.resetProfile();
    profileState.setAppStage(1);
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
        scaffoldBackgroundColor: const Color(0xFFFDFFFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F3D2E),
          primary: const Color(0xFF0F3D2E),
          secondary: const Color(0xFFA7F070),
          surface: const Color(0xFFFDFFFA),
        ),
        fontFamily: 'Inter',
      ),
      home: _buildStageScreen(),
    );
  }

  Widget _buildStageScreen() {
    switch (profileState.activeAppStage) {
      case 1:
        // Step 2: Sign-Up & Farmer Details Collection ("Who Are You etc.")
        return SignupScreen(
          profileState: profileState,
          onBackToOnboarding: () => profileState.setAppStage(0),
          onRegistrationComplete: () {
            _persistSession();
            profileState.setAppStage(2);
          },
        );
      case 2:
        // Step 3: Mazhi Sheti Main App Dashboard
        return PostLoginAppScreen(
          profileState: profileState,
          onSignOut: _handleSignOut,
          onBackToOnboarding: () => profileState.setAppStage(0),
        );
      case 0:
      default:
        // Natural Onboarding Flow (Screens 1 to 6)
        return OnboardingFlowWidget(
          profileState: profileState,
          onProceedToSignUp: () => profileState.setAppStage(1),
          onSkipToApp: () {
            _persistSession();
            profileState.setAppStage(2);
          },
        );
    }
  }
}
