import 'dart:io' show Platform;

abstract class Env {
  static int port = int.parse(Platform.environment['files_port']!);
  static String sk = Platform.environment['SK']!;
  static String accessKey = Platform.environment['files_access_key']!;
  static String secretKey = Platform.environment['files_secret_key']!;
  static bool storageUseSSL =
      bool.parse(Platform.environment['files_use_ssl']!);
  static int storagePort =
      int.parse(Platform.environment['files_storage_port']!);
  static String storageHost = Platform.environment['files_storage_host']!;
}
