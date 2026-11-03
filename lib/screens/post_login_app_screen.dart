import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/farmer_profile.dart';
import 'interactive_farm_map_screen.dart';
import 'crop_advice_screen.dart';
import 'weather_detail_screen.dart';
import 'market_prices_screen.dart';
import 'crop_scanner_screen.dart';
import 'learn_screen.dart';
import 'community_screen.dart';

// ============================================================================
// EXACT COLOR PALETTE SAMPLED PIXEL-FOR-PIXEL FROM REFERENCE IMAGE (1024x682)
// ============================================================================
class ExactColors {
  static const Color scaffoldBg = Color(0xFFF9FCF7);
  static const Color headerDarkGreen = Color(0xFF072A2C);
  static const Color primaryFabGreen = Color(0xFF044D3D);
  static const Color aiSendGreen = Color(0xFF054F3E);
  static const Color bodyText = Color(0xFF223438);
  static const Color mutedText = Color(0xFF798088);
  static const Color navInactive = Color(0xFF96A0A9);

  // Screen 1 Card Surfaces
  static const Color featureCardBg = Color(0xFFF6FEF1);
  static const Color featureCardBorder = Color(0xFFEAF2E7);
  static const Color harvestBannerBg = Color(0xFFD6F0C1);

  // Screen 2 Card Surfaces
  static const Color weatherTopCardBg = Color(0xFFFAFBF8);
  static const Color goodCondCardBg = Color(0xFFF2FDEF);
  static const Color myFieldsCardBg = Color(0xFFDEF8D1);
  static const Color insightsBlueCardBg = Color(0xFFEBF5FE);
  static const Color quickActionBg = Color(0xFFFFFFFF);

  // Screen 3 Card Surfaces
  static const Color aiContainerBg = Color(0xFFF1F6EF);
  static const Color aiPromptPillBg = Color(0xFFFCFDF9);
  static const Color marketCardBg = Color(0xFFFCFDFB);
  static const Color trendUpGreen = Color(0xFF1D8348);
  static const Color trendDownRed = Color(0xFFD93829);
}

class PostLoginAppScreen extends StatefulWidget {
  final FarmerProfileState profileState;
  final VoidCallback onSignOut;
  final VoidCallback onBackToOnboarding;

  const PostLoginAppScreen({
    super.key,
    required this.profileState,
    required this.onSignOut,
    required this.onBackToOnboarding,
  });

  @override
  State<PostLoginAppScreen> createState() => _PostLoginAppScreenState();
}

class _PostLoginAppScreenState extends State<PostLoginAppScreen> {
  // 0 = Home, 1 = Insights, 2 = Market / AI
  int _activeNavIndex = 0;
  final TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _navigateToTab(int index) {
    if (index == 3) {
      _showProfileSheet();
      return;
    }
    setState(() {
      _activeNavIndex = index.clamp(0, 2);
    });
  }

  void _handleSearchQuery(String query, BuildContext ctx) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;
    Navigator.pop(ctx);
    if (q.contains('weather') || q.contains('rain') || q.contains('forecast') || q.contains('temp')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherDetailScreen()));
    } else if (q.contains('market') || q.contains('price') || q.contains('mandi') || q.contains('rate') || q.contains('bhav')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketPricesScreen()));
    } else if (q.contains('map') || q.contains('field') || q.contains('land') || q.contains('acre') || q.contains('survey')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => InteractiveFarmMapScreen(profileState: widget.profileState)));
    } else if (q.contains('scan') || q.contains('pest') || q.contains('leaf') || q.contains('disease') || q.contains('camera')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CropScannerScreen()));
    } else if (q.contains('community') || q.contains('farmer') || q.contains('chat') || q.contains('group')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityScreen(profileState: widget.profileState)));
    } else if (q.contains('learn') || q.contains('video') || q.contains('guide')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CropAdviceScreen()));
    }
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: ExactColors.primaryFabGreen, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Notifications & Farm Alerts',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ExactColors.headerDarkGreen,
                  ),
                ),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              title: 'Weather & Spray Advisory',
              subtitle: '26°C–32°C with 58% humidity. Ideal foliar spraying window between 07:00 AM – 10:30 AM.',
              badge: 'Agronomy',
              badgeColor: Colors.green,
              actionLabel: 'View Weather',
              onAction: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherDetailScreen()));
              },
            ),
            const SizedBox(height: 10),
            _buildNotificationCard(
              title: 'Mandi Price Gain (+2.4%)',
              subtitle: 'Soybean touched ₹4,892/quintal in Nagpur APMC. Upward demand from local oil mills.',
              badge: 'Market Alert',
              badgeColor: Colors.orange,
              actionLabel: 'Check Mandi',
              onAction: () {
                Navigator.pop(ctx);
                setState(() => _activeNavIndex = 2);
              },
            ),
            const SizedBox(height: 10),
            _buildNotificationCard(
              title: 'Aerial Drone Survey Ready',
              subtitle: 'Flight log processed: Canopy NDVI 0.78 indicates healthy vegetative crop growth.',
              badge: 'Drone Telemetry',
              badgeColor: Colors.blue,
              actionLabel: 'View Telemetry',
              onAction: () {
                Navigator.pop(ctx);
                _showTrackProgressSheet();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ExactColors.featureCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6F0C1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                onPressed: onAction,
                child: Text(actionLabel, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: ExactColors.primaryFabGreen)),
              ),
            ],
          ),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ExactColors.headerDarkGreen)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11.5, color: ExactColors.mutedText, height: 1.3)),
        ],
      ),
    );
  }

  void _showTrackProgressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.flight_takeoff_rounded, color: ExactColors.primaryFabGreen, size: 26),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Drone Progress & Aerial Monitoring',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: ExactColors.headerDarkGreen,
                    ),
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/screen_8_bg.jpg',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/s2_tool_track_hd.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ExactColors.featureCardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6F0C1)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Canopy NDVI', style: TextStyle(fontSize: 11, color: ExactColors.mutedText)),
                        SizedBox(height: 4),
                        Text('0.78', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ExactColors.primaryFabGreen)),
                        Text('Dense & Healthy', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ExactColors.featureCardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6F0C1)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Canopy Closure', style: TextStyle(fontSize: 11, color: ExactColors.mutedText)),
                        SizedBox(height: 4),
                        Text('84%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ExactColors.headerDarkGreen)),
                        Text('Optimal Coverage', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5EDE2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Latest Aerial Flight Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildProgressRow('Flight Survey Time', 'Today, 07:15 AM'),
                  _buildProgressRow('Sensor Type', 'Multispectral 12MP (NIR + RGB)'),
                  _buildProgressRow('Field 1 (Cotton - 2.4 Ac)', 'NDVI 0.81 • Peak Vigor'),
                  _buildProgressRow('Field 2 (Soybean - 1.8 Ac)', 'NDVI 0.74 • Uniform Growth'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ExactColors.primaryFabGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Schedule Next Drone Flight', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Drone flight scheduled for tomorrow morning at 07:00 AM.'),
                      backgroundColor: ExactColors.primaryFabGreen,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: ExactColors.mutedText)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ExactColors.headerDarkGreen)),
        ],
      ),
    );
  }

  String _generateAgronomyResponse(String query) {
    final q = query.toLowerCase();
    final p = widget.profileState;
    final farmerName = p.fullName.isNotEmpty ? p.fullName : 'Farmer';
    final location = p.selectedLocation.isNotEmpty ? p.selectedLocation : 'Nagpur, Maharashtra';

    if (q.contains('cotton') || q.contains('kapas')) {
      return 'Cotton Advisory for $farmerName:\n'
          '• Pest Watch: Monitor for Pink Bollworm using pheromone traps (5/acre). If rosette flowers exceed 5%, spray Profenofos 50% EC @ 2 mL/L.\n'
          '• Current APMC Price: ₹6,150 / quintal (↑ 3.2%) in $location.\n'
          '• Irrigation: Maintain light moisture during boll formation; avoid waterlogging.';
    }
    if (q.contains('wheat') || q.contains('gehu')) {
      return 'Wheat Advisory for $farmerName:\n'
          '• Sowing Window: Optimal window is November 1–15 with varieties Lok-1 or GW-322.\n'
          '• Fertilizer: 50 kg DAP + 30 kg MOP basal per acre. Top-dress Urea in two splits at 21 & 45 DAS.\n'
          '• Market Rate: ₹2,425 / quintal in local APMC.';
    }
    if (q.contains('soybean') || q.contains('soyabean')) {
      return 'Soybean Advisory for $farmerName:\n'
          '• Disease Alert: Spray Mancozeb 75% WP @ 2.5 g/L to manage Cercospora leaf spot.\n'
          '• Harvest Moisture: Harvest when pod moisture drops to 13–15% to avoid pod shattering.\n'
          '• Market Rate: Trading strong at ₹4,892 / quintal (↑ 2.4%).';
    }
    if (q.contains('price') || q.contains('mandi') || q.contains('bhav') || q.contains('rate') || q.contains('market')) {
      return 'Live Mandi Price Rates for $location:\n'
          '• Soybean: ₹4,892 / qtl (↑ 2.4%)\n'
          '• Cotton: ₹6,150 / qtl (↑ 3.2%)\n'
          '• Wheat: ₹2,425 / qtl (↓ 1.1%)\n'
          '• Maize: ₹1,980 / qtl (↑ 0.8%)\n'
          'Peak buyer volume is active between 10:00 AM and 01:00 PM.';
    }
    if (q.contains('weather') || q.contains('rain') || q.contains('havaman') || q.contains('forecast') || q.contains('temp')) {
      return 'Weather Forecast for $location:\n'
          '• Day Temp: 26°C – 32°C (Partly Cloudy)\n'
          '• Humidity: 58% • Soil Moisture: 68%\n'
          '• Rain Risk: Low (<10%) over next 48 hours\n'
          '• Best Spray Window: 07:00 AM – 10:30 AM before wind speed picks up.';
    }
    if (q.contains('fertilizer') || q.contains('khad') || q.contains('urea') || q.contains('dap') || q.contains('npk')) {
      return 'Nutrient Management (${p.selectedFarmSize ?? "5.0"} Acres - ${p.soilType.label}):\n'
          '• Basal Dose: 50 kg DAP + 30 kg MOP per acre at sowing.\n'
          '• Top Dressing: 45 kg Urea split across vegetative stages.\n'
          '• Micronutrient: Apply 10 kg Zinc Sulphate (21%) for root strength and chlorophyll synthesis.';
    }
    return 'AI Agronomist Diagnosis for $farmerName ($location):\n'
        'Based on your registered crops (${p.selectedCrops.join(', ')}) and soil moisture (68%), field conditions are favorable. '
        'For specific recommendations, you can ask about pest symptoms, fertilizer doses, weather spraying windows, or live mandi rates.';
  }

  void _showSearchSheet() {
    final searchCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search, color: ExactColors.primaryFabGreen),
                const SizedBox(width: 8),
                const Text(
                  'Search Crops, Advice, or Tools',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ExactColors.headerDarkGreen,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchCtrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (query) => _handleSearchQuery(query, ctx),
              decoration: InputDecoration(
                hintText: 'e.g. Soybean leaf spot, Wheat Mandi price, Drip timing...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic, color: ExactColors.primaryFabGreen),
                      onPressed: () {
                        searchCtrl.text = 'Best fertilizer dose for Soybean';
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: ExactColors.primaryFabGreen),
                      onPressed: () => _handleSearchQuery(searchCtrl.text, ctx),
                    ),
                  ],
                ),
                filled: true,
                fillColor: ExactColors.featureCardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFD6F0C1)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Trending Searches:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ExactColors.mutedText),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('🌿 Soybean Agronomy Advice', style: TextStyle(fontSize: 12)),
                  backgroundColor: ExactColors.featureCardBg,
                  side: const BorderSide(color: Color(0xFFD6F0C1)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CropAdviceScreen()));
                  },
                ),
                ActionChip(
                  label: const Text('📊 Live Mandi Market Prices', style: TextStyle(fontSize: 12)),
                  backgroundColor: ExactColors.featureCardBg,
                  side: const BorderSide(color: Color(0xFFD6F0C1)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketPricesScreen()));
                  },
                ),
                ActionChip(
                  label: const Text('🗺️ GPS Field Boundary Map', style: TextStyle(fontSize: 12)),
                  backgroundColor: ExactColors.featureCardBg,
                  side: const BorderSide(color: Color(0xFFD6F0C1)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InteractiveFarmMapScreen(profileState: widget.profileState)),
                    );
                  },
                ),
                ActionChip(
                  label: const Text('🌤️ 7-Day Agro Weather Forecast', style: TextStyle(fontSize: 12)),
                  backgroundColor: ExactColors.featureCardBg,
                  side: const BorderSide(color: Color(0xFFD6F0C1)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherDetailScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAiQuestionSheet(String prompt, String answer) {
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
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: ExactColors.primaryFabGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Mazhi Sheti AI Agronomist',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ExactColors.headerDarkGreen,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ExactColors.aiContainerBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Q: $prompt',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: ExactColors.headerDarkGreen),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              answer,
              style: const TextStyle(fontSize: 14, height: 1.5, color: ExactColors.bodyText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ExactColors.primaryFabGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Ask Another Question', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomAiDialog() {
    _questionController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_rounded, color: ExactColors.primaryFabGreen, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Ask Mazhi Sheti AI',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ExactColors.headerDarkGreen,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              autofocus: true,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                final q = _questionController.text.trim();
                if (q.isEmpty) return;
                Navigator.pop(ctx);
                _showAiQuestionSheet(q, _generateAgronomyResponse(q));
              },
              decoration: InputDecoration(
                hintText: 'Type your farming question here...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, color: ExactColors.primaryFabGreen),
                  onPressed: () {
                    final q = _questionController.text.trim();
                    if (q.isEmpty) return;
                    Navigator.pop(ctx);
                    _showAiQuestionSheet(q, _generateAgronomyResponse(q));
                  },
                ),
                filled: true,
                fillColor: ExactColors.featureCardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFD6F0C1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileSheet() {
    final p = widget.profileState;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                ClipOval(
                  child: p.photoUrl != null && p.photoUrl!.isNotEmpty
                      ? Image.network(
                          p.photoUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarFallbackLarge(p),
                        )
                      : (p.fullName.toLowerCase().contains('vineet')
                          ? Image.asset(
                              'assets/images/avatar_vineet.jpg',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildAvatarFallbackLarge(p),
                            )
                          : _buildAvatarFallbackLarge(p)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.fullName.isNotEmpty ? p.fullName : 'Farmer User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ExactColors.headerDarkGreen,
                        ),
                      ),
                      if (p.email.isNotEmpty)
                        Text(
                          p.email,
                          style: const TextStyle(fontSize: 12, color: ExactColors.mutedText),
                        ),
                      if (p.mobileNumber.isNotEmpty)
                        Text(
                          '+91 ${p.mobileNumber}',
                          style: const TextStyle(fontSize: 12, color: ExactColors.mutedText),
                        ),
                      Text(
                        '${p.selectedDistrict ?? "Nagpur"}, ${p.selectedState ?? "Maharashtra"}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ExactColors.primaryFabGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 8),
            _buildProfileRow('Farm Name:', p.farmName.isNotEmpty ? p.farmName : 'Krishi Seva Farm'),
            _buildProfileRow('Total Fields:', '5 Active GPS Fields (10.8 Acres Total)'),
            _buildProfileRow('Primary Crops:', p.selectedCrops.join(', ')),
            _buildProfileRow('Soil Type:', p.soilType.label),
            _buildProfileRow('Irrigation:', p.irrigationType.label),
            _buildProfileRow('Land Survey 7/12:', p.landSurveyNo),
            _buildProfileRow('Language:', p.selectedLanguage),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: ExactColors.headerDarkGreen,
                  side: const BorderSide(color: ExactColors.headerDarkGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onBackToOnboarding();
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Replay Onboarding Screens (1-6)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onSignOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out of Mazhi Sheti', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    final name = widget.profileState.fullName.isNotEmpty
        ? widget.profileState.fullName
        : 'Farmer';
    return CircleAvatar(
      radius: 17,
      backgroundColor: ExactColors.primaryFabGreen,
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAvatarFallbackLarge(FarmerProfileState p) {
    final name = p.fullName.isNotEmpty ? p.fullName : 'Farmer';
    return CircleAvatar(
      radius: 28,
      backgroundColor: ExactColors.primaryFabGreen,
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: ExactColors.mutedText)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: ExactColors.headerDarkGreen),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MAIN SCAFFOLD & BODY
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExactColors.scaffoldBg,
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(
          index: _activeNavIndex,
          children: [
            _buildScreen1Home(),
            _buildScreen2Insights(),
            _buildScreen3AiAndMarket(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ==========================================================================
  // BOTTOM NAVIGATION BAR (Exact match to design mockup)
  // ==========================================================================
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: _activeNavIndex == 0,
              ),
              // 2. Insights
              _buildNavItem(
                index: 1,
                icon: Icons.bar_chart_rounded,
                label: 'Insights',
                isActive: _activeNavIndex == 1,
              ),
              // 3. Center FAB '+'
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => InteractiveFarmMapScreen(profileState: widget.profileState)),
                ),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: ExactColors.primaryFabGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33044D3D),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
              // 4. Market / AI
              _buildNavItem(
                index: 2,
                icon: Icons.storefront_outlined,
                label: 'Market',
                isActive: _activeNavIndex == 2,
              ),
              // 5. Profile
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isActive: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _navigateToTab(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? ExactColors.primaryFabGreen : ExactColors.navInactive,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? ExactColors.primaryFabGreen : ExactColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SCREEN 1: HOME (Exact match to ref_screens_mockup.jpg - Screen 1)
  // ==========================================================================
  Widget _buildScreen1Home() {
    final farmerName = widget.profileState.fullName.isNotEmpty
        ? widget.profileState.fullName.split(" ").first
        : "Farmer";

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Bar: Mazhi Sheti logo + Good Morning, [User] 👋 + Avatar + Bell
          Row(
            children: [
              // Logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_emblem.png',
                    width: 38,
                    height: 38,
                    errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: ExactColors.primaryFabGreen, size: 34),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mazhi\nSheti',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: ExactColors.headerDarkGreen,
                          height: 1.05,
                        ),
                      ),
                      Text(
                        'Smart Farming for a Better Tomorrow',
                        style: TextStyle(fontSize: 6.8, color: ExactColors.mutedText, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Greeting & Avatar & Bell
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Good Morning,', style: TextStyle(fontSize: 9.5, color: ExactColors.mutedText)),
                  Text(
                    '$farmerName 👋',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: ExactColors.headerDarkGreen),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showProfileSheet,
                child: ClipOval(
                  child: widget.profileState.photoUrl != null && widget.profileState.photoUrl!.isNotEmpty
                      ? Image.network(
                          widget.profileState.photoUrl!,
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                        )
                      : (widget.profileState.fullName.toLowerCase().contains('vineet')
                          ? Image.asset(
                              'assets/images/avatar_vineet.jpg',
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                            )
                          : _buildAvatarFallback()),
                ),
              ),
              const SizedBox(width: 6),
              Stack(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.notifications_none_rounded, color: ExactColors.headerDarkGreen, size: 24),
                    onPressed: _showNotificationsSheet,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Hero Banner: Exact Pastoral Illustration ("Grow Better, Live Brighter")
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CropAdviceScreen()),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/s1_hero_banner_hd.png',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/banner_healthy_farms.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Search Bar
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: _showSearchSheet,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD6F0C1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: ExactColors.headerDarkGreen, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search for crops, advice, or tools...',
                      style: TextStyle(fontSize: 12, color: ExactColors.mutedText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.mic, color: ExactColors.primaryFabGreen, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4. 6 Feature Cards (Redirect to real interactive screens)
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: [
              _buildFeatureCard(
                icon: Icons.eco_rounded,
                title: 'Crop Advice',
                subtitle: 'AI-powered tips',
                iconColor: const Color(0xFF14833B),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CropAdviceScreen()),
                ),
              ),
              _buildFeatureCard(
                icon: Icons.wb_sunny_rounded,
                title: 'Weather',
                subtitle: 'Live updates',
                iconColor: const Color(0xFFF39C12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeatherDetailScreen()),
                ),
              ),
              _buildFeatureCard(
                icon: Icons.bar_chart_rounded,
                title: 'Market Prices',
                subtitle: 'Real-time rates',
                iconColor: const Color(0xFF16A085),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketPricesScreen()),
                ),
              ),
              _buildFeatureCard(
                icon: Icons.camera_alt_rounded,
                title: 'Scan & Diagnose',
                subtitle: 'Identify problems',
                iconColor: const Color(0xFF27AE60),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CropScannerScreen()),
                ),
              ),
              _buildFeatureCard(
                icon: Icons.menu_book_rounded,
                title: 'Learn',
                subtitle: 'Guides & videos',
                iconColor: const Color(0xFF2980B9),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LearnScreen()),
                ),
              ),
              _buildFeatureCard(
                icon: Icons.groups_rounded,
                title: 'Community',
                subtitle: 'Farmers together',
                iconColor: const Color(0xFF8E44AD),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CommunityScreen(profileState: widget.profileState)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5. Promo Banner: "This Season, A Healthier Harvest"
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CropAdviceScreen()),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/s1_harvest_banner_hd.png',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/s1_harvest_banner.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 6. Pagination Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 5,
                decoration: BoxDecoration(
                  color: ExactColors.headerDarkGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              ...List.generate(
                3,
                (_) => Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: ExactColors.featureCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ExactColors.featureCardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: ExactColors.headerDarkGreen,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: ExactColors.mutedText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SCREEN 2: INSIGHTS (Exact match to ref_screens_mockup.jpg - Screen 2)
  // ==========================================================================
  Widget _buildScreen2Insights() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: "Your Farm at a Glance"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Farm at a Glance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: ExactColors.headerDarkGreen,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'All important insights in one place.',
                    style: TextStyle(fontSize: 12, color: ExactColors.mutedText),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: ExactColors.headerDarkGreen, size: 24),
                onPressed: _showNotificationsSheet,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Weather & Conditions Cards
          Row(
            children: [
              // 26°C Nagpur Card -> opens WeatherDetailScreen
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WeatherDetailScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ExactColors.weatherTopCardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5EDE2)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_sunny_rounded, color: Color(0xFFF39C12), size: 22),
                            SizedBox(width: 8),
                            Text(
                              '26°C',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: ExactColors.headerDarkGreen,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Nagpur, Maharashtra >',
                          style: TextStyle(fontSize: 10, color: ExactColors.mutedText, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Partly cloudy',
                          style: TextStyle(fontSize: 10, color: ExactColors.primaryFabGreen, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Good Conditions Card -> opens WeatherDetailScreen
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WeatherDetailScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ExactColors.goodCondCardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD6F0C1)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.eco_rounded, color: Color(0xFF14833B), size: 22),
                        SizedBox(height: 4),
                        Text(
                          'Good Conditions',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: ExactColors.headerDarkGreen,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ideal for crop growth\ntoday >',
                          style: TextStyle(fontSize: 10, color: ExactColors.mutedText, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. My Fields Section -> Opens InteractiveFarmMapScreen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Fields',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ExactColors.headerDarkGreen),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => InteractiveFarmMapScreen(profileState: widget.profileState)),
                ),
                child: const Text(
                  'View All >',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ExactColors.headerDarkGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2 Cards: Left count + Right 3D Isometric Fields -> Both open Interactive GPS Map
          Row(
            children: [
              Expanded(
                flex: 5,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InteractiveFarmMapScreen(profileState: widget.profileState)),
                  ),
                  child: Container(
                    height: 82,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ExactColors.myFieldsCardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC8EDB6)),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.eco, color: Color(0xFF14833B), size: 18),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('My Fields', style: TextStyle(fontSize: 10.5, color: ExactColors.mutedText)),
                            Text('5', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: ExactColors.headerDarkGreen)),
                            Text('Total Fields', style: TextStyle(fontSize: 9.5, color: ExactColors.mutedText)),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.chevron_right, color: ExactColors.headerDarkGreen, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Right Card: 3D Isometric Field Image -> opens Interactive Map
              Expanded(
                flex: 5,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InteractiveFarmMapScreen(profileState: widget.profileState)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/s2_my_fields_map_hd.png',
                      height: 82,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/s2_my_fields_map.png',
                        height: 82,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Today's Insights Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Insights",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ExactColors.headerDarkGreen),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeatherDetailScreen()),
                ),
                child: const Text(
                  'See All >',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ExactColors.headerDarkGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2 Cards: 32°C Weather + Soil Moisture 68%
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WeatherDetailScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ExactColors.insightsBlueCardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCEE3F5)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.cloud_outlined, color: Color(0xFF2980B9), size: 22),
                        SizedBox(height: 4),
                        Text("Today's Weather", style: TextStyle(fontSize: 10.5, color: ExactColors.mutedText)),
                        Row(
                          children: [
                            Text(
                              '32°C',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ExactColors.headerDarkGreen),
                            ),
                            Spacer(),
                            Icon(Icons.chevron_right, size: 16, color: ExactColors.mutedText),
                          ],
                        ),
                        Text(
                          'Partly cloudy',
                          style: TextStyle(fontSize: 10, color: Color(0xFF2980B9), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CropAdviceScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ExactColors.insightsBlueCardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCEE3F5)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.water_drop_outlined, color: Color(0xFF3498DB), size: 22),
                        SizedBox(height: 4),
                        Text('Soil Moisture', style: TextStyle(fontSize: 10.5, color: ExactColors.mutedText)),
                        Row(
                          children: [
                            Text(
                              '68%',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ExactColors.headerDarkGreen),
                            ),
                            Spacer(),
                            Icon(Icons.chevron_right, size: 16, color: ExactColors.mutedText),
                          ],
                        ),
                        Text(
                          'Good',
                          style: TextStyle(fontSize: 10, color: Color(0xFF27AE60), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Quick Actions Section -> Opens respective screens
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ExactColors.headerDarkGreen),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.map_outlined,
                  iconColor: const Color(0xFF27AE60),
                  label: 'Map My Field',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InteractiveFarmMapScreen(profileState: widget.profileState)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.location_on,
                  iconColor: const Color(0xFFE74C3C),
                  label: 'Check Market',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MarketPricesScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.camera_alt,
                  iconColor: const Color(0xFF8E44AD),
                  label: 'Scan Crop',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CropScannerScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 6. Tools for You Section
          const Text(
            'Tools for You',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ExactColors.headerDarkGreen),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InteractiveFarmMapScreen(profileState: widget.profileState)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/s2_tool_map_hd.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/s2_tool_map.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CropAdviceScreen()),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/s2_tool_grow_hd.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/s2_tool_grow.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showTrackProgressSheet,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/s2_tool_track_hd.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/s2_tool_track.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EDE2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: ExactColors.headerDarkGreen,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SCREEN 3: AI ASSISTANT & MARKET (Exact match to ref_screens_mockup.jpg - Screen 3)
  // ==========================================================================
  Widget _buildScreen3AiAndMarket() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: "Your AI Assistant"
          const Text(
            'Your AI Assistant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: ExactColors.headerDarkGreen,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Ask anything about your crops, weather, or farming practices.',
            style: TextStyle(fontSize: 12, color: ExactColors.mutedText),
          ),
          const SizedBox(height: 14),

          // 2. AI Assistant Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ExactColors.aiContainerBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD6F0C1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sprout circle + "How can I help you today?"
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: ExactColors.primaryFabGreen,
                      child: Icon(Icons.eco, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How can I help you today?',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: ExactColors.headerDarkGreen,
                            ),
                          ),
                          Text(
                            'Get instant, personalized advice for your farm.',
                            style: TextStyle(fontSize: 10, color: ExactColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3 Prompt Pills
                _buildAiPromptPill(
                  'How to control leaf spot in soybean?',
                  'Spray Mancozeb 75% WP @ 2.5 g/L or Hexaconazole 5% EC @ 1 mL/L of water. Ensure thorough foliar coverage in early morning.',
                ),
                const SizedBox(height: 8),
                _buildAiPromptPill(
                  'Best time to sow wheat?',
                  'For Nagpur & Vidarbha, optimal sowing window for irrigated Wheat (Sharbati / Lok-1) is November 1–15 when day temperatures are 26°C–30°C.',
                ),
                const SizedBox(height: 8),
                _buildAiPromptPill(
                  'Current market price of cotton?',
                  'Cotton is trading at ₹6,150 / quintal (↑ 3.2%) today in Nagpur and Hingna APMC, with premium long-staple lots reaching ₹6,340 / quintal.',
                ),
                const SizedBox(height: 12),

                // Input Box: "Type your question..." + Mic + Green Send
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _showCustomAiDialog,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.only(left: 14, right: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD6F0C1)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Type your question...',
                            style: TextStyle(fontSize: 12, color: ExactColors.mutedText),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.mic, color: ExactColors.headerDarkGreen, size: 20),
                          onPressed: _showCustomAiDialog,
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: ExactColors.aiSendGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.near_me_rounded, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Market Prices Section -> Opens MarketPricesScreen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Market Prices',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ExactColors.headerDarkGreen),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketPricesScreen()),
                ),
                child: const Text(
                  'View All >',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ExactColors.headerDarkGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4 Market Price Rows in a Card -> Tapping navigates to MarketPricesScreen
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: ExactColors.marketCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EDE2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMarketPriceRow(
                  iconAsset: 'assets/images/crop_soybean_hd.png',
                  cropName: 'Soybean',
                  price: '₹4,892 / quintal',
                  trend: '↑ 2.4%',
                  isUp: true,
                ),
                const Divider(height: 16, thickness: 0.8),
                _buildMarketPriceRow(
                  iconAsset: 'assets/images/crop_wheat_hd.png',
                  cropName: 'Wheat',
                  price: '₹2,425 / quintal',
                  trend: '↓ 1.1%',
                  isUp: false,
                ),
                const Divider(height: 16, thickness: 0.8),
                _buildMarketPriceRow(
                  iconAsset: 'assets/images/crop_cotton_hd.png',
                  cropName: 'Cotton',
                  price: '₹6,150 / quintal',
                  trend: '↑ 3.2%',
                  isUp: true,
                ),
                const Divider(height: 16, thickness: 0.8),
                _buildMarketPriceRow(
                  iconAsset: 'assets/images/crop_maize_hd.png',
                  cropName: 'Maize',
                  price: '₹1,980 / quintal',
                  trend: '↑ 0.8%',
                  isUp: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Promo Banner: "Small Steps. A Greener Future." -> Opens LearnScreen
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LearnScreen()),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/s3_greener_banner_hd.png',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/s3_greener_banner.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiPromptPill(String prompt, String answer) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _showAiQuestionSheet(prompt, answer),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ExactColors.aiPromptPillBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD6F0C1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                prompt,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: ExactColors.headerDarkGreen,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: ExactColors.mutedText),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketPriceRow({
    required String iconAsset,
    required String cropName,
    required String price,
    required String trend,
    required bool isUp,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MarketPricesScreen()),
      ),
      child: Row(
        children: [
          Image.asset(
            iconAsset,
            width: 24,
            height: 24,
            errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 20, color: ExactColors.primaryFabGreen),
          ),
          const SizedBox(width: 10),
          Text(
            cropName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: ExactColors.headerDarkGreen,
            ),
          ),
          const Spacer(),
          Text(
            price,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ExactColors.bodyText,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            trend,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: isUp ? ExactColors.trendUpGreen : ExactColors.trendDownRed,
            ),
          ),
        ],
      ),
    );
  }
}
