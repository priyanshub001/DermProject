import 'package:flutter/material.dart';

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const HistoryDetailPage({super.key, required this.item});

  String formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    String prediction = item["final_prediction"] ?? "Unknown";
    double confidence = (item["final_confidence"] ?? 0.0).toDouble();
    String severity = item["severity"] ?? "Low";
    String advice = item["advice"] ?? "No advice available.";
    String type = item["type"] ?? "";
    String dateStr = item["date"]?.toString() ?? "";
    String formattedDate = formatDate(dateStr);

    String imagePred = item["image_prediction"] ?? "";
    double imageConf = (item["image_confidence"] ?? 0.0).toDouble();
    String textPred = item["text_prediction"] ?? "";
    double textConf = (item["text_confidence"] ?? 0.0).toDouble();
    String symptoms = item["text"] ?? "";

    Color severityColor = Colors.green;
    Color severityBg = const Color(0xffE8F5E9);
    if (severity == "High") {
      severityColor = Colors.red;
      severityBg = const Color(0xffFFEBEE);
    } else if (severity == "Medium") {
      severityColor = Colors.orange;
      severityBg = const Color(0xffFFF3E0);
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        title: const Text("Scan Detail"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // MAIN RESULT CARD
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _typeChip(type),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Prediction",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prediction,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoChip(
                        "Confidence: ${confidence.toStringAsFixed(1)}%",
                        Colors.blueGrey.shade50,
                        Colors.blueGrey,
                      ),
                      const SizedBox(width: 8),
                      _infoChip(
                        "Severity: $severity",
                        severityBg,
                        severityColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ADVICE CARD
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tips_and_updates_outlined, color: Colors.purple, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Advice",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    advice,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ],
              ),
            ),

            // BREAKDOWN (only if combined)
            if (imagePred.isNotEmpty || textPred.isNotEmpty) ...[
              const SizedBox(height: 12),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Analysis Breakdown",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    if (imagePred.isNotEmpty)
                      _breakdownRow(
                        icon: Icons.image_outlined,
                        label: "Image",
                        value: "$imagePred  (${imageConf.toStringAsFixed(1)}%)",
                        color: const Color(0xff2E9C7A),
                      ),
                    if (imagePred.isNotEmpty && textPred.isNotEmpty)
                      const Divider(height: 16),
                    if (textPred.isNotEmpty)
                      _breakdownRow(
                        icon: Icons.text_snippet_outlined,
                        label: "Text",
                        value: "$textPred  (${textConf.toStringAsFixed(1)}%)",
                        color: Colors.purple,
                      ),
                  ],
                ),
              ),
            ],

            // SYMPTOMS (if any)
            if (symptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note_outlined, color: Colors.blueGrey, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Symptoms Entered",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      symptoms,
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: child,
    );
  }

  Widget _typeChip(String type) {
    String label = "🤖 Combined Analysis";
    String typeLower = type.toLowerCase();

    if (typeLower.contains("image")) {
      label = "📷 Image Analysis";
    } else if (typeLower.contains("text")) {
      label = "📝 Text Analysis";
    } else if (typeLower.contains("combined")) {
      label = "🤖 Combined Analysis";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xffE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _infoChip(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _breakdownRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}