String formatFromString(String str) {
  return format(
    DateTime.fromMillisecondsSinceEpoch(
      int.parse(str),
    ),
  );
}

String format(DateTime dateTime) {
  return "${dateTime.day}. ${_monthFromInt(dateTime.month)} ${dateTime.year.toString().substring(2)}";
}

String _monthFromInt(int index) {
  assert(index >= 0 && index <= 12);
  switch (index) {
    case 1:
      return "Jan";
    case 2:
      return "Feb";
    case 3:
      return "Mar";
    case 4:
      return "Apr";
    case 5:
      return "May";
    case 6:
      return "Jun";
    case 7:
      return "Jul";
    case 8:
      return "Aug";
    case 9:
      return "Sept";
    case 10:
      return "Oct";
    case 11:
      return "Nov";
    case 12:
      return "Dec";
  }
  return "";
}
