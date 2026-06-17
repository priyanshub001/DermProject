import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectdermsight/main_screen.dart';
import 'api_service.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool obscurePassword = true;
  bool rememberMe = true;
  bool isLoading = false; // ✅ ADD

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void setLoading(bool val) {
    setState(() => isLoading = val);
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

                  // GREEN HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 90),
                    decoration: const BoxDecoration(
                      color: Color(0xff2E9C7A),
                    ),
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
                        Text("Welcome back", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                  // FORM CARD
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

                          // EMAIL
                          const Text("Email address"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: "Enter your email",
                              prefixIcon: const Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.black12,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // PASSWORD LABEL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Password"),
                              Text(
                                "Forgot password?",
                                style: TextStyle(color: Color(0xff2E9C7A), fontSize: 12),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // PASSWORD FIELD
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Enter your password",
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
                              fillColor: Colors.black12,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // REMEMBER ME
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor: const Color(0xff2E9C7A),
                                onChanged: (v) {
                                  setState(() {
                                    rememberMe = v!;
                                  });
                                },
                              ),
                              const Text("Remember me"),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // LOGIN BUTTON
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

                                String email = emailController.text.trim();
                                String password = passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Enter email and password")),
                                  );
                                  return;
                                }

                                setLoading(true); // START

                                try {
                                  final response = await ApiService.loginUser(
                                    email: email,
                                    password: password,
                                  );

                                  if (response.containsKey("token")) {
                                    String token = response["token"];

                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setString("token", token);

                                    final profile = await ApiService.getProfile(token);
                                    await prefs.setString("name", profile["name"] ?? "");
                                    await prefs.setString("email", profile["email"] ?? "");
                                    await prefs.setString("age", profile["age"] ?? "");

                                    setLoading(false); //  STOP

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MainScreen(),
                                      ),
                                    );
                                  } else {
                                    setLoading(false); //  STOP
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(response["msg"] ?? "Login failed")),
                                    );
                                  }
                                } catch (e) {
                                  setLoading(false); //  STOP
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          const Center(child: Text("or")),
                          const SizedBox(height: 10),

                          // GOOGLE BUTTON
                          GestureDetector(
                            onTap: () async {
                              try {
                                final account = await _googleSignIn.signIn();
                                if (account == null) return;

                                setLoading(true); // START

                                String email = account.email;
                                String name = account.displayName ?? "";

                                final response = await ApiService.googleLogin(
                                  name: name,
                                  email: email,
                                );

                                if (response.containsKey("token")) {
                                  String token = response["token"];

                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setString("token", token);
                                  await prefs.setString("name", name);
                                  await prefs.setString("email", email);

                                  setLoading(false); //  STOP

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(),
                                    ),
                                        (route) => false,
                                  );
                                } else {
                                  setLoading(false); //  STOP
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Google login failed")),
                                  );
                                }
                              } catch (e) {
                                setLoading(false); //  STOP
                                print("Google Login Error: $e");
                              }
                            },
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
                                  Icon(Icons.g_mobiledata, size: 28),
                                  SizedBox(width: 8),
                                  Text("Continue with Google"),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // REGISTER LINK
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("New user? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    color: Color(0xff2E9C7A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                      "Logging in...",
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
}