import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController controller = PageController();
  int currentIndex = 0;

  final List data = [
    {
      "icon": Icons.center_focus_strong,
      "title": "Scan Your Skin",
      "desc":
      "Take a photo or upload an image to analyze your skin condition instantly"
    },
    {
      "icon": Icons.shield,
      "title": "AI-Powered Detection",
      "desc":
      "Advanced AI technology identifies potential skin conditions with high accuracy"
    },
    {
      "icon": Icons.history,
      "title": "Track Your History",
      "desc":
      "Monitor your skin health over time and get personalized recommendations"
    },
  ];

  //  LOGIN CHECK HERE
  Future<void> goNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void nextPage() {
    if (currentIndex < data.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      goNextScreen(); //  LAST PAGE
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: Column(
          children: [

            // SKIP
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: goNextScreen,
                child: const Text(
                  "Skip",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            //  PAGES
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: data.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // ICON
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: const BoxDecoration(
                          color: Color(0xffD1FAE5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          data[index]["icon"],
                          size: 40,
                          color: const Color(0xff10B981),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        data[index]["title"],
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          data[index]["desc"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            //  DOTS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                data.length,
                    (index) => Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? const Color(0xff10B981)
                        : Colors.grey.shade300,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //  BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10B981),
                  minimumSize:
                  const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
                onPressed: nextPage,
                child: Text(
                  currentIndex == data.length - 1
                      ? "Get Started"
                      : "Next",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}