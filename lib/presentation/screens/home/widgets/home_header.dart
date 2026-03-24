import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/data/models/user_model.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/medical_chat_factory.dart';
import 'package:idoc_user/presentation/screens/chat/patient_chat_room_list_screen.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_doctors_carousel.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:idoc_user/presentation/screens/doctors/favorite_doctors_screen.dart';

class HomeHeader extends StatelessWidget {
  final UserModel user;
  const HomeHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 280,
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildTitle(), _buildActions()],
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          top: 170,
          left: 0,
          right: 0,
          child: FeaturedDoctorsCarousel(),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Find Your',
          style: TextStyle(
            color: Color.fromARGB(255, 35, 35, 35),
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          'Specialist',
          style: TextStyle(
            color: Color.fromARGB(255, 48, 48, 48),
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FavoriteDoctorsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.favorite_border, size: 28),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedicalChatFactory.create(),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.chat_bubble_2_fill, size: 28),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PatientChatRoomListScreen(
                      patientId: user.uid,
                      patientName: user.name,
                      patientProfileImageUrl: user.profileImageUrl,
                    ),
                  ),
                );
              },
              icon: const Icon(Symbols.sms_rounded, size: 30),
            ),
          ],
        );
      },
    );
  }
}
