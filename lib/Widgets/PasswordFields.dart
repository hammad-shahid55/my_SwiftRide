import 'package:flutter/material.dart';

class PasswordFields extends StatefulWidget {
  const PasswordFields({super.key});

  @override
  _PasswordFieldsState createState() => _PasswordFieldsState();
}

class _PasswordFieldsState extends State<PasswordFields> {
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        _buildPasswordField(
          "Password",
          _passwordController,
          _obscurePassword,
          () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          screenWidth,
          screenHeight,
        ),
        SizedBox(height: screenHeight * 0.03),
        _buildPasswordField(
          "Repeat Password",
          _repeatPasswordController,
          _obscureRepeatPassword,
          () {
            setState(() {
              _obscureRepeatPassword = !_obscureRepeatPassword;
            });
          },
          screenWidth,
          screenHeight,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback onToggle,
    double width,
    double height,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color.fromRGBO(62, 62, 62, 1),
            fontFamily: 'Urbanist',
          ),
        ),
        SizedBox(height: height * 0.01),
        TextField(
          controller: controller,
          obscureText: obscureText,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          style: const TextStyle(
            color: Color.fromRGBO(62, 62, 62, 1),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: height * 0.02,
              horizontal: width * 0.05,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width * 0.08),
              borderSide: const BorderSide(
                color: Color.fromRGBO(226, 223, 223, 1),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width * 0.08),
              borderSide: const BorderSide(
                color: Color.fromRGBO(226, 223, 223, 1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width * 0.08),
              borderSide: const BorderSide(
                color: Color.fromRGBO(226, 223, 223, 1),
                width: 1,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color.fromRGBO(185, 185, 185, 1),
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
