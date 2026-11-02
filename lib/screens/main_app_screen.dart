import 'package:flutter/material.dart';
import '../models/farmer_profile.dart';

class MainAppScreen extends StatefulWidget {
  final FarmerProfileState profileState;
  final VoidCallback onBackToSignup;
  final VoidCallback onBackToOnboarding;

  const MainAppScreen({
    super.key,
    required this.profileState,
    required this.onBackToSignup,
    required this.onBackToOnboarding,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildHomeDashboardTab(),
          _buildMyFarmTab(),
          _buildMandiPricesTab(),
          _buildCropDoctorTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final p = widget.profileState;
    final isMarathi = p.selectedLanguage == 'मराठी';

    return AppBar(
      backgroundColor: const Color(0xFF0D3B2A),
      elevation: 3,
      titleSpacing: 14,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5B42),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF88C440)),
            ),
            child: const Icon(Icons.eco, color: Color(0xFF88C440), size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMarathi ? 'माझी शेती' : 'Mazhi Sheti',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFB5E48C), size: 12),
                  const SizedBox(width: 3),
                  Text(
                    '${p.selectedDistrict}, ${p.selectedState}',
                    style: const TextStyle(
                      color: Color(0xFFB5E48C),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // App Stage Pill
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF88C440),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'STEP 3: APP',
              style: TextStyle(
                color: Color(0xFF0D3B2A),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          tooltip: 'Alerts',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Weather alert: Rain expected in 48 hours. Postpone pesticide spray.'),
                backgroundColor: Color(0xFF0D3B2A),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.swap_horiz, color: Color(0xFF88C440)),
          tooltip: 'Workflow Switcher',
          onPressed: _showWorkflowMenu,
        ),
      ],
    );
  }

  void _showWorkflowMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mazhi Sheti App Navigation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3B2A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Easily switch between the 3 main project flows:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE4F0E7),
                  child: Text('1', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A))),
                ),
                title: const Text('Step 1: 8-Screen Onboarding'),
                subtitle: const Text('Interactive language, role, crops & farm location flow'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onBackToOnboarding();
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE4F0E7),
                  child: Text('2', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A))),
                ),
                title: const Text('Step 2: Sign-Up Page'),
                subtitle: const Text('Farmer details, phone/OTP, soil, 7/12 & landholdings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onBackToSignup();
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0D3B2A),
                  child: Text('3', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                title: const Text('Step 3: The App Itself (Current)'),
                subtitle: const Text('Weather, Mandi, Farm manager, AI Plant Doctor'),
                trailing: const Icon(Icons.check, color: Color(0xFF1E7E34)),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _currentTab,
      onDestinationSelected: (idx) => setState(() => _currentTab = idx),
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFF88C440).withValues(alpha: 0.35),
      elevation: 8,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: Color(0xFF0D3B2A)),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.agriculture_outlined),
          selectedIcon: Icon(Icons.agriculture, color: Color(0xFF0D3B2A)),
          label: 'My Farm',
        ),
        NavigationDestination(
          icon: Icon(Icons.currency_rupee_outlined),
          selectedIcon: Icon(Icons.currency_rupee, color: Color(0xFF0D3B2A)),
          label: 'Mandi',
        ),
        NavigationDestination(
          icon: Icon(Icons.document_scanner_outlined),
          selectedIcon: Icon(Icons.document_scanner, color: Color(0xFF0D3B2A)),
          label: 'AI Doctor',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: Color(0xFF0D3B2A)),
          label: 'Profile',
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: HOME DASHBOARD
  // ==========================================
  Widget _buildHomeDashboardTab() {
    final p = widget.profileState;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D3B2A), Color(0xFF19553D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D3B2A).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF88C440),
                  child: Text(
                    p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : 'V',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3B2A),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Namaskar, ${p.fullName} 🙏',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.farmName} • ${p.selectedFarmSize} Acres',
                        style: const TextStyle(color: Color(0xFFB5E48C), fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${p.selectedRole} | ${p.selectedCrops.join(", ")}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Weather Card
          _buildWeatherCard(),
          const SizedBox(height: 16),

          // Mandi Live Ticker Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Mandi Rates (बाजार भाव)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3B2A),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _currentTab = 2),
                child: const Text(
                  'View All Mandis →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E7E34),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Mandi Ticker Horizontal Scroll
          SizedBox(
            height: 94,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMandiCard('Cotton (कापूस)', 'Nagpur APMC', '₹7,450', '+2.4%', true),
                _buildMandiCard('Soybean (सोयाबीन)', 'Amravati APMC', '₹4,920', '+1.1%', true),
                _buildMandiCard('Rice (भात)', 'Bhandara APMC', '₹2,680', '+0.5%', true),
                _buildMandiCard('Wheat (गहू)', 'Akola APMC', '₹2,410', '-0.8%', false),
                _buildMandiCard('Tur (तूर डाळ)', 'Latur APMC', '₹10,200', '+3.2%', true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Action Grid
          const Text(
            'Smart Farming Services',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B2A),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildServiceButton(
                icon: Icons.camera_alt,
                label: 'AI Plant Doctor',
                color: const Color(0xFF1E7E34),
                onTap: () => setState(() => _currentTab = 3),
              ),
              _buildServiceButton(
                icon: Icons.storefront,
                label: 'APMC Mandi',
                color: const Color(0xFF0D3B2A),
                onTap: () => setState(() => _currentTab = 2),
              ),
              _buildServiceButton(
                icon: Icons.water_drop,
                label: 'Drip Timer',
                color: const Color(0xFF007791),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Drip Irrigation scheduled for 06:30 AM tomorrow')),
                  );
                },
              ),
              _buildServiceButton(
                icon: Icons.calculate_outlined,
                label: 'Fertilizer Calc',
                color: const Color(0xFF7A5C00),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('NPK Recommended: Urea 50kg, DAP 75kg per acre')),
                  );
                },
              ),
              _buildServiceButton(
                icon: Icons.account_balance,
                label: 'Govt Schemes',
                color: const Color(0xFF5A2A7A),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PM-KISAN 17th Installment: Credited to Bank Account')),
                  );
                },
              ),
              _buildServiceButton(
                icon: Icons.phone_in_talk,
                label: 'Kisan Helpline',
                color: const Color(0xFFB3261E),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling Kisan Call Center: 1800-180-1551 (Toll-Free)')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Today's Farm Tasks & Timeline
          _buildFarmTasksCard(),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Color(0xFFF9A825), size: 36),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '31°C • Sunny & Clear',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D3B2A),
                      ),
                    ),
                    Text(
                      'Nagpur Region • Humidity 42% • Wind 11 km/h',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Good for Spraying',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E7E34),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeatherForecastItem('Today', '31° / 21°', Icons.wb_sunny, Color(0xFFF9A825)),
              _WeatherForecastItem('Tue', '30° / 20°', Icons.wb_cloudy, Color(0xFF607D8B)),
              _WeatherForecastItem('Wed', '28° / 19°', Icons.grain, Color(0xFF0288D1)),
              _WeatherForecastItem('Thu', '29° / 20°', Icons.wb_sunny, Color(0xFFF9A825)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMandiCard(String crop, String mandi, String price, String change, bool isUp) {
    return Container(
      width: 148,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EBE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            crop,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0D3B2A)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(mandi, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF1B5B42)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isUp ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isUp ? const Color(0xFF1E7E34) : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2EBE4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D3B2A),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmTasksCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today & Upcoming Farm Tasks',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A)),
              ),
              Icon(Icons.calendar_today, size: 16, color: Color(0xFF1B5B42)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTaskItem(
            title: 'Drip Irrigation — Plot A (Cotton)',
            time: 'Today • 07:00 AM (2 Hours)',
            status: 'Completed',
            isDone: true,
          ),
          const Divider(height: 16),
          _buildTaskItem(
            title: 'NPK 19:19:19 Fertigation — Plot B (Soybean)',
            time: 'Today • 04:30 PM',
            status: 'Pending',
            isDone: false,
          ),
          const Divider(height: 16),
          _buildTaskItem(
            title: 'Pest Scouting & Leaf Inspection',
            time: 'Tomorrow • Morning',
            status: 'Scheduled',
            isDone: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String time,
    required String status,
    required bool isDone,
  }) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? const Color(0xFF1E7E34) : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : const Color(0xFF0D3B2A),
                ),
              ),
              Text(time, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDone ? const Color(0xFF1E7E34) : const Color(0xFFE65100),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: MY FARM
  // ==========================================
  Widget _buildMyFarmTab() {
    final p = widget.profileState;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EBE4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.farmName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D3B2A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF88C440),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${p.selectedFarmSize} Acres',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D3B2A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Village: ${p.village}, Taluka: ${p.taluka}, Dist: ${p.selectedDistrict}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Record: ${p.landSurveyNo} • ${p.landOwnershipType}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1B5B42), fontWeight: FontWeight.w600),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFarmDetailBadge('Irrigation', p.irrigationType.label, Icons.water_drop),
                    _buildFarmDetailBadge('Soil Type', p.soilType.label.split(' ')[0], Icons.terrain),
                    _buildFarmDetailBadge('Crops', '${p.selectedCrops.length} Active', Icons.eco),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Crops Progress
          const Text(
            'Active Crops & Growth Stages',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A)),
          ),
          const SizedBox(height: 10),
          ...p.selectedCrops.map((crop) => _buildCropStageCard(crop)),
        ],
      ),
    );
  }

  Widget _buildFarmDetailBadge(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0D3B2A), size: 22),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A))),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCropStageCard(String crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EBE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🌱 $crop',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Vegetative Stage (Day 45)',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E7E34)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            value: 0.45,
            backgroundColor: Color(0xFFE0E0E0),
            color: Color(0xFF88C440),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sowing: 15 June 2026', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Expected Harvest: Oct 2026', style: TextStyle(fontSize: 11, color: Color(0xFF1B5B42), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: MANDI PRICES
  // ==========================================
  Widget _buildMandiPricesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3B2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.currency_rupee, color: Color(0xFF88C440), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maharashtra APMC Live Rates',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Verified daily commodity market prices per quintal',
                        style: TextStyle(color: Color(0xFFB5E48C), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMandiDetailedItem('Cotton (कापूस Medium Staple)', 'Nagpur APMC', '₹7,150', '₹7,450', '₹7,300', '+ ₹180', true),
          _buildMandiDetailedItem('Soybean (सोयाबीन Yellow)', 'Amravati APMC', '₹4,750', '₹5,020', '₹4,920', '+ ₹60', true),
          _buildMandiDetailedItem('Tur / Pigeon Pea (तूर)', 'Latur APMC', '₹9,800', '₹10,500', '₹10,200', '+ ₹320', true),
          _buildMandiDetailedItem('Wheat (गहू Lokwan)', 'Akola APMC', '₹2,350', '₹2,500', '₹2,410', '- ₹25', false),
          _buildMandiDetailedItem('Rice / Paddy (भात)', 'Gondia APMC', '₹2,550', '₹2,720', '₹2,650', '+ ₹40', true),
          _buildMandiDetailedItem('Onion (कांदा Red)', 'Lasalgaon APMC', '₹1,450', '₹2,200', '₹1,850', '- ₹110', false),
          _buildMandiDetailedItem('Gram / Harbara (चना)', 'Pune APMC', '₹5,800', '₹6,150', '₹6,000', '+ ₹90', true),
        ],
      ),
    );
  }

  Widget _buildMandiDetailedItem(
    String commodity,
    String mandi,
    String minP,
    String maxP,
    String modalP,
    String change,
    bool isPositive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EBE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  commodity,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0D3B2A)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? const Color(0xFF1E7E34) : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(mandi, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceSub('Min Price', minP),
              _buildPriceSub('Max Price', maxP),
              _buildPriceSub('Modal Price', modalP, isHighlight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSub(String label, String price, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          price,
          style: TextStyle(
            fontSize: isHighlight ? 14 : 12,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? const Color(0xFF1E7E34) : const Color(0xFF0D3B2A),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 4: AI PLANT DOCTOR
  // ==========================================
  Widget _buildCropDoctorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2EBE4)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFE4F0E7),
                  child: Icon(Icons.document_scanner, size: 40, color: Color(0xFF0D3B2A)),
                ),
                const SizedBox(height: 14),
                const Text(
                  'AI Crop Disease Scanner',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Snap a clear picture of leaf spots, wilted stems, or pests to get instant diagnosis and cure recommendations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B2A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera opening for Crop Leaf Diagnosis...')),
                    );
                  },
                  icon: const Icon(Icons.photo_camera, color: Color(0xFF88C440)),
                  label: const Text('Take Photo / Scan Crop', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Common Disease Alerts
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EBE4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Regional Pest Outbreak Warnings',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A)),
                ),
                const SizedBox(height: 12),
                _buildDiseaseAlert(
                  'Pink Bollworm (गुलाबी बोंडअळी)',
                  'Cotton (कापूस)',
                  'Install pheromone traps (5/acre). Spray Neem oil (5ml/L) as preventive bio-measure.',
                  Colors.amber.shade800,
                ),
                const Divider(height: 16),
                _buildDiseaseAlert(
                  'Yellow Mosaic Virus (पिवळा मोझॅक)',
                  'Soybean (सोयाबीन)',
                  'Transmitted by whiteflies. Spray Thiamethoxam 25% WG @ 4g per 10 Liters water.',
                  Colors.red.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseAlert(String title, String crop, String advice, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A)),
              ),
              Text(
                'Crop: $crop',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E7E34)),
              ),
              const SizedBox(height: 2),
              Text(advice, style: const TextStyle(fontSize: 11.5, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 5: PROFILE
  // ==========================================
  Widget _buildProfileTab() {
    final p = widget.profileState;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF0D3B2A),
            child: Text(
              p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : 'V',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF88C440)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            p.fullName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A)),
          ),
          Text(
            '+91 ${p.mobileNumber} • ${p.email}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Details List
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EBE4)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: Color(0xFF0D3B2A)),
                  title: const Text('Role & Category', style: TextStyle(fontSize: 13)),
                  trailing: Text(p.selectedRole, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.home_work_outlined, color: Color(0xFF0D3B2A)),
                  title: const Text('Farm Name', style: TextStyle(fontSize: 13)),
                  trailing: Text(p.farmName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.straighten, color: Color(0xFF0D3B2A)),
                  title: const Text('Landholding Size', style: TextStyle(fontSize: 13)),
                  trailing: Text('${p.selectedFarmSize} Acres', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: Color(0xFF0D3B2A)),
                  title: const Text('Location', style: TextStyle(fontSize: 13)),
                  trailing: Text('${p.village}, ${p.selectedDistrict}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance, color: Color(0xFF0D3B2A)),
                  title: const Text('PM-KISAN Status', style: TextStyle(fontSize: 13)),
                  trailing: Text(
                    p.isPmKisanRegistered ? 'Registered (DBT Active)' : 'Not Registered',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: p.isPmKisanRegistered ? const Color(0xFF1E7E34) : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Action buttons to switch steps
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5B42),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: widget.onBackToSignup,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Farmer Registration (Step 2)'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D3B2A),
              side: const BorderSide(color: Color(0xFF0D3B2A)),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: widget.onBackToOnboarding,
            icon: const Icon(Icons.replay, size: 18),
            label: const Text('Re-run 8-Screen Onboarding (Step 1)'),
          ),
        ],
      ),
    );
  }
}

class _WeatherForecastItem extends StatelessWidget {
  final String day;
  final String temp;
  final IconData icon;
  final Color color;

  const _WeatherForecastItem(this.day, this.temp, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(temp, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D3B2A))),
      ],
    );
  }
}
