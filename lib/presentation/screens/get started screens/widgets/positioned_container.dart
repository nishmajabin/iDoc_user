import 'package:flutter/material.dart';

Widget positionedLeft() {
  return Positioned(
    top: -20,
    left: -80,
    child: Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF052C40), Color(0xFF6AD2FF)],
          stops: [0.4, 1],
        ),
      ),
    ),
  );
}

Widget positionedRight() {
  return Positioned(
    top: -20,
    right: -80,
    child: Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF052C40), Color(0xFF6AD2FF)],
          stops: [0.4, 1],
        ),
      ),
    ),
  );
}
