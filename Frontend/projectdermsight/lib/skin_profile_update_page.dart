import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SkinProfilePage extends StatefulWidget {
  const SkinProfilePage({super.key});

  @override
  State<SkinProfilePage> createState() => _SkinProfilePageState();
}

class _SkinProfilePageState extends State<SkinProfilePage> {

  String selectedGender = "Male";
  String selectedSkinType = "Oily";
  String selectedAllergy = "None";
  int selectedSkinToneIndex = 2;
  bool isSaving = false;

  final List<Color> skinColors = const [
    Color(0xffF1C9A5),
    Color(0xffDDAA74),
    Color(0xffC68642),
    Color(0xff8D5524),
    Color(0xff5C2E0C),
    Color(0xff3B1F0F),
  ];

  final List<Map<String, String>> skinTypes = const [
    {"title": "Oily", "subtitle": "Shiny, pores visible"},
    {"title": "Dry", "subtitle": "Tight, flaky feel"},
    {"title": "Combination", "subtitle": "T-zone oily, rest dry"},
    {"title": "Normal", "subtitle": "Balanced, smooth"},
    {"title": "Sensitive", "subtitle": "Reacts easily, redness prone"},
  ];

  @override
  void initState() {
    super.initState();
    loadExisting();
  }

  Future<void> loadExisting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGender = prefs.getString("gender")?.isNotEmpty == true
          ? prefs.getString("gender")!
          : "Male";
      selectedSkinType = prefs.getString("skin_type")?.isNotEmpty == true
          ? prefs.getString("skin_type")!
          : "Oily";
      selectedAllergy = prefs.getString("allergy")?.isNotEmpty == true
          ? prefs.getString("allergy")!
          : "None";
      selectedSkinToneIndex = prefs.getInt("skin_tone") ?? 2;
    });
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("gender", selectedGender);
    await prefs.setString("skin_type", selectedSkinType);
    await prefs.setString("allergy", selectedAllergy);
    await prefs.setInt("skin_tone", selectedSkinToneIndex);

    if (!mounted) return;
    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Skin profile saved")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6F5),
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
                        "Skin Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Helps us personalize your results",
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

                    const SizedBox(height: 4),

                    // GENDER CARD
                    _card(
                      title: "Gender",
                      child: wrapChips(
                        ["Male", "Female", "Other"],
                        selectedGender,
                            (v) => setState(() => selectedGender = v),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // SKIN TYPE CARD
                    _card(
                      title: "Skin type",
                      child: Column(
                        children: List.generate(
                          (skinTypes.length / 2).ceil(),
                              (rowIndex) {
                            final first = skinTypes[rowIndex * 2];
                            final second = rowIndex * 2 + 1 < skinTypes.length
                                ? skinTypes[rowIndex * 2 + 1]
                                : null;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  skinTypeCard(first["title"]!, first["subtitle"]!),
                                  const SizedBox(width: 8),
                                  second != null
                                      ? skinTypeCard(
                                      second["title"]!, second["subtitle"]!)
                                      : const Expanded(child: SizedBox()),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // SKIN TONE CARD
                    _card(
                      title: "Skin tone",
                      subtitle: "Pick the shade closest to your own",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(skinColors.length, (index) {
                          bool isSelected = selectedSkinToneIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedSkinToneIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: isSelected ? 42 : 36,
                              height: isSelected ? 42 : 36,
                              decoration: BoxDecoration(
                                color: skinColors[index],
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                    color: const Color(0xff2E9C7A),
                                    width: 3)
                                    : Border.all(
                                    color: Colors.grey.shade200, width: 1),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: const Color(0xff2E9C7A)
                                        .withOpacity(0.3),
                                    blurRadius: 6,
                                  ),
                                ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ALLERGIES CARD
                    _card(
                      title: "Known allergies / conditions",
                      child: wrapChips(
                        [
                          "None",
                          "Dust",
                          "Pollen",
                          "Fragrance",
                          "Latex",
                          "Metals",
                          "Sunscreen"
                        ],
                        selectedAllergy,
                            (v) => setState(() => selectedAllergy = v),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2E9C7A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isSaving ? null : saveProfile,
                        child: isSaving
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                            : const Text(
                          "Save profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // CARD WRAPPER
  Widget _card({required String title, String? subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // CHIPS
  Widget wrapChips(List<String> items, String selected, Function(String) onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((e) {
        final isSelected = e == selected;
        return GestureDetector(
          onTap: () => onTap(e),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xffDFF3EC) : const Color(0xffFAFAF9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xff2E9C7A)
                    : Colors.grey.shade200,
              ),
            ),
            child: Text(
              e,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xff1B7F63) : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // SKIN TYPE CARD (inside grid)
  Widget skinTypeCard(String title, String subtitle) {
    bool isSelected = selectedSkinType == title;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSkinType = title),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xffDFF3EC) : const Color(0xffFAFAF9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xff2E9C7A) : Colors.grey.shade200,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: isSelected
                          ? const Color(0xff1B7F63)
                          : Colors.black87,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle,
                        color: Color(0xff2E9C7A), size: 16),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}