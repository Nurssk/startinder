import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const backgroundColor = Color(0xFF0E0F12);
  static const cardColor = Color(0xFF1A1C22);
  static const neonGreen = Color(0xFF8CF23C);
  static const fieldColor = Color(0xFF12141A);

  final user = FirebaseAuth.instance.currentUser;

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _roleController = TextEditingController();
  final _teamController = TextEditingController();
  final _experienceController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _photoController = TextEditingController();

  bool _isSaving = false;
  bool _isEditing = false;
  bool _controllersPopulated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _roleController.dispose();
    _teamController.dispose();
    _experienceController.dispose();
    _portfolioController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _populateControllers(Map<String, dynamic> data) {
    if (_controllersPopulated) return;
    _nameController.text = data['fullName'] ?? '';
    _bioController.text = data['bio'] ?? '';
    _roleController.text = data['role'] ?? '';
    _teamController.text = data['team'] ?? '';
    _experienceController.text = data['experience'] ?? '';
    _portfolioController.text = data['portfolio'] ?? '';
    _photoController.text = data['photoUrl'] ?? '';
    _controllersPopulated = true;
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'fullName': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'role': _roleController.text.trim(),
        'team': _teamController.text.trim(),
        'experience': _experienceController.text.trim(),
        'portfolio': _portfolioController.text.trim(),
        'photoUrl': _photoController.text.trim(),
        'email': user!.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isEditing = false;
        _controllersPopulated = false;
      });
      _showSnack("Profile saved!");
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.black)),
        backgroundColor: neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        elevation: 0,
        // ✅ Home button — clean, no duplicates
        leading: IconButton(
          icon: const Icon(Icons.home, color: neonGreen),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() {
                _isEditing = false;
                _controllersPopulated = false;
              }),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
        ],
      ),

      // ✅ StreamBuilder — instant, no waiting
      body: StreamBuilder<DocumentSnapshot>(
        stream: user == null
            ? const Stream.empty()
            : FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: neonGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white54)),
            );
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            _populateControllers(data);
          }

          // ✅ Auto-create doc if it doesn't exist
          if (snapshot.hasData && !snapshot.data!.exists) {
            FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
              'fullName': user!.displayName ?? '',
              'email': user!.email ?? '',
              'photoUrl': user!.photoURL ?? '',
              'bio': '',
              'role': '',
              'team': '',
              'experience': '',
              'portfolio': '',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // ── Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: neonGreen, width: 2.5),
                        ),
                      ),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: fieldColor,
                        backgroundImage: _photoController.text.trim().isNotEmpty
                            ? NetworkImage(_photoController.text.trim())
                            : null,
                        child: _photoController.text.trim().isEmpty
                            ? const Icon(Icons.person,
                                color: Colors.white54, size: 40)
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : "Your Name",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),

                  const SizedBox(height: 30),

                  // ── Edit or View mode
                  if (_isEditing) ...[
                    _buildSection("Personal Info", [
                      _buildField(
                          _nameController, "Full Name", Icons.person_outline),
                      const SizedBox(height: 12),
                      _buildField(_photoController, "Profile Photo URL",
                          Icons.image_outlined),
                      const SizedBox(height: 12),
                      _buildField(
                          _bioController, "Bio / About Me", Icons.info_outline,
                          maxLines: 3),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection("Team & Role", [
                      _buildField(
                          _roleController, "Role", Icons.badge_outlined),
                      const SizedBox(height: 12),
                      _buildField(
                          _teamController, "Team Name", Icons.group_outlined),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection("Experience & Portfolio", [
                      _buildField(_experienceController, "Experience",
                          Icons.work_outline,
                          maxLines: 2),
                      const SizedBox(height: 12),
                      _buildField(_portfolioController,
                          "Portfolio URL or GitHub", Icons.link_outlined),
                    ]),
                  ] else ...[
                    _buildInfoCard(
                        "About Me", _bioController.text, Icons.info_outline),
                    const SizedBox(height: 12),
                    _buildTileCard([
                      _buildTile(
                          Icons.badge_outlined, "Role", _roleController.text),
                      _buildTile(
                          Icons.group_outlined, "Team", _teamController.text),
                      _buildTile(Icons.work_outline, "Experience",
                          _experienceController.text),
                      _buildTile(Icons.link_outlined, "Portfolio",
                          _portfolioController.text),
                    ]),
                  ],

                  const SizedBox(height: 30),

                  // ── Save / Edit button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () {
                              if (_isEditing) {
                                _saveProfile();
                              } else {
                                setState(() {
                                  _isEditing = true;
                                  _controllersPopulated = false;
                                });
                              }
                            },
                      child: _isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2.5),
                            )
                          : Text(
                              _isEditing ? "Save Changes" : "Edit Profile",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Sign Out
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: neonGreen),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: const Text("Sign Out",
                          style: TextStyle(
                              color: neonGreen, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Helpers

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.4)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String hint, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: fieldColor,
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: neonGreen, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  color: neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.4)),
          const SizedBox(height: 8),
          Text(value.isNotEmpty ? value : "—",
              style: const TextStyle(color: Colors.white70, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTileCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: tiles
            .expand((t) => [
                  t,
                  if (t != tiles.last)
                    const Divider(
                        color: Color(0xFF12141A),
                        height: 1,
                        indent: 16,
                        endIndent: 16),
                ])
            .toList(),
      ),
    );
  }

  Widget _buildTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: fieldColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: neonGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
                Text(value.isNotEmpty ? value : "—",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
