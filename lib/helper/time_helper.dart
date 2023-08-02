import 'dart:developer';

import 'package:flutter/material.dart';

class TimeHelper {
  static String getExactTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    log('date: $date');
    return TimeOfDay.fromDateTime(date).format(context);
  }
}
