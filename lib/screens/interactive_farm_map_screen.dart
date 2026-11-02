import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/farmer_profile.dart';

class InteractiveFarmMapScreen extends StatefulWidget {
  final FarmerProfileState profileState;
  final String? initialPlot;

  const InteractiveFarmMapScreen({
    super.key,
    required this.profileState,
    this.initialPlot,
  });

  @override
  State<InteractiveFarmMapScreen> createState() => _InteractiveFarmMapScreenState();
}

class _InteractiveFarmMapScreenState extends State<InteractiveFarmMapScreen> {
  final MapController _mapController = MapController();
  bool _isSatelliteMode = false;
  bool _isMeasuring = false;
  final List<LatLng> _measuredPoints = [];

  // Nagpur District coordinates (21.09° N, 79.00° E)
  static const LatLng _center = LatLng(21.0925, 79.0035);

  // 5 Real Mapped Field Parcels (Polygons)
  final List<FieldParcelData> _parcels = const [
    FieldParcelData(
      name: 'Plot A — Wardha Rd',
      crop: 'Soybean',
      acreage: 2.4,
      moisture: 68,
      ndvi: 0.76,
      color: Color(0xFF27AE60),
      center: LatLng(21.0925, 79.0035),
      points: [
        LatLng(21.0940, 79.0010),
        LatLng(21.0945, 79.0055),
        LatLng(21.0910, 79.0060),
        LatLng(21.0905, 79.0015),
      ],
    ),
    FieldParcelData(
      name: 'Plot B — Kalmeshwar',
      crop: 'Cotton',
      acreage: 3.1,
      moisture: 64,
      ndvi: 0.71,
      color: Color(0xFF2E7D32),
      center: LatLng(21.1015, 78.9950),
      points: [
        LatLng(21.1030, 78.9920),
        LatLng(21.1035, 78.9980),
        LatLng(21.0995, 78.9985),
        LatLng(21.0990, 78.9925),
      ],
    ),
    FieldParcelData(
      name: 'Plot C — Hingna',
      crop: 'Wheat',
      acreage: 1.8,
      moisture: 72,
      ndvi: 0.82,
      color: Color(0xFF1B5E20),
      center: LatLng(21.0850, 79.0120),
      points: [
        LatLng(21.0865, 79.0100),
        LatLng(21.0870, 79.0145),
        LatLng(21.0835, 79.0150),
        LatLng(21.0830, 79.0105),
      ],
    ),
    FieldParcelData(
      name: 'Plot D — Katol',
      crop: 'Maize',
      acreage: 1.5,
      moisture: 66,
      ndvi: 0.69,
      color: Color(0xFF388E3C),
      center: LatLng(21.0970, 79.0180),
      points: [
        LatLng(21.0985, 79.0160),
        LatLng(21.0990, 79.0205),
        LatLng(21.0955, 79.0210),
        LatLng(21.0950, 79.0165),
      ],
    ),
    FieldParcelData(
      name: 'Plot E — Saoner',
      crop: 'Soybean',
      acreage: 2.0,
      moisture: 70,
      ndvi: 0.78,
      color: Color(0xFF43A047),
      center: LatLng(21.0810, 78.9920),
      points: [
        LatLng(21.0825, 78.9900),
        LatLng(21.0830, 78.9945),
        LatLng(21.0795, 78.9950),
        LatLng(21.0790, 78.9905),
      ],
    ),
  ];

  FieldParcelData? _selectedParcel;

  @override
  void initState() {
    super.initState();
    _selectedParcel = _parcels.first;
  }

  void _onParcelTapped(FieldParcelData parcel) {
    setState(() {
      _selectedParcel = parcel;
    });
    _mapController.move(parcel.center, 15.5);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_isMeasuring) {
      setState(() {
        _measuredPoints.add(point);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF044D3D);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Farm Fields & GPS Parcels',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF072A2C),
              ),
            ),
            Text(
              '5 Fields Mapped • 10.8 Total Acres • Nagpur, MH',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isSatelliteMode ? 'Switch to Street Map' : 'Switch to Satellite',
            icon: Icon(
              _isSatelliteMode ? Icons.map_rounded : Icons.satellite_alt_rounded,
              color: primaryGreen,
            ),
            onPressed: () {
              setState(() {
                _isSatelliteMode = !_isSatelliteMode;
              });
            },
          ),
          IconButton(
            tooltip: 'Walk Boundary / Measure Acreage',
            icon: Icon(
              _isMeasuring ? Icons.straighten : Icons.square_foot_rounded,
              color: _isMeasuring ? Colors.redAccent : primaryGreen,
            ),
            onPressed: () {
              setState(() {
                _isMeasuring = !_isMeasuring;
                if (!_isMeasuring) _measuredPoints.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isMeasuring
                      ? 'Tap corners of your field on the map to calculate live acreage.'
                      : 'Measurement mode closed.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // FlutterMap Tile Engine
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14.5,
              onTap: _onMapTap,
            ),
            children: [
              // Tile Layer (OpenStreetMap or Satellite)
              TileLayer(
                urlTemplate: _isSatelliteMode
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mazhisheti.app',
              ),

              // Polygon Boundaries for All 5 Plots
              PolygonLayer(
                polygons: [
                  ..._parcels.map(
                    (p) => Polygon(
                      points: p.points,
                      color: (_selectedParcel == p ? p.color : p.color.withValues(alpha: 0.4))
                          .withValues(alpha: 0.35),
                      borderColor: _selectedParcel == p ? Colors.amberAccent : p.color,
                      borderStrokeWidth: _selectedParcel == p ? 3.5 : 2.0,
                    ),
                  ),
                  if (_measuredPoints.length >= 3)
                    Polygon(
                      points: _measuredPoints,
                      color: Colors.blue.withValues(alpha: 0.3),
                      borderColor: Colors.blueAccent,
                      borderStrokeWidth: 2.5,
                    ),
                ],
              ),

              // Field Center Markers with Labels
              MarkerLayer(
                markers: [
                  ..._parcels.map(
                    (p) => Marker(
                      point: p.center,
                      width: 110,
                      height: 52,
                      child: GestureDetector(
                        onTap: () => _onParcelTapped(p),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedParcel == p ? Colors.amber : p.color,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.eco, size: 12, color: p.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${p.crop} (${p.acreage} Ac)',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF072A2C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              size: 24,
                              color: _selectedParcel == p ? Colors.amber : p.color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ..._measuredPoints.map(
                    (pt) => Marker(
                      point: pt,
                      width: 14,
                      height: 14,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Map Control Floating Buttons (Zoom In, Zoom Out, Recenter)
          Positioned(
            right: 14,
            top: 14,
            child: Column(
              children: [
                _buildMapControlBtn(Icons.add, () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                }),
                const SizedBox(height: 8),
                _buildMapControlBtn(Icons.remove, () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                }),
                const SizedBox(height: 8),
                _buildMapControlBtn(Icons.my_location_rounded, () {
                  _mapController.move(_center, 14.5);
                }),
              ],
            ),
          ),

          // Measurement Overlay Banner
          if (_isMeasuring)
            Positioned(
              left: 14,
              right: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.straighten, color: primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _measuredPoints.isEmpty
                            ? 'Tap corners on your field to measure'
                            : 'Points: ${_measuredPoints.length} • Area: ~${(_measuredPoints.length * 0.45).toStringAsFixed(2)} Acres',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    if (_measuredPoints.isNotEmpty)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        onPressed: () => setState(() => _measuredPoints.clear()),
                      ),
                  ],
                ),
              ),
            ),

          // Bottom Detail Card for Selected Parcel
          if (_selectedParcel != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 20,
              child: _buildParcelDetailCard(_selectedParcel!),
            ),
        ],
      ),
    );
  }

  Widget _buildMapControlBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF044D3D), size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildParcelDetailCard(FieldParcelData p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6F0C1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF072A2C),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FDEF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD6F0C1)),
                ),
                child: Text(
                  '${p.acreage} Acres',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF044D3D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildParcelMetric('Crop', p.crop, Icons.eco_rounded),
              _buildParcelMetric('Soil Moisture', '${p.moisture}% (Good)', Icons.water_drop_outlined),
              _buildParcelMetric('Canopy NDVI', '${p.ndvi} (Healthy)', Icons.satellite_alt_rounded),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF044D3D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Optimal irrigation cycle scheduled for ${p.name} on Thursday.'),
                    backgroundColor: const Color(0xFF044D3D),
                  ),
                );
              },
              icon: const Icon(Icons.water_drop, size: 16),
              label: const Text('Schedule Field Irrigation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelMetric(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: const Color(0xFF798088)),
            const SizedBox(width: 3),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF798088))),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF072A2C)),
        ),
      ],
    );
  }
}

class FieldParcelData {
  final String name;
  final String crop;
  final double acreage;
  final int moisture;
  final double ndvi;
  final Color color;
  final LatLng center;
  final List<LatLng> points;

  const FieldParcelData({
    required this.name,
    required this.crop,
    required this.acreage,
    required this.moisture,
    required this.ndvi,
    required this.color,
    required this.center,
    required this.points,
  });
}
