import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const CustomAppBar({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: Color.fromRGBO(0, 7, 45, 1),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: screenWidth * 0.045),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontFamily: "Urbanist",
          fontSize: screenWidth * 0.045, // Adjusts font size dynamically
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      titleSpacing: screenWidth * 0.02, // Ensures proper spacing
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
