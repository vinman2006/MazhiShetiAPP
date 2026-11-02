import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';
import '../models/farmer_profile.dart';

class GoogleAuthResult {
  final String displayName;
  final String email;
  final String? photoUrl;
  final String uid;
  final bool firebaseLinked;

  const GoogleAuthResult({
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.uid,
    this.firebaseLinked = false,
  });
}

class FirebaseService {
  static bool isInitialized = false;
  static String? initializationError;

  /// Safely initialize Firebase app.
  static Future<void> initialize() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      await Firebase.initializeApp(options: options);
      isInitialized = true;
      initializationError = null;
      debugPrint('[FirebaseService] Live Firebase initialized: ${options.projectId}');
    } catch (e) {
      initializationError = e.toString();
      debugPrint('[FirebaseService] Initialization failed or deferred: $e');
    }
  }

  /// Sign In with Google via Firebase Auth with safe fallback and timeouts
  static Future<GoogleAuthResult?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign in with timeout so user UI never hangs indefinitely
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Google Sign-In prompt timed out. Please try again.'),
      );

      if (googleUser == null) {
        // User closed the account selector dialog
        return null;
      }

      final String displayName = (googleUser.displayName != null && googleUser.displayName!.trim().isNotEmpty)
          ? googleUser.displayName!
          : (googleUser.email.contains('@') ? googleUser.email.split('@').first : 'Farmer');
      final String email = googleUser.email;
      final String? photoUrl = googleUser.photoUrl;
      final String uid = googleUser.id;

      debugPrint('[FirebaseService] Google account selected: $displayName ($email)');

      // Attempt Firebase credential exchange with a safe timeout
      bool linked = false;
      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication.timeout(
          const Duration(seconds: 5),
        );

        if (googleAuth.idToken != null || googleAuth.accessToken != null) {
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final userCred = await FirebaseAuth.instance
              .signInWithCredential(credential)
              .timeout(const Duration(seconds: 5));
          linked = userCred.user != null;
          debugPrint('[FirebaseService] Firebase Auth link successful for: ${userCred.user?.displayName}');
        }
      } catch (authErr) {
        // If SHA-1 verification is pending or network delayed, proceed smoothly with the authenticated Google profile
        debugPrint('[FirebaseService] Firebase credential note: $authErr (Proceeding with Google User)');
      }

      return GoogleAuthResult(
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
        uid: FirebaseAuth.instance.currentUser?.uid ?? uid,
        firebaseLinked: linked,
      );
    } catch (e) {
      debugPrint('[FirebaseService] Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Register farmer with Email & Password in Firebase Authentication
  static Future<UserCredential?> registerFarmerAccount({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      debugPrint('[FirebaseService] Error creating user: $e');
      rethrow;
    }
  }

  /// Sign in with Email & Password
  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      debugPrint('[FirebaseService] Error signing in: $e');
      rethrow;
    }
  }

  /// Sign Out
  static Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }

  /// Save complete Farmer & Land registration profile into Cloud Firestore
  static Future<void> saveFarmerProfile(FarmerProfileState profile) async {
    try {
      if (!isInitialized) return;
      final user = FirebaseAuth.instance.currentUser;
      final docId = user?.uid ?? (profile.email.isNotEmpty ? profile.email : profile.mobileNumber);
      if (docId.isEmpty) return;

      await FirebaseFirestore.instance.collection('farmers').doc(docId).set({
        'uid': user?.uid ?? docId,
        'fullName': profile.fullName,
        'mobileNumber': profile.mobileNumber,
        'email': profile.email,
        'photoUrl': profile.photoUrl,
        'role': profile.selectedRole,
        'state': profile.selectedState,
        'district': profile.selectedDistrict,
        'taluka': profile.taluka,
        'village': profile.village,
        'farmName': profile.farmName,
        'farmSize': profile.selectedFarmSize,
        'landSurveyNo': profile.landSurveyNo,
        'landOwnershipType': profile.landOwnershipType,
        'soilType': profile.soilType.label,
        'irrigationType': profile.irrigationType.label,
        'selectedCrops': profile.selectedCrops.toList(),
        'isPmKisanRegistered': profile.isPmKisanRegistered,
        'isPmFbyInsured': profile.isPmFbyInsured,
        'language': profile.selectedLanguage,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 4));
      debugPrint('[FirebaseService] Profile saved to Firestore for: $docId');
    } catch (e) {
      debugPrint('[FirebaseService] Firestore save error: $e');
    }
  }
}
