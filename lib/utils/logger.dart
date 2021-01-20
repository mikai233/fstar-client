import 'package:logger/logger.dart';

class Log {
  static var logger = Logger(
    printer: PrettyPrinter(methodCount: 1),
  );
}
