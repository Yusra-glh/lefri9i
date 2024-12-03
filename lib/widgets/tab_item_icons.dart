import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventTabItemIcon extends StatelessWidget {
  final SvgPicture icon;
  final bool isSelected;

  const EventTabItemIcon({
    super.key,
    required this.icon,
    required this.isSelected,
  });

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
      child: icon,
    );
  }
}
