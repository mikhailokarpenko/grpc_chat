import 'dart:convert';

import 'package:auth/env.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class Utils {
  static String getHashPassword(String password) {
    final bytes = utf8.encode(password + Env.sk);
    return sha256.convert(bytes).toString();
  }

  static String encryptField(String value, {bool isDecode = false}) {
    final key = Key.fromUtf8(Env.dbSk);
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
    final iv = IV.fromLength(16);
    return isDecode
        ? encrypter.decrypt64(value, iv: iv)
        : encrypter.encrypt(value, iv: iv).base64;
  }

  static int getIdFromToken(String token) {
    final jwtClaim = verifyJwtHS256Signature(token, Env.sk);
    final id = int.tryParse(jwtClaim['user_id']);
    if (id == null) throw GrpcError.dataLoss('User ID not found');
    return id;
  }
}
