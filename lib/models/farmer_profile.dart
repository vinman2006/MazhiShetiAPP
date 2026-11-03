import 'package:flutter/material.dart';

enum UserRole {
  farmer('Farmer', 'शेतकरी', Icons.agriculture),
  landOwner('Land Owner', 'जमीन मालक', Icons.landscape),
  agriStudent('Agriculture Student', 'कृषी विद्यार्थी', Icons.school),
  advisor('Advisor / Expert', 'सल्लागार / तज्ज्ञ', Icons.support_agent);

  final String englishLabel;
  final String marathiLabel;
  final IconData icon;
  const UserRole(this.englishLabel, this.marathiLabel, this.icon);
}

enum IrrigationType {
  drip('Drip Irrigation', 'ठिबक सिंचन'),
  sprinkler('Sprinkler', 'तुषार सिंचन'),
  borewell('Borewell / Well', 'कूपनलिका / विहीर'),
  canal('Canal / River', 'कालवा / नदी'),
  rainfed('Rainfed / Monsoon', 'पावसावर आधारित');

  final String label;
  final String marathiLabel;
  const IrrigationType(this.label, this.marathiLabel);
}

enum SoilType {
  blackCotton('Black Cotton Soil (काळी माती)', 'काळी कसदार जमीन'),
  redSoil('Red Soil (तांबडी माती)', 'तांबडी जमीन'),
  loamy('Alluvial / Loamy (गाळाची माती)', 'गाळाची जमीन'),
  sandyLoam('Sandy Loam (वाळूमिश्रित माती)', 'हलकी जमीन');

  final String label;
  final String marathiLabel;
  const SoilType(this.label, this.marathiLabel);
}

class CropItemData {
  final String name;
  final String marathiName;
  final String iconEmoji;
  final String season;

  const CropItemData(this.name, this.marathiName, this.iconEmoji, this.season);
}

/// Comprehensive model holding all registration and profile details for the user.
class FarmerProfileState extends ChangeNotifier {
  // Navigation state across the 3 main workflow stages:
  // 0 = Step 1: 8-Screen Onboarding
  // 1 = Step 2: Sign-Up & Farmer Details Collection
  // 2 = Step 3: Mazhi Sheti Main App
  int activeAppStage = 0;

  // Onboarding screen index (0..7)
  int currentOnboardingScreen = 0;
  bool showGridOverview = false;

  // STEP 1 DETAILS (Collected during Onboarding)
  String selectedLanguage = 'English'; // English, मराठी, हिंदी
  String selectedRole = 'Farmer';
  String? selectedState = 'Maharashtra';
  String? selectedDistrict = 'Nagpur';
  String? selectedFarmSize = '5.0';
  String? selectedMainCrop = 'Cotton';
  final Set<String> grantedPermissions = {'Location', 'Camera', 'Notifications'};
  final Set<String> selectedCrops = {'Cotton', 'Soybean', 'Rice'};
  String selectedLocation = 'Nagpur, Maharashtra';

  // STEP 2 DETAILS (Collected on Sign-Up Page or Google Sign-In)
  String fullName = '';
  String mobileNumber = '';
  String email = '';
  String? photoUrl;
  String mpin = '';
  String farmName = '';
  String taluka = 'Hingna';
  String village = 'Wanadongri';
  String landSurveyNo = 'Gut No. 142/2';
  String landOwnershipType = 'Own Land (स्वतःची जमीन)';
  IrrigationType irrigationType = IrrigationType.drip;
  SoilType soilType = SoilType.blackCotton;
  bool isPmKisanRegistered = true;
  bool isPmFbyInsured = true;
  bool acceptedTerms = true;
  bool isOtpVerified = false;

  void setGoogleUser({required String name, required String email, String? photo}) {
    fullName = name;
    this.email = email;
    photoUrl = photo;
    isOtpVerified = true;
    notifyListeners();
  }

  // Available crops list
  final List<CropItemData> availableCrops = [
    const CropItemData('Cotton', 'कापूस', '🌱', 'Kharif'),
    const CropItemData('Soybean', 'सोयाबीन', '🌿', 'Kharif'),
    const CropItemData('Rice', 'भात (तांदूळ)', '🌾', 'Kharif'),
    const CropItemData('Wheat', 'गहू', '🌾', 'Rabi'),
    const CropItemData('Sugarcane', 'ऊस', '🎋', 'Annual'),
    const CropItemData('Maize', 'मका', '🌽', 'Kharif / Rabi'),
    const CropItemData('Tur / Pigeon Pea', 'तूर', '🌱', 'Kharif'),
    const CropItemData('Groundnut', 'भुईमूग', '🥜', 'Kharif / Summer'),
    const CropItemData('Gram / Harbara', 'हरभरा (चना)', '🌰', 'Rabi'),
    const CropItemData('Onion', 'कांदा', '🧅', 'Rabi / Late Kharif'),
  ];

  // Stage Switchers
  void setAppStage(int stage) {
    activeAppStage = stage.clamp(0, 2);
    notifyListeners();
  }

  void goToOnboardingScreen(int index) {
    currentOnboardingScreen = index.clamp(0, 7);
    showGridOverview = false;
    notifyListeners();
  }

  void toggleOverview() {
    showGridOverview = !showGridOverview;
    notifyListeners();
  }

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
    final clean = cropName.trim();
    if (clean.isEmpty) return;
    if (!availableCrops.any((c) => c.name.toLowerCase() == clean.toLowerCase())) {
      availableCrops.add(CropItemData(clean, clean, '🌱', 'Seasonal'));
    }
    selectedCrops.add(clean);
    notifyListeners();
  }

  void setLocation(String loc) {
    selectedLocation = loc;
    notifyListeners();
  }

  // Update Sign Up Details
  void updateSignUpDetails({
    String? name,
    String? mobile,
    String? mail,
    String? pin,
    String? fName,
    String? tal,
    String? vill,
    String? survey,
    String? ownership,
    IrrigationType? irrigation,
    SoilType? soil,
    bool? pmKisan,
    bool? pmFby,
    bool? terms,
    bool? otpDone,
  }) {
    if (name != null) fullName = name;
    if (mobile != null) mobileNumber = mobile;
    if (mail != null) email = mail;
    if (pin != null) mpin = pin;
    if (fName != null) farmName = fName;
    if (tal != null) taluka = tal;
    if (vill != null) village = vill;
    if (survey != null) landSurveyNo = survey;
    if (ownership != null) landOwnershipType = ownership;
    if (irrigation != null) irrigationType = irrigation;
    if (soil != null) soilType = soil;
    if (pmKisan != null) isPmKisanRegistered = pmKisan;
    if (pmFby != null) isPmFbyInsured = pmFby;
    if (terms != null) acceptedTerms = terms;
    if (otpDone != null) isOtpVerified = otpDone;
    notifyListeners();
  }

  void resetProfile() {
    activeAppStage = 0;
    currentOnboardingScreen = 0;
    fullName = '';
    mobileNumber = '';
    email = '';
    photoUrl = null;
    mpin = '';
    farmName = '';
    isOtpVerified = false;
    notifyListeners();
  }
}

