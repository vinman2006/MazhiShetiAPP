import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  final List<LearnVideoModule> _modules = const [
    LearnVideoModule(
      title: 'Precision Drip Fertigation for Cotton & Soybean',
      duration: '8 mins',
      views: '12.4k farmers',
      category: 'Water & Nutrients',
      description: 'Learn how to calibrate Venturi injectors, dissolve water-soluble NPK without clogging drippers, and save 40% water.',
    ),
    LearnVideoModule(
      title: 'How to Read Your Soil Health Card (SHC)',
      duration: '11 mins',
      views: '24.1k farmers',
      category: 'Soil Health',
      description: 'Understanding electrical conductivity, organic carbon percentage, and calculating exact DAP/Urea savings.',
    ),
    LearnVideoModule(
      title: 'Integrated Pest Management (IPM) in Vidarbha',
      duration: '14 mins',
      views: '9.8k farmers',
      category: 'Pest Control',
      description: 'Setting up yellow sticky cards, pheromone traps, and timing biopesticide sprays to break pest lifecycles.',
    ),
    LearnVideoModule(
      title: 'PM-KISAN & PMFBY Crop Insurance Claim Guide',
      duration: '6 mins',
      views: '41.2k farmers',
      category: 'Govt Schemes',
      description: 'Step-by-step guidance to submit 72-hour crop loss intimation on the PMFBY portal with geo-tagged photos.',
    ),
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
          'Farmer Learning & Video Hub',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF072A2C)),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _modules.length,
        itemBuilder: (context, i) {
          final m = _modules[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5EDE2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F0C1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: primaryGreen, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                          const SizedBox(height: 2),
                          Text('${m.duration} • ${m.views} • ${m.category}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(m.description, style: const TextStyle(fontSize: 12.5, color: Color(0xFF223438), height: 1.35)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryGreen,
                      side: const BorderSide(color: primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Playing video guide: ${m.title}')),
                      );
                    },
                    icon: const Icon(Icons.smart_display, size: 16),
                    label: const Text('Watch Video & Read Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LearnVideoModule {
  final String title;
  final String duration;
  final String views;
  final String category;
  final String description;

  const LearnVideoModule({
    required this.title,
    required this.duration,
    required this.views,
    required this.category,
    required this.description,
  });
}

