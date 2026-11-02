import 'package:flutter/material.dart';

class CropScannerScreen extends StatefulWidget {
  const CropScannerScreen({super.key});

  @override
  State<CropScannerScreen> createState() => _CropScannerScreenState();
}

class _CropScannerScreenState extends State<CropScannerScreen> {
  bool _isAnalyzing = false;
  bool _hasResult = false;
  String _detectedIssue = '';
  double _confidence = 0.0;

  void _startScan() {
    setState(() {
      _isAnalyzing = true;
      _hasResult = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _hasResult = true;
        _detectedIssue = 'Cercospora Leaf Spot (बुरशीजन्य करपा)';
        _confidence = 96.4;
      });
    });
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
          'AI Crop Leaf Doctor & Scanner',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF072A2C)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Camera / Viewfinder Box
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryGreen, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.filter_center_focus_rounded,
                    size: 160,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  if (_isAnalyzing)
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.greenAccent),
                        SizedBox(height: 14),
                        Text(
                          'AI Analyzing Leaf Symptoms...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  else if (!_hasResult)
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 48, color: Colors.white70),
                        SizedBox(height: 8),
                        Text(
                          'Point camera at diseased crop leaf',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Hold steady in natural daylight',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Diagnosed: $_detectedIssue',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Confidence: ${_confidence.toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Scan Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isAnalyzing ? null : _startScan,
                    icon: const Icon(Icons.camera),
                    label: const Text('Capture & Diagnose', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: const BorderSide(color: primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _startScan,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Diagnosis & Treatment Plan
            if (_hasResult) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD6F0C1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_services_outlined, color: Colors.redAccent, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _detectedIssue,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF072A2C)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Chemical Prescription:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text(
                      '• Spray Hexaconazole 5% EC @ 1 mL per litre of water OR Mancozeb 75% WP @ 2.5 g per litre.\n• Repeat spray after 10–14 days if fungal lesions continue spreading.',
                      style: TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    const Text('Organic Alternative:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text(
                      '• Spray 5% Neem Seed Kernel Extract (NSKE) or Pseudomonas fluorescens @ 10 g/L.',
                      style: TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
