import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mynote_pro/pages/home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _togglePassword() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // Desain Warna
  final Color _primaryColor = const Color(0xFF4F46E5);
  final Color _darkTextColor = const Color(0xFF0F172A);
  final Color _bodyTextColor = const Color(0xFF475569);
  final Color _borderColor = const Color(0xFFE2E8F0);
  final Color _bglight = const Color(0xFFF8FAFC);

  // Fungsi Login ke Firebase Auth (Sudah Diperbaiki)
  Future<bool> _loginWithFirebase() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password tidak boleh kosong!")),
      );
      return false;
    }

    // 🔥 KUNCI UTAMA: Ambil messenger SEBELUM await agar aman dari async gap
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Berhasil login! (AuthWrapper akan otomatis mendeteksi dan pindah page)
      messenger.showSnackBar(const SnackBar(content: Text("Login berhasil!")));

      return true;
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan";

      // 🔥 Ditambahkan 'invalid-credential' karena Firebase versi baru menyatukan error code ini
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = "Email atau password salah.";
      } else if (e.code == 'invalid-email') {
        message = "Format email salah.";
      } else if (e.code == 'user-disabled') {
        message = "Akun ini telah dinonaktifkan.";
      }

      messenger.showSnackBar(SnackBar(content: Text(message)));
      return false;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Error: $e")));
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi Google Sign-In (Sudah Diperbaiki)
  Future<bool> _signInWithGoogle() async {
    if (!mounted) return false;

    // 🔥 Ambil messenger sebelum proses async dimulai
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Memaksa sistem selalu menampilkan pilihan akun Google
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return false; // User membatalkan login, keluar dengan aman
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Berhasil login! (AuthWrapper yang handle pindah page)
      messenger.showSnackBar(
        const SnackBar(content: Text("Login dengan Google berhasil!")),
      );

      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Gagal login Google: $e")));
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bglight,
      body: Stack(
        children: [
          Backgrounddecoration(color: _primaryColor),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        _LoginHeader(
                          darkColor: _darkTextColor,
                          bodyColor: _darkTextColor,
                        ),

                        const SizedBox(height: 48),
                        _LoginFormFields(
                          primaryColor: _primaryColor,
                          darkColor: _darkTextColor,
                          bodyColor: _bodyTextColor,
                          borderColor: _borderColor,
                          isPasswordVisible: _isPasswordVisible,
                          onTogglePassword: _togglePassword,
                          emailController: emailController,
                          passwordController: passwordController,
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkTextColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    final result = await _loginWithFirebase();
                                    if (result) {
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) => HomePage(),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Sign in",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        _SosialLoginSection(
                          bodyColor: _bodyTextColor,
                          borderColor: _borderColor,
                          darkColor: _darkTextColor,
                          onGooglePressed: () async {
                            final result = await _signInWithGoogle();
                            if (result) {
                              if (mounted) {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                );
                              }
                            }
                          },
                        ),

                        const SizedBox(height: 20),
                        _FooterSection(
                          bodyColor: _bodyTextColor,
                          primaryColor: _primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================== COMPONENT WIDGETS (SAMA SEPERTI SEBELUMNYA) ===================

class Backgrounddecoration extends StatelessWidget {
  final Color color;
  const Backgrounddecoration({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -90,
          child: _blob(280, color.withOpacity(0.08)),
        ),
        Positioned(
          bottom: -80,
          right: -60,
          child: _blob(230, color.withOpacity(0.08)),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _LoginHeader extends StatelessWidget {
  final Color darkColor, bodyColor;
  const _LoginHeader({required this.darkColor, required this.bodyColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 70),
        Text(
          "Welcome back",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: darkColor,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          "Enter your credentials to access your account",
          style: TextStyle(fontSize: 14, color: bodyColor, height: 1.5),
        ),
      ],
    );
  }
}

class _LoginFormFields extends StatelessWidget {
  final Color primaryColor, darkColor, bodyColor, borderColor;
  final bool isPasswordVisible;
  final VoidCallback onTogglePassword;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _LoginFormFields({
    required this.primaryColor,
    required this.darkColor,
    required this.bodyColor,
    required this.borderColor,
    required this.isPasswordVisible,
    required this.onTogglePassword,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("email address"),
        _inputField(
          Icons.mail_outline_rounded,
          "Enter your email",
          controller: emailController,
        ),
        const SizedBox(height: 20),
        _label("password"),
        _inputField(
          Icons.lock_open_rounded,
          "Enter your password",
          isPassword: true,
          controller: passwordController,
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 20,
              color: bodyColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: bodyColor.withOpacity(0.8),
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _inputField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    Widget? suffix,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        style: TextStyle(color: darkColor, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: bodyColor.withOpacity(0.4), fontSize: 15),
          prefixIcon: Icon(icon, color: primaryColor, size: 22),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class _SosialLoginSection extends StatelessWidget {
  final Color bodyColor, darkColor, borderColor;
  final VoidCallback onGooglePressed;

  const _SosialLoginSection({
    required this.bodyColor,
    required this.borderColor,
    required this.darkColor,
    required this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            "Or continue with",
            style: TextStyle(
              color: bodyColor.withOpacity(0.7),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onGooglePressed,
                borderRadius: BorderRadius.circular(16),
                child: _title(
                  "Google",
                  "https://developers.google.com/identity/images/g-logo.png",
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16),
                child: _title("Apple", null, icon: Icons.apple),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _title(String label, String? imgUrl, {IconData? icon}) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imgUrl != null)
            Image.network(imgUrl, height: 18)
          else
            Icon(icon, size: 22, color: darkColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: darkColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  final Color primaryColor, bodyColor;
  const _FooterSection({required this.bodyColor, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("New here?", style: TextStyle(color: bodyColor)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            );
          },
          child: Text(
            "Create an Account",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
