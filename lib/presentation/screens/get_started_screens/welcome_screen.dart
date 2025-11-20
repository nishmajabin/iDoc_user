import 'package:flutter/material.dart';
import 'package:second_project/core/constants/color.dart';
import 'package:second_project/presentation/screens/get_started_screens/widgets/get_started_button.dart';
import 'package:second_project/presentation/screens/get_started_screens/widgets/layer_blur_container.dart';
import 'package:second_project/presentation/screens/get_started_screens/widgets/welcom_title.dart';
import 'package:second_project/presentation/screens/get_started_screens/widgets/welcome_description.dart';
import 'package:second_project/presentation/screens/get_started_screens/widgets/welcome_image.dart';
import 'package:second_project/presentation/screens/get_started_screens/widgets/welcome_logo_text.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          layerBlur(context),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          const WelcomeLogoText(),
                          const SizedBox(height: 20),
                          const WelcomeTitle(),
                          const SizedBox(height: 10),
                          const WelcomeDescription(),
                          SizedBox(height: screenSize.height * 0.07),
                          const WelcomeImage(height: 300),
                          SizedBox(height: 60),
                          const GetStartedButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
