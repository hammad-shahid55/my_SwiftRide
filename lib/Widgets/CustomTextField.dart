import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool isEmail; // ✅ new flag for email
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.suffixIcon,
    this.isPassword = false,
    this.isEmail = false, // ✅ default false
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;
  String? _errorText;

  String? _validate(String value) {
    if (widget.isEmail) {
      if (!value.endsWith('@must.com')) {
        return 'Email must be in must@gmail.com format';
      }
    }
    if (widget.isPassword) {
      final hasUpper = value.contains(RegExp(r'[A-Z]'));
      final hasLower = value.contains(RegExp(r'[a-z]'));
      final hasDigit = value.contains(RegExp(r'\d'));
      final hasSymbol = value.contains(RegExp(r'[!@#\$&*~]'));
      if (!hasUpper || !hasLower || !hasDigit || !hasSymbol) {
        return 'Password must have upper, lower, digit & symbol';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Urbanist',
            color: Color.fromRGBO(62, 62, 62, 1),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: widget.controller,
          cursorColor: const Color.fromRGBO(62, 62, 62, 1),
          obscureText: widget.isPassword ? !_isPasswordVisible : false,
          obscuringCharacter: '*',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Urbanist',
            color: Color.fromRGBO(62, 62, 62, 1),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            hintText: widget.isEmail ? 'example@gmail.com' : widget.hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Urbanist',
              color: Color.fromRGBO(185, 185, 185, 1),
            ),
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color.fromRGBO(185, 185, 185, 1),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                    : (widget.suffixIcon != null
                        ? Icon(
                          widget.suffixIcon,
                          color: const Color.fromRGBO(185, 185, 185, 1),
                        )
                        : null),
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromRGBO(226, 223, 223, 1),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromRGBO(226, 223, 223, 1),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromRGBO(226, 223, 223, 1),
                width: 1.2,
              ),
            ),
            errorText: _errorText,
          ),
          onChanged: (value) {
            setState(() {
              _errorText = _validate(value);
            });
          },
        ),
      ],
    );
  }
}
