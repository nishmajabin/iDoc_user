import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/home/widgets/custom_carousel.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

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
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTitle(),
                    _buildActions(),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 190,
          left: 0,
          right: 0,
          child: buildCarousel([]),
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
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.search, size: 28),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Symbols.sms_rounded, size: 28),
        ),
      ],
    );
  }
}