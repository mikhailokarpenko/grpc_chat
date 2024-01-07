import 'dart:async';
import 'dart:developer';
import 'package:files/data/grpc_interceptors.dart';
import 'package:files/data/minio_storage.dart';
import 'package:files/domain/i_storage.dart';
import 'package:files/env.dart';
import 'package:grpc/grpc.dart';

final MinioStorage storage = MinioStorage();

Future<void> startServer() async {
  runZonedGuarded(() async {
    final authServer = Server.create(services: [
      // FilesRpc()
    ], interceptors: <Interceptor>[
      GrpcInterceptor.token
    ], codecRegistry: CodecRegistry(codecs: [GzipCodec()]));
    await authServer.serve(port: Env.port);
    log("Server listen port ${authServer.port}");
    log("Minio inited on port ${storage.minio.port}");
  }, (error, stack) {
    log("Error", error: error);
  });
}
