import 'package:flutter/material.dart';
import 'package:gark_academy/utils/colors.dart';

class WeekView extends StatelessWidget {
  final int weekIndex;
  final Function(DateTime) onDaySelected;
  final DateTime selectedDate;

  const WeekView(
      {super.key,
      required this.weekIndex,
      required this.onDaySelected,
      required this.selectedDate});

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final daysInWeek = List.generate(7, (index) {
      final firstDayOfYear = DateTime(DateTime.now().year, 1, 1);
      final date = firstDayOfYear.add(Duration(days: weekIndex * 7 + index));
      return date;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: daysInWeek.map((date) {
        return GestureDetector(
          onTap: () => onDaySelected(date),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.104,
            height: MediaQuery.of(context).size.height * 0.048,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSameDate(date, selectedDate)
                  ? primaryColor
                  : Colors.transparent,
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: isSameDate(date, selectedDate)
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
