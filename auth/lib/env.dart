import 'dart:io' show Platform;

abstract class Env {
  static String sk = Platform.environment['SK'] ?? 'SK';
  static String dbSk = Platform.environment['DB_SK'] ?? ':anb1&(=Ch8aI_<v';
  static int accessTokenLife =
      int.tryParse(Platform.environment['ACCESS_TOKEN_LIFE'] ?? '5') ?? 5;
  static int refreshTokenLife =
      int.tryParse(Platform.environment['REFRESH_TOKEN_LIFE'] ?? '72') ?? 72;
}
