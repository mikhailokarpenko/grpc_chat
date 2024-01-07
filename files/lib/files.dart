import 'dart:async';
import 'dart:developer';
import 'package:files/data/grpc_interceptors.dart';
import 'package:files/data/minio_storage.dart';
import 'package:files/domain/files_rpc.dart';
import 'package:files/env.dart';
import 'package:grpc/grpc.dart';

Future<void> startServer() async {
  runZonedGuarded(() async {
    final authServer = Server.create(
        services: [FilesRpc(MinioStorage())],
        interceptors: <Interceptor>[GrpcInterceptor.token],
        codecRegistry: CodecRegistry(codecs: [GzipCodec()]));
    await authServer.serve(port: Env.port);
    log("Server listen port ${authServer.port}");
  }, (error, stack) {
    log("Error", error: error);
  });
}
