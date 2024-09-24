import 'package:bookapp/pages/profile.dart';
import 'package:bookapp/widgets/promo_link_widget.dart';
import 'package:flutter/material.dart';
import 'daily_reading.dart';
import 'leaderboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  _buildBookContainer(
                    context,
                    'Profil',
                    Colors.blue,
                    Icons.person,
                    const ProfileScreen(),
                  ),
                  const SizedBox(height: 20),
                  _buildBookContainer(
                    context,
                    'Liderlik Sıralaması',
                    Colors.green,
                    Icons.leaderboard,
                    LeaderboardScreen(),
                  ),
                  const SizedBox(height: 20),
                  _buildBookContainer(
                    context,
                    'Günlük Okuma Girişi',
                    Colors.orange,
                    Icons.book,
                    DailyReadingScreen(),
                  ),
                ],
              ),
              const PromoLinkWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookContainer(BuildContext context, String title, Color color,
      IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 40.0),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ],
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white)
          ],
        ),
      ),
    );
  }
}
