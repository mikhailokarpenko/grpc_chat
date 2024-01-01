import 'dart:async';
import 'dart:developer';
import 'package:chat/data/db.dart';
import 'package:chat/data/grpc_interceptors.dart';
import 'package:chat/env.dart';
import 'package:grpc/grpc.dart';

Future<void> startServer() async {
  runZonedGuarded(() async {
    final authServer = Server.create(
        services: [],
        interceptors: <Interceptor>[GrpcInterceptor.token],
        codecRegistry: CodecRegistry(codecs: [GzipCodec()]));
    await authServer.serve(port: Env.port);
    log("Server listen port ${authServer.port}");
    db = initDatabase();
    db.open();
  }, (error, stack) {
    log("Error", error: error);
  });
}
