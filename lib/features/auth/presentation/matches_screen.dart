import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  static const backgroundColor = Color(0xFF0E0F12);
  static const cardColor = Color(0xFF1A1C22);
  static const neonGreen = Color(0xFF8CF23C);
  static const fieldColor = Color(0xFF12141A);

  String get currentUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Matches",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .where('users', arrayContains: currentUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: neonGreen));
          }

          // ✅ No matches — show friendly empty state, no chat access
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final matches = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final match = matches[index].data() as Map<String, dynamic>;
              final matchId = matches[index].id;
              final users = List<String>.from(match['users']);
              final otherUid = users.firstWhere((uid) => uid != currentUid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUid)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const SizedBox(height: 80);
                  }

                  final user = userSnap.data!.data() as Map<String, dynamic>;
                  final name = user['fullName'] ?? 'Unknown';
                  final role = user['role'] ?? '';
                  final team = user['team'] ?? '';
                  final lastMessage = match['lastMessage'] ?? '🎉 You matched!';

                  // ✅ Only matched users can open chat
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          matchId: matchId,
                          otherUserName: name,
                          otherUid: otherUid,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: neonGreen.withValues(alpha: 0.15), width: 1),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: fieldColor,
                              border: Border.all(color: neonGreen, width: 2),
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white54, size: 28),
                          ),
                          const SizedBox(width: 14),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                if (role.isNotEmpty)
                                  Text(role,
                                      style: const TextStyle(
                                          color: neonGreen, fontSize: 12)),
                                if (team.isNotEmpty)
                                  Text(team,
                                      style: const TextStyle(
                                          color: Colors.white38, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // ✅ Chat button — only visible on matched cards
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: neonGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.chat_bubble_outline,
                                color: neonGreen, size: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Clean empty state — no way to access chat from here
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1C22),
              border: Border.all(
                  color: const Color(0xFF8CF23C).withValues(alpha: 0.3),
                  width: 2),
            ),
            child: const Icon(Icons.chat_bubble_outline,
                color: Colors.white24, size: 38),
          ),
          const SizedBox(height: 24),
          const Text(
            "No matches yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "When you and someone both\nswipe right, you'll match here",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF8CF23C).withValues(alpha: 0.3),
                  width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swipe, color: Color(0xFF8CF23C), size: 16),
                SizedBox(width: 8),
                Text(
                  "Go swipe on the Discover tab",
                  style: TextStyle(color: Color(0xFF8CF23C), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
