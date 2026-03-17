import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> teams = [
    "AI Hackers",
    "Flutter Ninjas",
    "Cyber Squad",
  ];

  Offset position = Offset.zero;
  double angle = 0;

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
    setState(() {
      position += const Offset(500, 0);
    });
    Future.delayed(const Duration(milliseconds: 300), nextCard);
  }

  void swipeLeft() {
    setState(() {
      position -= const Offset(500, 0);
    });
    Future.delayed(const Duration(milliseconds: 300), nextCard);
  }

  void nextCard() {
    setState(() {
      teams.removeLast();
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
    const backgroundColor = Color(0xFF0E0F12);
    const neonGreen = Color(0xFF8CF23C);

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
                  const Text(
                    "Discover Teams",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // ✅ Fixed: navigate to Profile without signing out
                  IconButton(
                    icon: const Icon(Icons.person, color: neonGreen),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Swipe Stack
            Expanded(
              child: teams.isEmpty
                  ? const Center(
                      child: Text(
                        "No more teams",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: teams.asMap().entries.map((entry) {
                        final index = entry.key;
                        final team = entry.value;

                        if (index == teams.length - 1) {
                          return GestureDetector(
                            onPanUpdate: onPanUpdate,
                            onPanEnd: onPanEnd,
                            child: Transform.translate(
                              offset: position,
                              child: Transform.rotate(
                                angle: angle,
                                child: _teamCard(team),
                              ),
                            ),
                          );
                        } else {
                          return Transform.scale(
                            scale: 0.95,
                            child: _teamCard(team),
                          );
                        }
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 30),

            // ── Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circleButton(Icons.close, Colors.red, swipeLeft),
                _circleButton(Icons.favorite, neonGreen, swipeRight),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _teamCard(String teamName) {
    const neonGreen = Color(0xFF8CF23C);

    return Container(
      width: 340,
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1C22), Color(0xFF12141A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: neonGreen.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.groups, size: 100, color: neonGreen),
          Column(
            children: [
              Text(
                teamName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Looking for UI Designer",
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A1C22),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 25,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
