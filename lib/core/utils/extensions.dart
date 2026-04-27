import 'package:flutter/material.dart';
import 'package:give_track/config/app_design_tokens.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toFormattedString() {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  String toDateString() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  String toRelativeString() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  GiveTrackTokens get giveTrack =>
      Theme.of(this).extension<GiveTrackTokens>() ?? GiveTrackTokens.light;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
}
