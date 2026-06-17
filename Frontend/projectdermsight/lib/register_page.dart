import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'main_screen.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool obscurePassword = true;
  bool isChecked = true;
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String selectedAge = "";

  void setLoading(bool val) {
    setState(() => isLoading = val);
  }

  Future<void> handleGoogleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      setLoading(true); // START

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) { setLoading(false); return; }

      String email = user.email ?? "";
      String name = user.displayName ?? "User";

      final response = await ApiService.googleLogin(email: email, name: name);

      if (response.containsKey("token")) {
        String token = response["token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("name", name);
        await prefs.setString("email", email);

        setLoading(false); // STOP

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
        );
      } else {
        setLoading(false); // STOP
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["msg"] ?? "Google login failed")),
        );
      }
    } catch (e) {
      setLoading(false); //  STOP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // ── MAIN UI ──
        Scaffold(
          backgroundColor: const Color(0xffF3F4F6),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 90),
                    decoration: const BoxDecoration(color: Color(0xff2E9C7A)),
                    child: Column(
                      children: const [
                        Icon(Icons.shield_outlined, size: 40, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          "DermSight",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text("Create Account", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),

                  // CARD
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // NAME
                          const Text("Full name"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: nameController,
                            decoration: inputDecoration("Enter your name", Icons.person),
                          ),

                          const SizedBox(height: 12),

                          // EMAIL
                          const Text("Email address"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: emailController,
                            decoration: inputDecoration("Enter your email", Icons.email),
                          ),

                          const SizedBox(height: 12),

                          // AGE
                          const Text("Age"),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              ageChip("13–17"),
                              ageChip("18–24"),
                              ageChip("25–34"),
                              ageChip("35–50"),
                              ageChip("50+"),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // PASSWORD
                          const Text("Password"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Enter password",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xffF1F1F1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // TERMS
                          Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                activeColor: const Color(0xff2E9C7A),
                                onChanged: (v) {
                                  setState(() { isChecked = v!; });
                                },
                              ),
                              const Expanded(
                                child: Text("I agree to the Terms of Service and Privacy Policy"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // REGISTER BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2E9C7A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                String name = nameController.text.trim();
                                String email = emailController.text.trim();
                                String password = passwordController.text.trim();
                                String age = selectedAge;

                                if (name.isEmpty || email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Fill all fields")),
                                  );
                                  return;
                                }

                                setLoading(true);

                                final response = await ApiService.registerUser(
                                  name: name,
                                  email: email,
                                  age: age,
                                  password: password,
                                );

                                setLoading(false); // STOP

                                if (response["msg"] == "User registered") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Registered successfully")),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(response["msg"] ?? "Registration failed")),
                                  );
                                }
                              },
                              child: const Text(
                                "Create Account",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          const Center(child: Text("or")),
                          const SizedBox(height: 10),

                          // GOOGLE BUTTON
                          GestureDetector(
                            onTap: handleGoogleLogin,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.g_mobiledata_outlined, size: 28),
                                  SizedBox(width: 8),
                                  Text("Continue with Google"),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // LOGIN NAVIGATE
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Color(0xff2E9C7A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── LOADING OVERLAY ──
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child:  Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xff2E9C7A),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Creating account...",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xffF1F1F1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget ageChip(String text) {
    final isSelected = selectedAge == text;
    return GestureDetector(
      onTap: () {
        setState(() { selectedAge = text; });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffDFF3EC) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xff2E9C7A) : Colors.grey.shade300,
          ),
        ),
        child: Text(text),
      ),
    );
  }
}