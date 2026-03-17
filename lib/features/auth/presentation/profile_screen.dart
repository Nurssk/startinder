import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),

            // Аватар
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=3',
              ),
            ),

            SizedBox(height: 20),

            // Имя
            Text(
              "Иван Иванов",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            // Email
            Text(
              "ivan@mail.com",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 20),

            // О себе
            Text(
              "Flutter разработчик 🚀 Люблю создавать мобильные приложения.",
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 30),

            // Кнопка
            ElevatedButton(
              onPressed: null,
              child: Text("Редактировать"),
            ),
          ],
        ),
      ),
    );
  }
}
