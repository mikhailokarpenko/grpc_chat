import 'dart:async';
import 'dart:developer';

import 'package:auth/data/db.dart';
import 'package:auth/domain/auth_rpc.dart';
import 'package:grpc/grpc.dart';

Future<void> startServer() async {
  runZonedGuarded(() async {
    final authServer = Server(
        [AuthRpc()], <Interceptor>[], CodecRegistry(codecs: [GzipCodec()]));
    await authServer.serve(port: 4401);
    log("Server listen port ${authServer.port}");
    db = initDatabase();
    db.open();
  }, (error, stack) {
    log("Error", error: error);
  });
}
