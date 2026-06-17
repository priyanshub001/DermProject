import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'api_service.dart';
import 'history_page.dart';
import 'image_analysis_page.dart';
import 'symptom_page.dart';
import 'combined_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List history = [];
  bool isLoading = true;
  String name = "";

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token") ?? "";
      final data = await ApiService.getHistory(token);
      setState(() {
        history = data;
        name = prefs.getString("name") ?? "User";
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 21) return "Good Evening";
    return "Good Night";
  }

  String formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      DateTime now = DateTime.now();
      int diff = now.difference(date).inDays;
      if (diff == 0) return "Today";
      if (diff == 1) return "Yesterday";
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Unknown";
    }
  }

  int getTotalScans() => history.length;

  String getLastPrediction() {
    if (history.isEmpty) return "No scans yet";
    return history[0]["final_prediction"] ?? "-";
  }

  String getLastSeverity() {
    if (history.isEmpty) return "";
    return history[0]["severity"] ?? "";
  }

  Color severityColor(String severity) {
    if (severity == "High") return Colors.red;
    if (severity == "Medium") return Colors.orange;
    return const Color(0xff2E9C7A);
  }

  String resolveType(Map item) {
    String type = item["type"]?.toString() ?? "";
    if (type.isEmpty) {
      String imagePred = item["image_prediction"]?.toString() ?? "";
      String textPred = item["text_prediction"]?.toString() ?? "";
      if (imagePred.isNotEmpty && textPred.isNotEmpty) return "combined";
      if (imagePred.isNotEmpty) return "image";
      if (textPred.isNotEmpty) return "text";
    }
    return type.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ── HEADER ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 70),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1B7F63), Color(0xff2E9C7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getGreeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "U",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // STATS ROW
                    Row(
                      children: [
                        _headerStat(getTotalScans().toString(), "Total Scans"),
                        _headerDivider(),
                        _headerStat(
                          getLastSeverity().isEmpty ? "-" : getLastSeverity(),
                          "Last Severity",
                        ),
                        _headerDivider(),
                        _headerStat(
                          history.isEmpty ? "0" : "Active",
                          "Status",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── QUICK ACTIONS ──
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Start Analysis",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Choose how you want to scan",
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _actionCard(
                                  icon: Icons.camera_alt_outlined,
                                  label: "Image",
                                  color: const Color(0xff2E9C7A),
                                  bg: const Color(0xffE8F5F0),
                                  onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const ImageAnalysisPage()),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _actionCard(
                                  icon: Icons.edit_note_outlined,
                                  label: "Symptoms",
                                  color: Colors.purple,
                                  bg: const Color(0xffF3EEFF),
                                  onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const SymptomPage()),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _actionCard(
                                  icon: Icons.merge_type_outlined,
                                  label: "Combined",
                                  color: Colors.orange,
                                  bg: const Color(0xffFFF4E5),
                                  onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const CombinedPage()),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── LAST RESULT BANNER ──
                      if (history.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xffE8F5F0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xff2E9C7A).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xff2E9C7A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.analytics_outlined,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Latest Result",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      getLastPrediction(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (getLastSeverity().isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: severityColor(getLastSeverity()).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    getLastSeverity(),
                                    style: TextStyle(
                                      color: severityColor(getLastSeverity()),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ── RECENT SCANS ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Scans",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const HistoryPage()),
                            ),
                            child: const Text(
                              "View all →",
                              style: TextStyle(
                                color: Color(0xff2E9C7A),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (isLoading)
                        const Center(child: CircularProgressIndicator(color: Color(0xff2E9C7A)))
                      else if (history.isEmpty)
                        _emptyHistory()
                      else
                        Column(
                          children: history.take(3).map((item) {
                            String prediction = item["final_prediction"] ?? "Unknown";
                            String severity = item["severity"] ?? "Low";
                            String dateStr = item["date"]?.toString() ?? "";
                            String date = formatDate(dateStr);
                            String type = resolveType(item);
                            double confidence = (item["final_confidence"] ?? 0.0).toDouble();

                            String typeLabel = "🤖";
                            if (type.contains("image")) typeLabel = "📷";
                            else if (type.contains("text")) typeLabel = "📝";

                            return _scanCard(
                              prediction: prediction,
                              severity: severity,
                              date: date,
                              typeLabel: typeLabel,
                              confidence: confidence,
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 20),

                      // ── SKIN TIPS ──
                      const Text(
                        "Skin Care Tips",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _skinTipsCard(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGETS ──

  Widget _headerStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _headerDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scanCard({
    required String prediction,
    required String severity,
    required String date,
    required String typeLabel,
    required double confidence,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffE8F5F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(typeLabel, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "$date  •  ${confidence.toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor(severity).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              severity,
              style: TextStyle(
                color: severityColor(severity),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.image_search, size: 48, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No scans yet",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            "Start your first analysis above",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _skinTipsCard() {
    final tips = [
      "Wash your face twice daily",
      "Drink enough water daily",
      "Use sunscreen before going out",
      "Avoid touching your face frequently",
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: tips.map((tip) => _tipRow(tip)).toList(),
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: Color(0xff2E9C7A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}