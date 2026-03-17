import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0E0F12);
    const cardColor = Color(0xFF1A1C22);
    const neonGreen = Color(0xFF8CF23C);
    const fieldColor = Color(0xFF12141A);

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Avatar with neon ring
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=3',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Name
              const Text(
                "Ivan Ivanov",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              // Email
              Text(
                user?.email ?? "ivan@mail.com",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),

              const SizedBox(height: 30),

              // Card section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "About Me",
                      style: TextStyle(
                        color: neonGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Flutter developer 🚀 Love building mobile applications.",
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info tiles
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.badge_outlined,
                      label: "Role",
                      value: "Team Lead",
                      neonGreen: neonGreen,
                      fieldColor: fieldColor,
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.group_outlined,
                      label: "Team",
                      value: "Alpha Squad",
                      neonGreen: neonGreen,
                      fieldColor: fieldColor,
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.emoji_events_outlined,
                      label: "Hackathons",
                      value: "3 participated",
                      neonGreen: neonGreen,
                      fieldColor: fieldColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Edit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: neonGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text(
                      "Sign Out",
                      style: TextStyle(
                        color: neonGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color neonGreen,
    required Color fieldColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: neonGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF12141A),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
