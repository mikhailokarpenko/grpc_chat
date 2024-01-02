import 'dart:io' show Platform;

abstract class Env {
  static int port = int.parse(Platform.environment['PORT']!);
  static String sk = Platform.environment['SK']!;
}
