import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'result_page.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  final TextEditingController controller = TextEditingController();
  int charCount = 0;
  bool isLoading = false;

  Future<void> analyzeText() async {
    String text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter symptoms")),
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
      final result = await ApiService.analyzeText(text, token);

      String prediction;
      double confidence;
      final predData = result["prediction"];

      if (predData is Map) {
        prediction = predData["label"] ?? "Unknown";
        confidence = (predData["confidence"] ?? 0.0).toDouble();
      } else {
        prediction = predData ?? "Unknown";
        confidence = (result["confidence"] ?? 0.0).toDouble();
      }

      await ApiService.saveScan({
        "type": "Text analysis",
        "text": text,
        "image": "",
        "final_prediction": prediction,
        "final_confidence": confidence,
        "image_prediction": "",
        "image_confidence": 0.0,
        "text_prediction": prediction,
        "text_confidence": confidence,
        "severity": result["severity"] ?? "Low",
        "advice": result["advice"] ?? "",
      }, token);

      setState(() => isLoading = false);

      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ResultPage(
          image: null,
          prediction: prediction,
          confidence: confidence,
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
                      colors: [Color(0xff5B2D8E), Color(0xff8B5CF6)],
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
                            "Symptom Analysis",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Describe your symptoms in detail",
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

                        // TEXT AREA CARD
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  "Describe your symptoms",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: controller,
                                maxLines: 6,
                                onChanged: (value) {
                                  setState(() => charCount = value.length);
                                },
                                decoration: InputDecoration(
                                  hintText: "E.g., I have red, itchy patches on my arm since 3 days...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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

                        const SizedBox(height: 20),

                        // QUICK CHIPS
                        const Text(
                          "Quick add symptoms",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip("Redness"),
                            _chip("Itching"),
                            _chip("Rash"),
                            _chip("Dry skin"),
                            _chip("Swelling"),
                            _chip("Pain"),
                            _chip("Burning"),
                            _chip("Blisters"),
                            _chip("Peeling"),
                            _chip("Dark spots"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // TIP CARD
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xffF3EEFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.purple.withOpacity(0.2)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: Colors.purple, size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Include details like: how long, which body part, any triggers, and what makes it worse.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purple,
                                  ),
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
                onPressed: analyzeText,
                icon: const Icon(Icons.psychology_outlined, color: Colors.white),
                label: const Text(
                  "Analyze Symptoms",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
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
                      color: Colors.purple,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Analyzing symptoms...",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "AI is reviewing your description",
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

  Widget _chip(String text) {
    return GestureDetector(
      onTap: () {
        final current = controller.text;
        controller.text = current.isEmpty ? text : "$current, $text";
        setState(() => charCount = controller.text.length);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xffF3EEFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Text(
          "+ $text",
          style: const TextStyle(
            color: Colors.purple,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}