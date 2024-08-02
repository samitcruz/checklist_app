import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final bool isNoCheckbox;
  final TextStyle textStyle;

  CustomCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    this.textStyle = const TextStyle(),
    this.isNoCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            onChanged(!value);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                color: value ? (isNoCheckbox ? Colors.red : Colors.green) : Colors.grey,
                width: 2.0,
              ),
              color: value ? Colors.transparent : Colors.transparent,
            ),
            child: value
                ? isNoCheckbox
                    ? Icon(Icons.close, size: 20.0, color: Colors.red)
                    : Icon(Icons.check, size: 20.0, color: Colors.green)
                : SizedBox(width: 20.0, height: 20.0),
          ),
        ),
        SizedBox(width: 8.0),
        Text(
          label,
          style: GoogleFonts.openSans(textStyle: textStyle),
        ),
      ],
    );
  }
}
