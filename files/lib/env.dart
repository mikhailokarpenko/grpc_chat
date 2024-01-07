import 'dart:io' show Platform;

abstract class Env {
  static int port = int.parse(Platform.environment['PORT'] ?? '4403');
  static String sk = Platform.environment['SK'] ?? 'secret_key';
  static String skFile =
      Platform.environment['files_sk_file'] ?? ':anb1&(=Ch8aI_<v';
  static String accessKey = Platform.environment['files_access_key'] ?? 'admin';
  static String secretKey =
      Platform.environment['files_secret_key'] ?? 'files_secret_key';
  static bool storageUseSSL =
      bool.tryParse(Platform.environment['FILES_USE_SSL'] ?? "false") ?? false;
  static int storagePort =
      int.tryParse(Platform.environment['FILES_STORAGE_PORT'] ?? "9000") ??
          9000;
  static String storageHost =
      Platform.environment['FILES_STORAGE_HOST'] ?? "localhost";
}
