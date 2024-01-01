import 'dart:async';
import 'package:chat/data/db.dart';
import 'package:chat/env.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class GrpcInterceptor {
  static FutureOr<GrpcError?> token(ServiceCall call, ServiceMethod method) {
    _updateDatabaseConnectionIfNeeded();

    try {
      final token = call.clientMetadata?['access_token'] ?? '';
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
