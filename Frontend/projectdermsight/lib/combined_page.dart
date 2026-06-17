import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'result_page.dart';

class CombinedPage extends StatefulWidget {
  const CombinedPage({super.key});

  @override
  State<CombinedPage> createState() => _CombinedPageState();
}

class _CombinedPageState extends State<CombinedPage> {
  final TextEditingController controller = TextEditingController();
  int charCount = 0;
  File? selectedImage;
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> analyzeCombined() async {
    String text = controller.text.trim();
    if (selectedImage == null || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add both image and symptoms")),
      );
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";

    if (token.isEmpty) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login again")),
      );
      return;
    }

    try {
      final result = await ApiService.analyzeCombined(selectedImage!, text, token);

      await ApiService.saveScan({
        "type": "Combined analysis",
        "text": text,
        "image": "",
        "final_prediction": result["final_prediction"],
        "final_confidence": result["final_confidence"],
        "image_prediction": result["image_prediction"],
        "image_confidence": result["image_confidence"],
        "text_prediction": result["text_prediction"],
        "text_confidence": result["text_confidence"],
        "severity": result["severity"],
        "advice": result["advice"],
      }, token);

      setState(() => isLoading = false);

      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ResultPage(
          image: selectedImage,
          prediction: result["final_prediction"] ?? "No result",
          confidence: (result["final_confidence"] ?? 0.0).toDouble(),
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
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [

                // HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(4, 16, 16, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffE65C00), Color(0xffF9A825)],
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
                            "Combined Analysis",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Image + symptoms for better accuracy",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 8),

                        // STEP 1
                        _stepHeader("1", "Upload Skin Image", Colors.orange),
                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedImage != null
                                    ? Colors.orange
                                    : Colors.grey.shade200,
                                width: selectedImage != null ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: selectedImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(selectedImage!, fit: BoxFit.cover),
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Color(0xffFFF4E5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 32,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Tap to select image",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "From gallery",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // STEP 2
                        _stepHeader("2", "Describe Symptoms", Colors.orange),
                        const SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: controller,
                                maxLines: 5,
                                onChanged: (val) {
                                  setState(() => charCount = val.length);
                                },
                                decoration: InputDecoration(
                                  hintText: "Describe your skin symptoms in detail...",
                                  hintStyle: TextStyle(
                                      color: Colors.grey[400], fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "$charCount characters",
                                      style: TextStyle(
                                          color: Colors.grey[500], fontSize: 12),
                                    ),
                                    Text(
                                      charCount < 20 ? "Add more detail" : "Good detail",
                                      style: TextStyle(
                                        color: charCount < 20
                                            ? Colors.orange
                                            : const Color(0xff2E9C7A),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // INFO
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFF4E5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.auto_awesome,
                                  color: Colors.orange, size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Combined analysis uses both image and symptoms for higher accuracy results.",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FIXED BOTTOM BUTTON
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: analyzeCombined,
                icon: const Icon(Icons.merge_type, color: Colors.white),
                label: const Text(
                  "Combined Analyze",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
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
                      color: Colors.orange,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Analyzing...",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Processing image and symptoms",
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

  Widget _stepHeader(String number, String title, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}