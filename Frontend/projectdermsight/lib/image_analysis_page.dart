import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'result_page.dart';

class ImageAnalysisPage extends StatefulWidget {
  const ImageAnalysisPage({super.key});

  @override
  State<ImageAnalysisPage> createState() => _ImageAnalysisPageState();
}

class _ImageAnalysisPageState extends State<ImageAnalysisPage> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> analyzeImage() async {
    if (selectedImage == null) return;
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";

    try {
      final result = await ApiService.analyzeImage(selectedImage!, token);

      await ApiService.saveScan({
        "type": "Image analysis",
        "image": "",
        "final_prediction": result["prediction"],
        "final_confidence": result["confidence"],
        "image_prediction": result["prediction"],
        "image_confidence": result["confidence"],
        "text_prediction": "",
        "text_confidence": 0.0,
        "severity": result["severity"] ?? "",
        "advice": result["advice"] ?? "",
      }, token);

      setState(() => isLoading = false);

      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ResultPage(
          image: selectedImage!,
          prediction: result["prediction"],
          confidence: (result["confidence"] ?? 0.0).toDouble(),
          severity: result["severity"] ?? "Low",
          advice: result["advice"] ?? "",
        ),
      ));
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF3F4F6),
          body: SafeArea(
            child: Column(
              children: [

                // HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(4, 16, 16, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff1B7F63), Color(0xff2E9C7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Image Analysis",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Upload a skin photo for AI analysis",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        const SizedBox(height: 8),

                        // IMAGE UPLOAD AREA
                        GestureDetector(
                          onTap: () => pickImage(ImageSource.gallery),
                          child: Container(
                            height: 240,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: selectedImage != null
                                    ? const Color(0xff2E9C7A)
                                    : Colors.grey.shade200,
                                width: selectedImage != null ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: selectedImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(selectedImage!, fit: BoxFit.cover),
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffE8F5F0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 40,
                                    color: Color(0xff2E9C7A),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  "Tap to upload image",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "JPG, PNG supported",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // CAMERA / GALLERY BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: _sourceButton(
                                icon: Icons.camera_alt_outlined,
                                label: "Camera",
                                onTap: () => pickImage(ImageSource.camera),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _sourceButton(
                                icon: Icons.photo_library_outlined,
                                label: "Gallery",
                                onTap: () => pickImage(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // INFO CARD
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xffE8F5F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Color(0xff2E9C7A), size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Use a clear, well-lit photo of the affected area for best results.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff1B7F63),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ANALYZE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: selectedImage == null ? null : analyzeImage,
                            icon: const Icon(Icons.search, color: Colors.white),
                            label: const Text(
                              "Analyze Image",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2E9C7A),
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // LOADING OVERLAY
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.45),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xff2E9C7A),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Analyzing image...",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "AI is processing your skin photo",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xff2E9C7A), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}