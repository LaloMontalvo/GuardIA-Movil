import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formateador de fechas para la app
class DateFormatter {
  DateFormatter._();

  static final _timeFormat = DateFormat('HH:mm');
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Formatea una fecha con formato relativo (hoy, ayer, etc.)
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Hoy ${_timeFormat.format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${_timeFormat.format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return _dateFormat.format(dateTime);
    }
  }

  /// Formatea solo la hora
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Formatea fecha completa
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }
}
