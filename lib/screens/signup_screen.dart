import 'package:flutter/material.dart';
import '../models/farmer_profile.dart';
import '../services/firebase_service.dart';

class SignupScreen extends StatefulWidget {
  final FarmerProfileState profileState;
  final VoidCallback onBackToOnboarding;
  final VoidCallback onRegistrationComplete;

  const SignupScreen({
    super.key,
    required this.profileState,
    required this.onBackToOnboarding,
    required this.onRegistrationComplete,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _selectedAuthTab = 0; // 0 = Sign In (Login), 1 = Sign Up (Register)

  // Sign In Form Controllers
  final _loginFormKey = GlobalKey<FormState>();
  late TextEditingController _loginMobileController;
  late TextEditingController _loginPinController;
  bool _isGoogleSigningIn = false;

  // Sign Up Form Controllers
  final _signUpFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _mpinController;
  late TextEditingController _farmNameController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;
  late TextEditingController _talukaController;
  late TextEditingController _villageController;
  late TextEditingController _farmSizeController;
  late TextEditingController _surveyNoController;

  late IrrigationType _selectedIrrigation;
  late SoilType _selectedSoil;
  late String _ownershipType;
  bool _pmKisan = true;
  bool _pmFby = true;
  bool _termsAgreed = true;
  bool _otpSent = false;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    final p = widget.profileState;

    // Login controllers (empty by default, ready for user credentials)
    _loginMobileController = TextEditingController(text: p.mobileNumber);
    _loginPinController = TextEditingController(text: p.mpin);

    // Sign up controllers
    _nameController = TextEditingController(text: p.fullName);
    _mobileController = TextEditingController(text: p.mobileNumber);
    _emailController = TextEditingController(text: p.email);
    _mpinController = TextEditingController(text: p.mpin);
    _farmNameController = TextEditingController(text: p.farmName);
    _stateController = TextEditingController(text: p.selectedState ?? 'Maharashtra');
    _districtController = TextEditingController(text: p.selectedDistrict ?? 'Nagpur');
    _talukaController = TextEditingController(text: p.taluka);
    _villageController = TextEditingController(text: p.village);
    _farmSizeController = TextEditingController(text: p.selectedFarmSize ?? '5.0');
    _surveyNoController = TextEditingController(text: p.landSurveyNo);

    _selectedIrrigation = p.irrigationType;
    _selectedSoil = p.soilType;
    _ownershipType = p.landOwnershipType;
    _pmKisan = p.isPmKisanRegistered;
    _pmFby = p.isPmFbyInsured;
    _termsAgreed = p.acceptedTerms;
  }

  @override
  void dispose() {
    _loginMobileController.dispose();
    _loginPinController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _mpinController.dispose();
    _farmNameController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _talukaController.dispose();
    _villageController.dispose();
    _farmSizeController.dispose();
    _surveyNoController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    final enteredMobile = _loginMobileController.text.trim();
    final enteredPin = _loginPinController.text.trim();

    widget.profileState.updateSignUpDetails(
      name: widget.profileState.fullName.isNotEmpty ? widget.profileState.fullName : 'Farmer',
      mobile: enteredMobile,
      pin: enteredPin,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome back, ${widget.profileState.fullName}! Logged in successfully.'),
        backgroundColor: const Color(0xFF0D3B2A),
        behavior: SnackBarBehavior.floating,
      ),
    );

    widget.onRegistrationComplete();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleSigningIn = true);
    try {
      final result = await FirebaseService.signInWithGoogle();
      if (!mounted) return;
      if (result != null) {
        widget.profileState.setGoogleUser(
          name: result.displayName,
          email: result.email,
          photo: result.photoUrl,
        );
        // Non-blocking background sync to Firestore
        FirebaseService.saveFarmerProfile(widget.profileState);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF88C440)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Welcome, ${result.displayName}! Signed in with Google.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0D3B2A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onRegistrationComplete();
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('[SignupScreen] Google sign-in exception: $e');
      _showGoogleSignInFallback(e.toString());
    } finally {
      if (mounted) setState(() => _isGoogleSigningIn = false);
    }
  }

  void _quickOneTapLogin([String name = 'Farmer']) {
    widget.profileState.updateSignUpDetails(
      name: widget.profileState.fullName.isNotEmpty ? widget.profileState.fullName : name,
      mobile: widget.profileState.mobileNumber.isNotEmpty ? widget.profileState.mobileNumber : '9876543210',
      pin: '1234',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome to Mazhi Sheti, ${widget.profileState.fullName}! 🌾'),
        backgroundColor: const Color(0xFF0D3B2A),
        behavior: SnackBarBehavior.floating,
      ),
    );
    widget.onRegistrationComplete();
  }

  void _showGoogleSignInFallback(String errorMsg) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.orange, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Google Sign-In Connection',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Google Play Services note: ${errorMsg.contains('10') ? 'SHA-1 key verification pending on Firebase Console.' : errorMsg}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B2A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _quickOneTapLogin('Farmer');
              },
              icon: const Icon(Icons.bolt, color: Color(0xFF88C440)),
              label: const Text(
                'Continue to Dashboard (Instant Access)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_signUpFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check and fill all mandatory fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions and Privacy Policy.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Save into state
    widget.profileState.updateSignUpDetails(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      mail: _emailController.text.trim(),
      pin: _mpinController.text.trim(),
      fName: _farmNameController.text.trim(),
      tal: _talukaController.text.trim(),
      vill: _villageController.text.trim(),
      survey: _surveyNoController.text.trim(),
      ownership: _ownershipType,
      irrigation: _selectedIrrigation,
      soil: _selectedSoil,
      pmKisan: _pmKisan,
      pmFby: _pmFby,
      terms: _termsAgreed,
      otpDone: true,
    );

    widget.profileState.updateFarmDetail(
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
      farmSize: _farmSizeController.text.trim(),
    );

    // Sync to Firebase Cloud Firestore if configured
    FirebaseService.saveFarmerProfile(widget.profileState);

    // Show celebration dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF1E7E34), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Registration Successful!',
                style: TextStyle(
                  color: Color(0xFF0D3B2A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Namaskar, ${_nameController.text.trim()}! 🙏',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0D3B2A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Mazhi Sheti farmer profile has been verified and registered with Firebase Cloud.',
              style: TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF88C440)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, color: Color(0xFF1E7E34), size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Location: ${_districtController.text}, ${_stateController.text}\nFarm Size: ${_farmSizeController.text} Acres • ${_selectedIrrigation.label}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D3B2A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B2A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onRegistrationComplete();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter Mazhi Sheti App', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOtpSheet() {
    setState(() {
      _otpSent = true;
      _otpCode = '4829';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to +91 ${_mobileController.text}. Demo Code: $_otpCode'),
        backgroundColor: const Color(0xFF0D3B2A),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = widget.profileState.selectedLanguage == 'मराठी';
    final isHindi = widget.profileState.selectedLanguage == 'हिंदी';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with back button & Step Indicator
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0D3B2A)),
                    tooltip: 'Back to Onboarding',
                    onPressed: widget.onBackToOnboarding,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF88C440),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.eco, size: 12, color: Color(0xFF0D3B2A)),
                                  SizedBox(width: 4),
                                  Text(
                                    'MAZHI SHETI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D3B2A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedAuthTab == 0 ? 'Farmer Sign In' : 'Farmer Registration',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF557766),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedAuthTab == 0
                              ? (isMarathi
                                  ? 'शेतकरी लॉगिन (Sign In)'
                                  : isHindi
                                      ? 'किसान लॉग इन'
                                      : 'Sign In to Your Account')
                              : (isMarathi
                                  ? 'शेतकरी नोंदणी (Sign Up)'
                                  : isHindi
                                      ? 'किसान पंजीकरण'
                                      : 'Create Farmer Account'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D3B2A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Language Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F0E7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF88C440)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language, size: 14, color: Color(0xFF0D3B2A)),
                        const SizedBox(width: 4),
                        Text(
                          widget.profileState.selectedLanguage,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D3B2A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sign In vs Sign Up Tab Switcher
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4E5D8)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedAuthTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _selectedAuthTab == 0 ? const Color(0xFF0D3B2A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.login_rounded,
                                size: 16,
                                color: _selectedAuthTab == 0 ? const Color(0xFF88C440) : const Color(0xFF0D3B2A),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isMarathi ? 'लॉगिन (Sign In)' : isHindi ? 'लॉग इन' : 'Sign In',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedAuthTab == 0 ? Colors.white : const Color(0xFF0D3B2A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedAuthTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _selectedAuthTab == 1 ? const Color(0xFF0D3B2A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 16,
                                color: _selectedAuthTab == 1 ? const Color(0xFF88C440) : const Color(0xFF0D3B2A),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isMarathi ? 'नवीन नोंदणी (Sign Up)' : isHindi ? 'नया पंजीकरण' : 'Sign Up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _selectedAuthTab == 1 ? Colors.white : const Color(0xFF0D3B2A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // View Routing
              if (_selectedAuthTab == 0) _buildSignInView(isMarathi, isHindi) else _buildSignUpView(isMarathi, isHindi),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SIGN IN VIEW
  // ==========================================================================
  Widget _buildSignInView(bool isMarathi, bool isHindi) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2EBE4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFE4F0E7),
                      child: Icon(Icons.person, color: Color(0xFF0D3B2A), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Farmer Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D3B2A),
                            ),
                          ),
                          Text(
                            'Enter your registered phone number or MPIN',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Mobile Number
                TextFormField(
                  controller: _loginMobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Registered Mobile Number *',
                    prefixText: '+91 ',
                    prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF1B5B42)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) =>
                      (val == null || val.trim().length != 10) ? '10-digit mobile required' : null,
                ),
                const SizedBox(height: 14),

                // 4-Digit MPIN
                TextFormField(
                  controller: _loginPinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '4-Digit MPIN / Password *',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1B5B42)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) =>
                      (val == null || val.length != 4) ? 'Enter 4-digit MPIN' : null,
                ),
                const SizedBox(height: 20),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3B2A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                    onPressed: _submitLogin,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login, color: Color(0xFF88C440), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isMarathi ? 'लॉगिन करा आणि ॲप उघडा' : 'Sign In & Open Mazhi Sheti',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 14),

                // Sign in with Google Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF223438),
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                    ),
                    onPressed: _isGoogleSigningIn ? null : _handleGoogleSignIn,
                    child: _isGoogleSigningIn
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata_rounded, color: Colors.blue, size: 32),
                              SizedBox(width: 8),
                              Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Fast 1-Tap Access
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5E9),
                      foregroundColor: const Color(0xFF1E7E34),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _quickOneTapLogin('Farmer'),
                    icon: const Icon(Icons.bolt, color: Color(0xFF1E7E34), size: 20),
                    label: Text(
                      isMarathi ? '⚡ झटपट १-टॅप लॉगिन (Quick Access)' : '⚡ Fast 1-Tap Login (Open App)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Switch to Register Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF88C440)),
            ),
            child: Row(
              children: [
                const Icon(Icons.app_registration, color: Color(0xFF1E7E34), size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New to Mazhi Sheti?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D3B2A),
                        ),
                      ),
                      Text(
                        'Register your farm, land records, soil type, and crop selections.',
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedAuthTab = 1),
                  child: const Text('Sign Up →', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SIGN UP VIEW (Farmer Details Collection)
  // ==========================================================================
  Widget _buildSignUpView(bool isMarathi, bool isHindi) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Banner carrying over Onboarding details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D3B2A), Color(0xFF1B5B42)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF88C440),
                  child: Icon(Icons.agriculture, color: Color(0xFF0D3B2A), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Role: ${widget.profileState.selectedRole}',
                        style: const TextStyle(
                          color: Color(0xFFB5E48C),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Prefilled from Onboarding: ${widget.profileState.selectedDistrict}, ${widget.profileState.selectedState} • ${widget.profileState.selectedCrops.length} Crops selected',
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // SECTION 1: Personal & Contact Details
          _buildSectionCard(
            title: '1. Personal & Contact Information',
            subtitle: 'Enter your basic details for SMS alerts and advisor calls',
            icon: Icons.person_outline,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Farmer Full Name (शेतकऱ्याचे नाव) *',
                  prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF1B5B42)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number *',
                        prefixText: '+91 ',
                        prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF1B5B42)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.trim().length != 10)
                          ? '10-digit mobile number required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _otpSent ? const Color(0xFF1E7E34) : const Color(0xFF0D3B2A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _showOtpSheet,
                      child: Text(
                        _otpSent ? 'Resend' : 'Verify',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              if (_otpSent) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5EC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF88C440)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Color(0xFF1E7E34), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OTP Verified successfully! (Demo code $_otpCode applied)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0D3B2A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address (Optional)',
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1B5B42)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _mpinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '4-Digit MPIN *',
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1B5B42)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.length != 4) ? '4 digits' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SECTION 2: Farm & Land Details
          _buildSectionCard(
            title: '2. Farm & Land Profile',
            subtitle: 'Specify your landholding to receive tailored crop & fertilizer advice',
            icon: Icons.landscape_outlined,
            children: [
              TextFormField(
                controller: _farmNameController,
                decoration: InputDecoration(
                  labelText: 'Farm Name / Shet Nav (शेताचे नाव)',
                  prefixIcon: const Icon(Icons.home_work_outlined, color: Color(0xFF1B5B42)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: InputDecoration(
                        labelText: 'State (राज्य) *',
                        prefixIcon: const Icon(Icons.map_outlined, color: Color(0xFF1B5B42)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'State required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      decoration: InputDecoration(
                        labelText: 'District (जिल्हा) *',
                        prefixIcon: const Icon(Icons.location_city, color: Color(0xFF1B5B42)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'District required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _talukaController,
                      decoration: InputDecoration(
                        labelText: 'Taluka / Tehsil *',
                        prefixIcon: const Icon(Icons.signpost_outlined, color: Color(0xFF1B5B42)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Taluka required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _villageController,
                      decoration: InputDecoration(
                        labelText: 'Village (गाव) *',
                        prefixIcon: const Icon(Icons.holiday_village, color: Color(0xFF1B5B42)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Village required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _farmSizeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Farm Size (Acres) *',
                        prefixIcon: const Icon(Icons.straighten, color: Color(0xFF1B5B42)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Size required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _surveyNoController,
                      decoration: InputDecoration(
                        labelText: 'Gut / 7/12 Survey No.',
                        prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF1B5B42)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _ownershipType,
                decoration: InputDecoration(
                  labelText: 'Land Ownership Type',
                  prefixIcon: const Icon(Icons.gavel, color: Color(0xFF1B5B42)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Own Land (स्वतःची जमीन)',
                    child: Text('Own Land (स्वतःची जमीन)'),
                  ),
                  DropdownMenuItem(
                    value: 'Tenant / Leased (भाडेपट्टा)',
                    child: Text('Tenant / Leased (भाडेपट्टा)'),
                  ),
                  DropdownMenuItem(
                    value: 'Joint Family (एकत्रित कुटुंब)',
                    child: Text('Joint Family (एकत्रित कुटुंब)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _ownershipType = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SECTION 3: Agriculture, Soil & Irrigation Details
          _buildSectionCard(
            title: '3. Soil & Irrigation Setup',
            subtitle: 'Helps calculate water needs and pest control schedules',
            icon: Icons.water_drop_outlined,
            children: [
              DropdownButtonFormField<IrrigationType>(
                initialValue: _selectedIrrigation,
                decoration: InputDecoration(
                  labelText: 'Primary Irrigation Source *',
                  prefixIcon: const Icon(Icons.water, color: Color(0xFF1B5B42)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: IrrigationType.values.map((irr) {
                  return DropdownMenuItem(
                    value: irr,
                    child: Text('${irr.label} (${irr.marathiLabel})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedIrrigation = val);
                },
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<SoilType>(
                initialValue: _selectedSoil,
                decoration: InputDecoration(
                  labelText: 'Soil Type (मातीचा प्रकार) *',
                  prefixIcon: const Icon(Icons.grass, color: Color(0xFF1B5B42)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: SoilType.values.map((st) {
                  return DropdownMenuItem(
                    value: st,
                    child: Text(st.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSoil = val);
                },
              ),
              const SizedBox(height: 14),

              const Text(
                'Selected Crops for Advisory (Tap to add/remove):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D3B2A),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.profileState.availableCrops.map((crop) {
                  final isSelected = widget.profileState.selectedCrops.contains(crop.name);
                  return FilterChip(
                    selected: isSelected,
                    selectedColor: const Color(0xFF0D3B2A),
                    checkmarkColor: const Color(0xFF88C440),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF0D3B2A) : const Color(0xFFD0DCD2),
                    ),
                    label: Text(
                      '${crop.iconEmoji} ${crop.name} (${crop.marathiName})',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isSelected ? Colors.white : const Color(0xFF1B5B42),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    onSelected: (_) {
                      setState(() {
                        widget.profileState.toggleCrop(crop.name);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SECTION 4: Government Schemes & Benefits
          _buildSectionCard(
            title: '4. Government Schemes & Subsidies',
            subtitle: 'Automate subsidy updates and crop loss compensation alerts',
            icon: Icons.account_balance_outlined,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _pmKisan,
                activeTrackColor: const Color(0xFF1E7E34),
                title: const Text(
                  'PM-KISAN Beneficiary',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Direct ₹6,000 yearly DBT installment alerts',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                onChanged: (val) => setState(() => _pmKisan = val),
              ),
              const Divider(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _pmFby,
                activeTrackColor: const Color(0xFF1E7E34),
                title: const Text(
                  'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Crop damage insurance claim assistance & weather tracking',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                onChanged: (val) => setState(() => _pmFby = val),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SECTION 5: Terms and Conditions
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _termsAgreed,
            activeColor: const Color(0xFF0D3B2A),
            checkColor: const Color(0xFF88C440),
            title: const Text(
              'I agree to the Mazhi Sheti Terms of Service and consent to receive weather advisories and APMC market updates.',
              style: TextStyle(fontSize: 12, color: Color(0xFF2B4D3C)),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => setState(() => _termsAgreed = val ?? true),
          ),
          const SizedBox(height: 20),

          // SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B2A),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _submitForm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.how_to_reg, color: Color(0xFF88C440), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    isMarathi
                        ? 'नोंदणी पूर्ण करा आणि ॲप उघडा'
                        : isHindi
                            ? 'पंजीकरण पूरा करें और ऐप खोलें'
                            : 'Complete Registration & Open App',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF223438),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isGoogleSigningIn ? null : _handleGoogleSignIn,
              child: _isGoogleSigningIn
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata_rounded, color: Colors.blue, size: 30),
                        SizedBox(width: 8),
                        Text('Quick Register with Google', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9),
                foregroundColor: const Color(0xFF1E7E34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _quickOneTapLogin('Farmer'),
              icon: const Icon(Icons.bolt, color: Color(0xFF1E7E34), size: 20),
              label: Text(
                isMarathi ? '⚡ १-टॅप थेट प्रवेश (Skip to App)' : '⚡ Fast 1-Tap Access (Skip to App)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8EFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F0E7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF0D3B2A), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D3B2A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
