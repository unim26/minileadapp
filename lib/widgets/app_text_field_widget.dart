import 'package:flutter/material.dart';

class AppTextFieldWidget extends StatelessWidget {
  const AppTextFieldWidget({
    super.key,
    required this.searchCtrl,
    this.onChanged,
    required this.hintText,
    required this.prefixIcon,
  });

  final TextEditingController searchCtrl;
  final void Function(String)? onChanged;
  final String hintText;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: searchCtrl,
          decoration: InputDecoration(
            prefixIcon: Icon(
              prefixIcon,
              color: Theme.of(context).colorScheme.primary,
            ),
            hintText: hintText,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
