import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final data = await ApiService.getHistory(token);

      setState(() {
        history = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("History Error: $e");
    }
  }

  String formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      DateTime now = DateTime.now();
      final diff = now.difference(date).inDays;
      if (diff == 0) return "Today";
      if (diff == 1) return "Yesterday";
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Unknown";
    }
  }

  // Resolves a clean type label from raw backend item, with sensible fallback
  String resolveType(Map item) {
    String type = item["type"]?.toString() ?? "";

    if (type.isEmpty) {
      String imagePred = item["image_prediction"]?.toString() ?? "";
      String textPred = item["text_prediction"]?.toString() ?? "";

      if (imagePred.isNotEmpty && textPred.isNotEmpty) {
        type = "Combined Analysis";
      } else if (imagePred.isNotEmpty) {
        type = "Image Analysis";
      } else if (textPred.isNotEmpty) {
        type = "Text Analysis";
      } else {
        type = "Analysis";
      }
    }
    return type;
  }

  int get totalScans => history.length;

  int get highSeverityCount => history
      .where((item) => (item["severity"] ?? "").toString() == "High")
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xff2E9C7A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Scan History",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff14241F),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36, right: 20, top: 4),
              child: Text(
                "Every analysis you've run, in one place",
                style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
              ),
            ),

            const SizedBox(height: 18),

            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xff2E9C7A)),
                ),
              )
            else if (history.isEmpty)
              Expanded(child: _emptyState(context))
            else
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xff2E9C7A),
                  onRefresh: fetchHistory,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      _statsStrip(),
                      const SizedBox(height: 18),
                      ...List.generate(history.length, (index) {
                        final item = history[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _historyCard(
                            context: context,
                            item: item,
                            prediction: item["final_prediction"] ?? "Unknown",
                            confidence:
                            (item["final_confidence"] ?? 0.0).toDouble(),
                            severity: item["severity"] ?? "Low",
                            date: formatDate(item["date"]?.toString() ?? ""),
                            type: resolveType(item),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statsStrip() {
    return Row(
      children: [
        Expanded(
          child: _statChip(
            icon: Icons.fact_check_outlined,
            value: totalScans.toString(),
            label: "Total scans",
            bg: const Color(0xffDFF3EC),
            fg: const Color(0xff1B7F63),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statChip(
            icon: Icons.warning_amber_rounded,
            value: highSeverityCount.toString(),
            label: "High severity",
            bg: const Color(0xffFFEBEE),
            fg: Colors.red.shade600,
          ),
        ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required String value,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: fg.withOpacity(0.85)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xffE8F5F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 44,
                color: Color(0xff2E9C7A),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No scans yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xff14241F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Run your first image, symptom, or combined analysis and it will show up here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ANALYSIS TYPE → icon + color mapping
  Map<String, dynamic> _typeStyle(String type) {
    final t = type.toLowerCase();
    if (t.contains("image")) {
      return {
        "label": "Image Analysis",
        "icon": Icons.camera_alt_rounded,
        "color": const Color(0xff2E9C7A),
      };
    } else if (t.contains("text") || t.contains("symptom")) {
      return {
        "label": "Symptom Analysis",
        "icon": Icons.edit_note_rounded,
        "color": const Color(0xff8B5CF6),
      };
    }
    return {
      "label": "Combined Analysis",
      "icon": Icons.merge_type_rounded,
      "color": const Color(0xffE65C00),
    };
  }

  Widget _historyCard({
    required BuildContext context,
    required Map item,
    required String prediction,
    required double confidence,
    required String severity,
    required String date,
    required String type,
  }) {
    final style = _typeStyle(type);
    final Color typeColor = style["color"];

    Color severityColor = const Color(0xff2E9C7A);
    Color severityBg = const Color(0xffE8F5F0);
    if (severity == "High") {
      severityColor = Colors.red.shade600;
      severityBg = const Color(0xffFFEBEE);
    } else if (severity == "Medium") {
      severityColor = Colors.orange.shade700;
      severityBg = const Color(0xffFFF3E0);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryDetailPage(
              item: Map<String, dynamic>.from(item),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffEDEDEB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(style["icon"], color: typeColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          style["label"],
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: typeColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    prediction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff14241F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: severityBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          severity,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: severityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (confidence / 100).clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor: const Color(0xffF0F0EE),
                            valueColor:
                            AlwaysStoppedAnimation<Color>(typeColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${confidence.toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}