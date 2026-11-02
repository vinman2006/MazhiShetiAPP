import 'package:flutter/material.dart';

class CropAdviceScreen extends StatefulWidget {
  const CropAdviceScreen({super.key});

  @override
  State<CropAdviceScreen> createState() => _CropAdviceScreenState();
}

class _CropAdviceScreenState extends State<CropAdviceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _crops = ['Soybean', 'Cotton', 'Wheat', 'Maize', 'Rice'];
  int _selectedCropIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF044D3D);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Crop Advisory & Agronomy',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF072A2C)),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryGreen,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Advisory'),
            Tab(text: 'Fertilizer Dose'),
            Tab(text: 'Pest Watch'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Crop Selector Chips
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _crops.length,
              itemBuilder: (context, i) {
                final isSelected = _selectedCropIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(_crops[i]),
                    selectedColor: const Color(0xFFD6F0C1),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryGreen : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSelected ? primaryGreen : Colors.grey.shade300),
                    onSelected: (_) => setState(() => _selectedCropIndex = i),
                  ),
                );
              },
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAdvisoryTab(_crops[_selectedCropIndex]),
                _buildFertilizerTab(_crops[_selectedCropIndex]),
                _buildPestTab(_crops[_selectedCropIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryTab(String crop) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'Current Growth Stage',
          subtitle: 'Vegetative to Pod Setting (45 Days After Sowing)',
          badge: 'Optimal Growth',
          badgeColor: Colors.green,
          content: 'Weather in Nagpur (26°C - 32°C) is ideal for foliar nutrient uptake. Ensure soil moisture is maintained between 60%-70%. Avoid flood irrigation.',
          icon: Icons.timeline_rounded,
        ),
        const SizedBox(height: 14),
        _buildInfoCard(
          title: 'Foliar Nutrient Recommendation',
          subtitle: 'Immediate Application Window',
          badge: 'Recommended',
          badgeColor: Colors.blue,
          content: 'Foliar spray of 19:19:19 NPK @ 5 g/L + Chelated Micronutrients @ 1 g/L in early morning (7:00 AM – 10:30 AM) to boost branching.',
          icon: Icons.water_drop_outlined,
        ),
        const SizedBox(height: 14),
        _buildInfoCard(
          title: 'Irrigation Timing',
          subtitle: 'Sensor Moisture: 68% (Adequate)',
          badge: 'Next: Thursday',
          badgeColor: Colors.teal,
          content: 'No water stress recorded. Next scheduled drip fertigation cycle should run for 45 minutes on Thursday morning.',
          icon: Icons.opacity_rounded,
        ),
      ],
    );
  }

  Widget _buildFertilizerTab(String crop) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6F0C1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$crop Nutrient Calculator (Per Acre)', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 12),
              _buildDoseRow('Urea (Nitrogen 46%)', '45 kg', 'Apply at first weeding stage'),
              const Divider(),
              _buildDoseRow('DAP (18:46:0)', '50 kg', 'Basal application at sowing'),
              const Divider(),
              _buildDoseRow('Muriate of Potash (MOP 60%)', '30 kg', 'Split in 2 doses at 30 & 60 DAS'),
              const Divider(),
              _buildDoseRow('Zinc Sulphate (21%)', '10 kg', 'Soil application for root vigor'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPestTab(String crop) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPestCard(
          pestName: 'Cercospora Leaf Spot',
          riskLevel: 'Moderate (Yellow Alert)',
          riskColor: Colors.orange,
          remedy: 'Spray Mancozeb 75% WP @ 2.5 g/L or Hexaconazole 5% EC @ 1 mL/L of water. Repeat after 12 days if spots persist.',
        ),
        const SizedBox(height: 14),
        _buildPestCard(
          pestName: 'Spodoptera Litura (Armyworm)',
          riskLevel: 'Low Risk (Green Alert)',
          riskColor: Colors.green,
          remedy: 'Install 4 pheromone traps per acre. In case of infestation, spray Emamectin Benzoate 5% SG @ 4g / 10L water.',
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EDE2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF044D3D), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildDoseRow(String item, String qty, String note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(note, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(qty, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF044D3D))),
        ],
      ),
    );
  }

  Widget _buildPestCard({
    required String pestName,
    required String riskLevel,
    required Color riskColor,
    required String remedy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(pestName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(riskLevel, style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 11.5)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Recommended Treatment:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(remedy, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

