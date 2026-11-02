import 'package:flutter/material.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  String _selectedMandi = 'Nagpur APMC';
  final List<String> _mandis = ['Nagpur APMC', 'Hingna APMC', 'Katol APMC', 'Kalmeshwar APMC', 'Saoner APMC', 'Amravati APMC'];

  final List<MandiCropItem> _crops = const [
    MandiCropItem('Soybean', 'assets/images/crop_soybean_hd.png', 4892, 2.4, true, '3,420 bags', 'Crushing plants active'),
    MandiCropItem('Cotton (Long Staple)', 'assets/images/crop_cotton_hd.png', 6150, 3.2, true, '1,890 bales', 'High export enquiry'),
    MandiCropItem('Wheat (Lok-1)', 'assets/images/crop_wheat_hd.png', 2425, 1.1, false, '2,150 bags', 'Flour mill buying steady'),
    MandiCropItem('Maize (Yellow)', 'assets/images/crop_maize_hd.png', 1980, 0.8, true, '950 bags', 'Poultry feed demand firm'),
    MandiCropItem('Tur / Pigeon Pea', 'assets/images/crop_soybean_hd.png', 10200, 1.5, true, '620 bags', 'Festival demand high'),
    MandiCropItem('Gram / Harbara', 'assets/images/crop_wheat_hd.png', 5650, 0.4, false, '1,100 bags', 'Government procurement'),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF044D3D);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Live APMC Mandi Rates',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF072A2C)),
        ),
      ),
      body: Column(
        children: [
          // Mandi Dropdown Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: primaryGreen, size: 20),
                const SizedBox(width: 8),
                const Text('Mandi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedMandi,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _mandis.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedMandi = v);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Commodity Rates List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _crops.length,
              itemBuilder: (context, i) {
                final c = _crops[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5EDE2)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        c.icon,
                        width: 36,
                        height: 36,
                        errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: primaryGreen, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text('Arrival: ${c.arrival} • ${c.note}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${c.price} / q', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF072A2C))),
                          Text(
                            '${c.isUp ? "↑" : "↓"} ${c.change}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: c.isUp ? const Color(0xFF1D8348) : const Color(0xFFD93829),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MandiCropItem {
  final String name;
  final String icon;
  final int price;
  final double change;
  final bool isUp;
  final String arrival;
  final String note;

  const MandiCropItem(this.name, this.icon, this.price, this.change, this.isUp, this.arrival, this.note);
}
