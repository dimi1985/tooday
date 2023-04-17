import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tooday/widgets/theme_provider.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final Function(bool?) onChanged;

  const CustomCheckbox(
      {super.key, required this.isChecked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        decoration: BoxDecoration(
          color: isChecked
              ? themeProvider.isDarkThemeEnabled
                  ? Color.fromARGB(255, 78, 0, 167)
                  : Color.fromARGB(255, 48, 18, 119)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: isChecked
                ? themeProvider.isDarkThemeEnabled
                    ? const Color.fromARGB(255, 189, 189, 189)
                    : const Color.fromARGB(255, 121, 122, 121)
                : Colors.grey,
            width: 1.5,
          ),
        ),
        width: 24.0,
        height: 24.0,
        child: isChecked
            ? const Icon(
                Icons.check,
                size: 16.0,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
