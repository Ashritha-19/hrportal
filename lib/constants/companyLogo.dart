import 'package:flutter/material.dart';

class CompanyLogoIcon extends StatelessWidget {
  final double size;

  const CompanyLogoIcon({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/icon.png",
      height: size,
      width: size,
      fit: BoxFit.contain,
    );
  }
}