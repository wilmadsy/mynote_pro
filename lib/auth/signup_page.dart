import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final Color _primaryColor = const Color(0xFF4F46E5);
  final Color _darkTextColor = const Color(0xFF0F172A);
  final Color _bodyTextColor = const Color(0xFF475569);
  final Color _borderColor = const Color(0xFFE2E8F0);
  final Color _bglight = const Color(0xFFF8FAFC);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Fungsi Registrasi Akun Baru ke Firebase Auth
  Future<void> _registerWithFirebase() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom wajib diisi!")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password dan konfirmasi tidak cocok!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan nama lengkap ke dalam profil Firebase Auth user
      await userCredential.user?.updateDisplayName(name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil! Silakan masuk.")),
        );
        Navigator.pop(context); // Kembali ke halaman Login
      }
    } on FirebaseAuthException catch (e) {
      String message = "Gagal mendaftar";
      if (e.code == 'weak-password') {
        message = "Password terlalu lemah (minimal 6 karakter).";
      } else if (e.code == 'email-already-in-use') {
        message = "Email ini sudah digunakan oleh akun lain.";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 70),

                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: _darkTextColor,
                    ),
                  ),
                  Text(
                    "Sign up to get started",
                    style: TextStyle(color: _bodyTextColor),
                  ),

                  const SizedBox(height: 40),

                  _input("Full Name", Icons.person, controller: nameController),
                  const SizedBox(height: 20),
                  _input("Email", Icons.mail, controller: emailController),
                  const SizedBox(height: 20),
                  _input("Password", Icons.lock, isPassword: true, controller: passwordController),
                  const SizedBox(height: 20),
                  _input(
                    "Confirm Password", 
                    Icons.lock, 
                    isPassword: true, 
                    isConfirm: true, 
                    controller: confirmPasswordController
                  ),

                  const SizedBox(height: 30),

                  // Tombol Sign Up dengan Loading Indicator
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
                      onPressed: _isLoading ? null : _registerWithFirebase,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Already have account? Sign in",
                      style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool isConfirm = false,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _darkTextColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword
            ? (isConfirm ? !_isConfirmPasswordVisible : !_isPasswordVisible)
            : false,
        style: TextStyle(color: _darkTextColor, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          hintText: hint,
          hintStyle: TextStyle(color: _bodyTextColor.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: _primaryColor),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      if (isConfirm) {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      } else {
                        _isPasswordVisible = !_isPasswordVisible;
                      }
                    });
                  },
                  icon: Icon(
                    (isConfirm ? _isConfirmPasswordVisible : _isPasswordVisible)
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: _bodyTextColor,
                  ),
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}