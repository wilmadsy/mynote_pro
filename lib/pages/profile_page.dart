import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  

  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: user?.displayName ?? '');
  }

  // 🔥 UPDATE NAME
  Future<void> updateName() async {
    await user?.updateDisplayName(nameController.text);
    await user?.reload();

    setState(() {});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Nama berhasil diupdate")));
  }

  // 🔥 LOGOUT
  Future<void> logout(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updatedUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 AVATAR
            CircleAvatar(
              radius: 40,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Text((user?.displayName ?? "U")[0])
                  : null,
            ),

            const SizedBox(height: 16),

            // 🔥 EMAIL
            Text(
              updatedUser?.email ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // 🔥 INPUT NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateName,
                child: const Text("Simpan"),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
              onPressed: () => logout(context),
              child: const Text("Logout"),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
