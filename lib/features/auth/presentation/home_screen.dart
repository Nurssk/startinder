import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'profile_screen.dart';
import 'matches_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const backgroundColor = Color(0xFF0E0F12);
  static const cardColor = Color(0xFF1A1C22);
  static const neonGreen = Color(0xFF8CF23C);
  static const fieldColor = Color(0xFF12141A);

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  Offset position = Offset.zero;
  double angle = 0;

  // ✅ Getter — always fresh
  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      // ✅ Exclude users already swiped on
      final swipesSnap = await FirebaseFirestore.instance
          .collection('swipes')
          .where('from', isEqualTo: uid)
          .get();

      final alreadySwiped =
          swipesSnap.docs.map((d) => d['to'] as String).toSet();

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: uid)
          .get();

      final users = snapshot.docs
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .where((u) =>
              (u['fullName'] ?? '').toString().isNotEmpty &&
              !alreadySwiped.contains(u['uid']))
          .toList();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      position += details.delta;
      angle = (pi / 180) * position.dx / 15;
    });
  }

  void onPanEnd(DragEndDetails details) {
    if (position.dx > 150) {
      swipeRight();
    } else if (position.dx < -150) {
      swipeLeft();
    } else {
      resetPosition();
    }
  }

  void swipeRight() {
    if (_users.isEmpty) return;
    final swipedUser = _users.last;
    setState(() => position += const Offset(600, 0));
    Future.delayed(const Duration(milliseconds: 300), () {
      _handleSwipeRight(swipedUser);
      nextCard();
    });
  }

  void swipeLeft() {
    if (_users.isEmpty) return;
    final swipedUser = _users.last;
    setState(() => position -= const Offset(600, 0));
    Future.delayed(const Duration(milliseconds: 300), () {
      _handleSwipeLeft(swipedUser);
      nextCard();
    });
  }

  Future<void> _handleSwipeLeft(Map<String, dynamic> swipedUser) async {
    final uid = currentUser?.uid;
    final swipedUid = swipedUser['uid'];
    if (uid == null || swipedUid == null) return;

    await FirebaseFirestore.instance
        .collection('swipes')
        .doc('${uid}_$swipedUid')
        .set({
      'from': uid,
      'to': swipedUid,
      'direction': 'left',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _handleSwipeRight(Map<String, dynamic> swipedUser) async {
    final uid = currentUser?.uid;
    final swipedUid = swipedUser['uid'];
    if (uid == null || swipedUid == null) return;

    // ✅ Save right swipe
    await FirebaseFirestore.instance
        .collection('swipes')
        .doc('${uid}_$swipedUid')
        .set({
      'from': uid,
      'to': swipedUid,
      'direction': 'right',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ✅ Check mutual swipe
    final mutualSwipe = await FirebaseFirestore.instance
        .collection('swipes')
        .doc('${swipedUid}_$uid')
        .get();

    final isMutual =
        mutualSwipe.exists && mutualSwipe.data()?['direction'] == 'right';

    if (isMutual) {
      final matchId = uid.compareTo(swipedUid) < 0
          ? '${uid}_$swipedUid'
          : '${swipedUid}_$uid';

      // ✅ Create match document
      await FirebaseFirestore.instance.collection('matches').doc(matchId).set({
        'users': [uid, swipedUid],
        'timestamp': FieldValue.serverTimestamp(),
        'lastMessage': '🎉 You matched!',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // ✅ Auto first message
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(matchId)
          .collection('messages')
          .add({
        'text':
            '🎉 You matched! Say hello and start building something amazing together.',
        'senderId': 'system',
        'senderName': 'System',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) _showMatchDialog(swipedUser, matchId);
    }
  }

  void _showMatchDialog(Map<String, dynamic> matchedUser, String matchId) {
    final name = matchedUser['fullName'] ?? 'Someone';
    final role = matchedUser['role'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: neonGreen.withOpacity(0.1),
                  border: Border.all(color: neonGreen, width: 2),
                ),
                child: const Icon(Icons.favorite, color: neonGreen, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "It's a Match! 🎉",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "You and $name both want to team up!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              if (role.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                      color: neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 24),
              // ✅ Open chat button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          matchId: matchId,
                          otherUserName: name,
                          otherUid: matchedUser['uid'],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Send Message",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Keep Swiping",
                    style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void nextCard() {
    setState(() {
      if (_users.isNotEmpty) _users.removeLast();
      position = Offset.zero;
      angle = 0;
    });
  }

  void resetPosition() {
    setState(() {
      position = Offset.zero;
      angle = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Discover",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        "Teammates",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // ── Refresh button
                      GestureDetector(
                        onTap: () {
                          setState(() => _isLoading = true);
                          _loadUsers();
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.refresh,
                              color: Colors.white54, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // ✅ Chat / Matches button with green dot badge
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MatchesScreen()),
                        ),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('matches')
                                .where('users', arrayContains: currentUser?.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final hasMatches = snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty;
                              return Stack(
                                children: [
                                  const Center(
                                    child: Icon(Icons.chat_bubble_outline,
                                        color: Colors.white54, size: 20),
                                  ),
                                  if (hasMatches)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: neonGreen,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // ── Profile button
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        ),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: neonGreen, width: 1.5),
                          ),
                          child: const Icon(Icons.person,
                              color: neonGreen, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Card Stack
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: neonGreen),
                    )
                  : _users.isEmpty
                      ? _buildEmptyState()
                      : Stack(
                          alignment: Alignment.center,
                          children: _users.asMap().entries.map((entry) {
                            final index = entry.key;
                            final user = entry.value;
                            final isTop = index == _users.length - 1;

                            if (isTop) {
                              final swipeProgress =
                                  (position.dx / 150).clamp(-1.0, 1.0);

                              return GestureDetector(
                                onPanUpdate: onPanUpdate,
                                onPanEnd: onPanEnd,
                                child: Transform.translate(
                                  offset: position,
                                  child: Transform.rotate(
                                    angle: angle,
                                    child: Stack(
                                      children: [
                                        _buildUserCard(user),
                                        if (swipeProgress > 0.1)
                                          Positioned(
                                            top: 30,
                                            left: 30,
                                            child: _buildSwipeLabel(
                                              "INVITE",
                                              neonGreen,
                                              swipeProgress,
                                            ),
                                          ),
                                        if (swipeProgress < -0.1)
                                          Positioned(
                                            top: 30,
                                            right: 30,
                                            child: _buildSwipeLabel(
                                              "SKIP",
                                              Colors.redAccent,
                                              -swipeProgress,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            final scale =
                                1.0 - ((_users.length - 1 - index) * 0.04);
                            final offset = (_users.length - 1 - index) * 8.0;

                            return Transform.translate(
                              offset: Offset(0, offset),
                              child: Transform.scale(
                                scale: scale,
                                child: _buildUserCard(user),
                              ),
                            );
                          }).toList(),
                        ),
            ),

            const SizedBox(height: 20),

            if (!_isLoading && _users.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "${_users.length} teammate${_users.length == 1 ? '' : 's'} to discover",
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 12, letterSpacing: 0.5),
                ),
              ),

            if (!_isLoading && _users.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _circleButton(
                        Icons.close_rounded, Colors.redAccent, swipeLeft,
                        label: "Skip"),
                    _circleButton(Icons.favorite_rounded, neonGreen, swipeRight,
                        label: "Invite"),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final name = user['fullName'] ?? 'Unknown';
    final role = user['role'] ?? '';
    final team = user['team'] ?? '';
    final bio = user['bio'] ?? '';
    final experience = user['experience'] ?? '';
    final portfolio = user['portfolio'] ?? '';
    final photoUrl = user['photoUrl'] ?? '';

    return Container(
      width: 320,
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: neonGreen.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: fieldColor,
                image: photoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            cardColor.withValues(alpha: 0.95),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  if (photoUrl.isEmpty)
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: backgroundColor,
                          border: Border.all(color: neonGreen, width: 2),
                        ),
                        child: const Icon(Icons.person,
                            color: Colors.white38, size: 36),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        if (role.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: neonGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: neonGreen.withValues(alpha: 0.4),
                                  width: 1),
                            ),
                            child: Text(
                              role,
                              style: const TextStyle(
                                color: neonGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (team.isNotEmpty)
                      _buildInfoRow(Icons.group_outlined, team),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (experience.isNotEmpty)
                          _buildChip(Icons.work_outline, experience),
                        if (portfolio.isNotEmpty)
                          _buildChip(Icons.link_rounded, "Portfolio"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white38, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeLabel(String text, Color color, double opacity) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardColor,
              border:
                  Border.all(color: neonGreen.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.people_outline,
                color: Colors.white38, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            "No teammates yet",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Invite others to join the hackathon",
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap,
      {required String label}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
              border:
                  Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.white38, fontSize: 11, letterSpacing: 0.5)),
      ],
    );
  }
}
