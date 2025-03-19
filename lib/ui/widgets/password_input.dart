
import 'package:flutter/material.dart';

class PasswordInput extends StatelessWidget {
  //icon can null
  final IconData? icon;
  final String hintText;
  final bool isObscured;
  final VoidCallback onToggleVisibility;
  final FormFieldValidator<String>? validator;
  final void Function(String?)? onSaved;


  const PasswordInput({
    super.key,
    required this.icon,
    required this.hintText,
    required this.isObscured,
    required this.onToggleVisibility,
    required this.validator,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
            obscureText: isObscured,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFFADAEBC),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: icon != null
                  ? Icon(
                        icon,
                        size: 20,
                        color: Colors.black,
                      )
                  : null,
              suffixIcon: IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: onToggleVisibility,
                    splashRadius: 8,
                    padding: const EdgeInsets.all(8),
                  ),
            ),
            validator: validator,
            onSaved: onSaved,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
      ],
    );
  }
}