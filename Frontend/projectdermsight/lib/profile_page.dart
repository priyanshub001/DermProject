import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectdermsight/history_page.dart';
import 'package:projectdermsight/skin_profile_update_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'edit_profile.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String age = "";
  String email = "";
  bool isLoading = true;
  String gender = "";
  String skinType = "";
  String allergy = "";
  bool isNotificationOn = false;

  List history = [];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  int getTotalScans() => history.length;

  int getTextScans() {
    return history
        .where((item) => (item["text"] ?? "").toString().isNotEmpty)
        .length;
  }

  int getCombinedScans() {
    return history.where((item) {
      bool hasText = (item["text"] ?? "").toString().isNotEmpty;
      bool hasImage = (item["image"] ?? "").toString().isNotEmpty;
      return hasText && hasImage;
    }).length;
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";

    List data = [];
    try {
      data = await ApiService.getHistory(token);
    } catch (e) {
      print("History load error: $e");
    }

    setState(() {
      name = prefs.getString("name") ?? "User";
      email = prefs.getString("email") ?? "";
      age = prefs.getString("age") ?? "";
      gender = prefs.getString("gender") ?? "";
      skinType = prefs.getString("skin_type") ?? "";
      allergy = prefs.getString("allergy") ?? "";
      isNotificationOn = prefs.getBool("notifications") ?? false;
      history = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1B7F63), Color(0xff2E9C7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "My Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    isLoading
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      ),
                    )
                        : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                            Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "?",
                              style: const TextStyle(
                                color: Color(0xff1B7F63),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isNotEmpty ? name : "User",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email.isNotEmpty ? email : "No email linked",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // MAIN CARD (skin profile)
              Transform.translate(
                offset: const Offset(0, -72),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Skin Profile",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15.5,
                              color: Color(0xff14241F),
                            ),
                          ),
                          Icon(Icons.face_retouching_natural,
                              size: 18, color: Colors.grey[400]),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          skinBox("Skin type", skinType, Icons.water_drop_outlined,
                              const Color(0xff2E9C7A)),
                          const SizedBox(width: 10),
                          skinBox("Gender", gender, Icons.person_outline,
                              const Color(0xff8B5CF6)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          skinBox(
                              "Age",
                              age.isEmpty ? "" : "$age yrs",
                              Icons.cake_outlined,
                              const Color(0xffE65C00)),
                          const SizedBox(width: 10),
                          skinBox("Allergies", allergy, Icons.healing_outlined,
                              Colors.red.shade400),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -56),
                child: Column(
                  children: [
                    // STATS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          statBox(
                            getTotalScans().toString(),
                            "Total scans",
                            const Color(0xffDFF3EC),
                            const Color(0xff1B7F63),
                            Icons.fact_check_outlined,
                          ),
                          const SizedBox(width: 12),
                          statBox(
                            getTextScans().toString(),
                            "Symptom",
                            const Color(0xffEAE6FB),
                            const Color(0xff5B2D8E),
                            Icons.edit_note_rounded,
                          ),
                          const SizedBox(width: 12),
                          statBox(
                            getCombinedScans().toString(),
                            "Combined",
                            const Color(0xffFFF1E5),
                            const Color(0xffC2540B),
                            Icons.merge_type_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ACCOUNT
                    section("ACCOUNT"),
                    tile(
                      Icons.edit_outlined,
                      "Edit profile",
                      const Color(0xffDFF3EC),
                      const Color(0xff1B7F63),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        ).then((_) => loadProfile());
                      },
                    ),
                    tile(
                      Icons.water_drop_outlined,
                      "Update skin profile",
                      const Color(0xffDFF3EC),
                      const Color(0xff1B7F63),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SkinProfilePage(),
                          ),
                        ).then((_) => loadProfile());
                      },
                    ),
                    tile(
                      Icons.access_time_rounded,
                      "Scan history",
                      const Color(0xffDFF3EC),
                      const Color(0xff1B7F63),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // PREFERENCES
                    section("PREFERENCES"),
                    switchTile(),
                    tile(
                      Icons.language_rounded,
                      "Language",
                      const Color(0xffF5EAD9),
                      const Color(0xffC2540B),
                      trailing: "English",
                    ),

                    const SizedBox(height: 16),

                    // SUPPORT
                    section("SUPPORT"),
                    tile(
                      Icons.help_outline_rounded,
                      "Help / FAQ",
                      const Color(0xffEAE6FB),
                      const Color(0xff5B2D8E),
                    ),
                    tile(
                      Icons.security_rounded,
                      "Privacy policy",
                      const Color(0xffEAE6FB),
                      const Color(0xff5B2D8E),
                    ),

                    const SizedBox(height: 16),

                    // LOGOUT
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffFFD9D9)),
                      ),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: Colors.red, size: 18),
                        ),
                        title: const Text(
                          "Log out",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => _handleLogout(context),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log out"),
          content: const Text("Are you sure you want to log out?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Log out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    try {
      final googleSignIn = GoogleSignIn();
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
      await prefs.clear();
    } catch (e) {
      print("Logout error: $e");
    }

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  // SKIN BOX
  Widget skinBox(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffFAFAF9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffEDEDEB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 10.5, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value.isEmpty ? "Not set" : value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: value.isEmpty
                    ? Colors.grey[400]
                    : const Color(0xff14241F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STAT BOX
  Widget statBox(String value, String label, Color bg, Color fg, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: fg.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE
  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w700,
            fontSize: 11.5,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  // TILE
  Widget tile(
      IconData icon,
      String title,
      Color bg,
      Color fg, {
        String? trailing,
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffEDEDEB)),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: fg),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.5,
                ),
              ),
              trailing: trailing != null
                  ? Text(trailing, style: const TextStyle(color: Colors.grey))
                  : Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey[400]),
            ),
          ),
        ),
      ),
    );
  }

  // SWITCH TILE
  Widget switchTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEDEDEB)),
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: const Text(
            "Notifications",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5),
          ),
          value: isNotificationOn,
          activeColor: const Color(0xff2E9C7A),
          onChanged: (v) async {
            final prefs = await SharedPreferences.getInstance();
            setState(() => isNotificationOn = v);
            await prefs.setBool("notifications", v);
          },
        ),
      ),
    );
  }
}