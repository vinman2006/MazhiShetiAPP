import 'package:flutter/material.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF044D3D);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Agro-Weather & Telemetry',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF072A2C)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Weather Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEBF5FE), Color(0xFFD9EDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBCE0FD)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nagpur, Maharashtra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        Text('Live Station Telemetry • Hingna Block', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Updated 10m ago', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny_rounded, color: Color(0xFFF39C12), size: 48),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('26°C', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
                        Text('Partly Cloudy • Peak 32°C', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherMiniMetric('Humidity', '58%', Icons.water_drop_outlined),
                    _buildWeatherMiniMetric('Wind', '11 km/h E', Icons.air_rounded),
                    _buildWeatherMiniMetric('Soil Moisture', '68%', Icons.grass_rounded),
                    _buildWeatherMiniMetric('UV Index', '6 (Mod)', Icons.wb_sunny_outlined),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Spray Condition Advisory
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FDEF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD6F0C1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: primaryGreen, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spray Conditions: Optimal Today', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                      Text('Wind < 12 km/h and no rain forecast for 48 hours. Best spraying window: 7:00 AM to 11:30 AM.', style: TextStyle(fontSize: 11.5, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 7-Day Forecast Header
          const Text('7-Day Agricultural Forecast', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          ...[
            _buildDayForecast('Today', 'Partly Cloudy', '32° / 22°', '0% Rain', Icons.wb_sunny_rounded, Colors.orange),
            _buildDayForecast('Tomorrow', 'Sunny & Clear', '33° / 21°', '5% Rain', Icons.wb_sunny_outlined, Colors.amber),
            _buildDayForecast('Wednesday', 'Mild Clouds', '31° / 20°', '10% Rain', Icons.cloud_queue_rounded, Colors.blueGrey),
            _buildDayForecast('Thursday', 'Scattered Sun', '30° / 19°', '0% Rain', Icons.wb_sunny_rounded, Colors.orange),
            _buildDayForecast('Friday', 'Clear Skies', '32° / 20°', '0% Rain', Icons.wb_sunny_outlined, Colors.amber),
            _buildDayForecast('Saturday', 'Partly Cloudy', '31° / 21°', '15% Rain', Icons.cloud_queue_rounded, Colors.blueGrey),
            _buildDayForecast('Sunday', 'Sunny', '33° / 22°', '0% Rain', Icons.wb_sunny_rounded, Colors.orange),
          ],
        ],
      ),
    );
  }

  static Widget _buildWeatherMiniMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF044D3D)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
      ],
    );
  }

  static Widget _buildDayForecast(String day, String condition, String temp, String rain, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EDE2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(condition, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Text(rain, style: const TextStyle(fontSize: 11, color: Color(0xFF2980B9), fontWeight: FontWeight.w600)),
          const SizedBox(width: 14),
          Text(temp, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}

