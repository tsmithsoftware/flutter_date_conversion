import 'package:flutter/foundation.dart';

/// A system wide logger that can be accessed from anywhere.
abstract class Logger {
  static const AppName = "ControlOfWorks";

  /// Used for logging stages in the app for debugging purposes.
  /// Use this most of the time except there's reason to use the other log types below
  /// Errors logged here will not be seen in the production release
  static void logDebug(String message, [Type sender]) {
    _log(message, LogLevel.DEBUG, sender);
  }

  /// Used to log general info that will be important to see in the production release
  static void logInformative(String message, [Type sender]) {
    _log(message, LogLevel.INFO, sender);
  }

  /// Used for logging errors that are not critical to the running of the application
  static void logWarning(String message, [Type sender]) {
    _log(message, LogLevel.WARNING, sender);
  }

  /// Used for logging errors that are critical to the running of the app or cause the app not to progress with a functionality
  static void logCritical(String message, [Type sender]) {
    _log(message, LogLevel.CRITICAL, sender);
  }

  ///Writes a log message to the console and to a log file.
  static void _log(String message,
      [LogLevel logLevel = LogLevel.DEBUG, Type sender]) {
    var dt = new DateTime.now();
    var timeFormatted = "${dt.hour}:${dt.minute}:${dt.second}";
    String fullMessage;
    var senderString = sender.toString();
    if (sender.toString() == "" || sender == null) {
      fullMessage = '[$AppName] [$timeFormatted] [$logLevel] $message';
    } else {
      fullMessage =
      '[$AppName] [$timeFormatted] [$logLevel] [$senderString] $message';
    }
    if (logLevel == LogLevel.DEBUG && kReleaseMode) {
      return;
    }
    print(fullMessage);
  }
}

enum LogLevel { DEBUG, INFO, WARNING, CRITICAL }
