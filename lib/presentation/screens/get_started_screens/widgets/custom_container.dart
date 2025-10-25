import 'package:flutter/material.dart';

Widget customContainer(
  {required Widget child}
) {
  return Container(
 decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0xFFBBDEFB)],
            stops: [0.75, 0.5, 0.95],
          ),
        ),
        child: child,
  );
}
