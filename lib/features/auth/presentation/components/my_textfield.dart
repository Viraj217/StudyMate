import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        // border when unselected
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.tertiary.withValues(
              alpha: 0.6,
            ), // softer unselected border
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        // border when selected
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 1.0), // solid when focused
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary.withValues(
            alpha: 0.7,
          ), // hint text less prominent
        ),
        fillColor: Theme.of(context).colorScheme.secondary.withValues(
          alpha: 0.9,
        ), // background with slight transparency
        filled: true,
      ),
    );
  }
}
