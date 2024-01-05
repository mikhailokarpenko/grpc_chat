import 'dart:async';

import 'package:auth/data/db.dart';
import 'package:auth/env.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

final _excludeMethods = ['SignUp', 'SignIn', 'RefreshToken'];

abstract class GrpcInterceptor {
  static FutureOr<GrpcError?> token(ServiceCall call, ServiceMethod method) {
    _updateDatabaseConnectionIfNeeded();

    try {
      if (_excludeMethods.contains(method.name)) return null;
      final token = call.clientMetadata?['token'] ?? '';
      final jwtClaim = verifyJwtHS256Signature(token, Env.sk);
      jwtClaim.validate();
      return null;
    } catch (_) {
      return GrpcError.unauthenticated();
    }
  }

  static void _updateDatabaseConnectionIfNeeded() {
    if (db.connection().isClosed) {
      db = initDatabase();
    }
  }
}
