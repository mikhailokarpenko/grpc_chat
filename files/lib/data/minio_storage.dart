import 'package:files/domain/i_storage.dart';
import 'package:files/env.dart';
import 'package:minio/minio.dart';

final class MinioStorage implements IStorage {
  late final Minio minio;

  MinioStorage() {
    minio = Minio(
        port: Env.storagePort,
        endPoint: Env.storageHost,
        accessKey: Env.accessKey,
        secretKey: Env.secretKey,
        useSSL: Env.storageUseSSL);
  }
}
