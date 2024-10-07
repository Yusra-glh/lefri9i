import 'package:flutter/material.dart';

class EventTabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final double fontSize;

  const EventTabItem(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.012,
        horizontal: 0.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: Colors.transparent,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.grey : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
